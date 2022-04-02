FROM nginx:alpine

RUN apk add --update wget libc6-compat g++

ARG HUGO_VERSION="0.96.0"
ARG HUGO_BINARY="hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz"
ARG HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY}"

RUN wget --quiet "${HUGO_URL}" && \
    tar xzf ${HUGO_BINARY} && \
    rm -r ${HUGO_BINARY} && \
    mv hugo /usr/bin 

WORKDIR /app
COPY ./ ./
RUN hugo

RUN cp -rf ./public/* /usr/share/nginx/html/
RUN cp -f ./nginx.conf /etc/nginx/conf.d/default.conf

