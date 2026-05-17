# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.23

# set version label
ARG BUILD_DATE
ARG VERSION
ARG ETHERPAD_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="johnmclear"

# environment settings
ENV \
  NODE_ENV=production \
  ETHERPAD_PRODUCTION=true \
  EP_DIR=/app/etherpad-lite

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    git \
    python3 && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    nodejs \
    npm && \
  echo "**** install pnpm ****" && \
  npm install -g pnpm@11.1.2 && \
  echo "**** download etherpad ****" && \
  if [ -z ${ETHERPAD_VERSION+x} ]; then \
    ETHERPAD_VERSION=$(curl -sX GET "https://api.github.com/repos/ether/etherpad/releases/latest" | jq -r '. | .tag_name'); \
  fi && \
  mkdir -p \
    /app/etherpad-lite && \
  curl -o \
    /tmp/etherpad.tar.gz -L \
    "https://github.com/ether/etherpad/archive/refs/tags/${ETHERPAD_VERSION}.tar.gz" && \
  tar xf \
    /tmp/etherpad.tar.gz -C \
    /app/etherpad-lite --strip-components=1 && \
  cd /app/etherpad-lite && \
  echo "**** build etherpad ****" && \
  pnpm install --frozen-lockfile --prod=false && \
  pnpm run build:etherpad && \
  echo "**** prune to production deps ****" && \
  find . -type d -name node_modules -prune -exec rm -rf {} + && \
  pnpm install --prod --frozen-lockfile --ignore-scripts && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /root/.npm \
    /root/.local \
    /tmp/* \
    /var/cache/apk/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9001
VOLUME /config
