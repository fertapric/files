FROM nginx:1.11.8-alpine

RUN apk add --no-cache alpine-sdk perl-data-uuid

COPY nginx/nginx.conf /etc/nginx/nginx.conf
