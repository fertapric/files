FROM nginx:1.13.0-alpine-perl

RUN apk add --no-cache perl-data-uuid=1.221-r0

COPY nginx/nginx.conf /etc/nginx/nginx.conf
