# Changelog

## v1.3.0 (2017-12-06)

* Upgrade the NGINX Docker image to `nginx:1.13.7-alpine-perl`.
* Add a `version` field in `/check` response.

## v1.2.2 (2017-11-07)

* Upgrade the NGINX Docker image to `nginx:1.13.6-alpine-perl`.

## v1.2.1 (2017-09-12)

* Upgrade the NGINX Docker image to `nginx:1.13.5-alpine-perl`.

## v1.2.0 (2017-07-23)

* Support the `FILES_PORT` environment variable in the Docker image to configure the port in which the service will accept requests. NGINX `listen` directives cannot be configured using environment variables. Because of that, a custom Docker ENTRYPOINT is introduced to modify the `listen` directive. Defaults to port 80.
* Properly fallback to the scheme and host provided by the request.
* Use HTTPS when contacting to AWS S3.
* Upgrade the NGINX Docker image to `nginx:1.13.3-alpine-perl`.

## v1.1.1 (2017-05-30)

* Initial release
