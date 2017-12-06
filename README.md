# Files

[![Build Status](https://travis-ci.org/fertapric/files.svg?branch=master)](https://travis-ci.org/fertapric/files)

A service to upload files to AWS S3, in around 200 LOC of NGINX configuration!

The service also dynamically resizes images in JPEG, GIF and PNG formats.

## Getting Started

**Files** logic is contained within the NGINX configuration at `nginx/nginx.conf`.

To setup the service, just copy the NGINX configuration file where the `nginx.conf` is placed on the target machine (by default at `/usr/local/nginx/conf`, `/etc/nginx`, or `/usr/local/etc/nginx`). Once the configuration file is there, set the environment variables of the project and start/restart the NGINX service to apply the new configuration.

**Files** must be configured with the following environment variables:

* **FILES_AWS_ACCESS_KEY_ID:** AWS access Key ID.
* **FILES_AWS_SECRET_ACCESS_KEY:** AWS secret key.
* **FILES_AWS_REGION:** AWS region.
* **FILES_AWS_S3_BUCKET:** AWS S3 bucket where the files will be stored.
* **FILES_URL_SCHEME:** scheme for generating URLs throughout the service, `http` or `https`. Defaults to the scheme of the request.
* **FILES_URL_HOST:** host for generating URLs throughout the service. Defaults to the host name from the request line, or host name from the `Host` request header field, or the server name matching a request.
* **FILES_URL_PORT:** port for generating URLs throughout the service. Defaults to 80.

_**Note:** NGINX `listen` directives cannot be configured using environment variables. This means that **Files** will listen on port 80 by default. If you want the service to listen on a different port, you must edit the line `listen 80` on `nginx/nginx.conf` with the desired one._

## Usage

### Uploading files

To upload a file to S3, you must send a `POST` request with the content of the file and the `Content-Type` header to `/`:

```bash
$ curl --verbose -X POST --header "Content-Type: <mime type>" --data-binary @"<path to file" $FILES_URL
```

Here is an example:

```bash
$ curl --verbose -X POST --header "Content-Type: text/plain" --data-binary @"/home/fertapric/document.txt" files.company.com
> POST / HTTP/1.1
> Host: files.company.com
> User-Agent: curl/7.51.0
> Accept: */*
> Content-Type: text/plain
> Content-Length: 15
>
< HTTP/1.1 200 OK
< Server: nginx/1.11.8
< Date: Wed, 25 Jan 2017 21:30:00 GMT
< Content-Length: 0
< Connection: keep-alive
< X-File-URL: http://files.company.com/text/plain/6CEB99DE-E345-11E6-BBA6-C680ACE78BD7
< ETag: "ff22941336956098ae9a564289d1bf1b"
< Cache-Control: no-cache
<
```

Internally, NGINX will include an [AWS Signature Version 4](http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html) authorization header, proxy your request to AWS S3, and include the header `X-File-URL` with the URL of your uploaded file in its response.

The [S3 key](http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingMetadata.html) is generated using a combination of the content type and a unique identifier (i.e. `image/png/6CEB99DE-E345-11E6-BBA6-C680ACE78BD7`).

**Files** currently supports `image/jpeg`, `image/png`, `image/gif` and `text/plain` formats.

### Retrieving files

To download one of the uploaded files, you can simply `GET` it by using the `X-File-URL` you got as a response header when uploading it.

```bash
$ curl http://files.company.com/text/plain/6CEB99DE-E345-11E6-BBA6-C680ACE78BD7

```

Images can be resized dynamically by appending `w` (width) and `h` (height) as query string parameters.

```bash
$ curl http://files.company.com/image/png/6CEB99DE-E345-11E6-BBA6-C680ACE78BD7?w=100&h=100
```

**Files** does not stretch the image (`w` or `h` bigger than the original image), nor changes its proportions (it will satisfy the minimum conditions if both `w` or `h` are provided).

The service uses the [ngx_http_image_filter_module](http://nginx.org/en/docs/http/ngx_http_image_filter_module.html) to provide image resizing. If you need more advanced image manipulation, consider using the [ngx_small_light](https://github.com/cubicdaiya/ngx_small_light) module.

## Testing

**Files** can be tested executing `script/test`.

Before running the script, be sure to launch the service and provide the proper environment variables. **The test uploads several (small) files to S3, so it's recommended to use a dedicated S3 bucket for testing. The S3 bucket is not emptied after running the test suite, for safety reasons.**

`script/test` can be used also for testing staging or production environments:

```bash
FILES_URL=http://files.company.com script/test
```

In addition, NGINX configuration can be analyzed using [GIXY](https://github.com/yandex/gixy):

```shell
$ script/lint
```

## Docker

If you are familiar with Docker, an official image can be found at [https://hub.docker.com/r/fertapric/files/](https://hub.docker.com/r/fertapric/files/).

The Docker image provides an additional environment variable `FILES_PORT` to configure the port in which the service will accept requests. Defaults to port 80.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fertapric/files. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Copyright and License

Copyright 2017 Fernando Tapia Rico

Files source code is licensed under the [MIT License](LICENSE).
