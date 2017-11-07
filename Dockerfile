FROM nginx:1.13.6-alpine-perl

RUN apk add --no-cache perl-data-uuid=1.221-r0

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint docker-entrypoint

ENTRYPOINT ["./docker-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]
