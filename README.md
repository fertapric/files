# Files

A service to upload files to AWS S3, in less than 180 LOC of nginx configuration!

The service also resizes dynamically images in JPEG, GIF and PNG formats.

## Getting Started

**Files** logic is contained within the nginx configuration at `nginx/nginx.conf`.

If you are not familiar with Docker, copy the configuration file where the `nginx.conf` is placed on the target machine (by default at `/usr/local/nginx/conf`, `/etc/nginx`, or `/usr/local/etc/nginx`). Once the configuration file is there, set the environment variables of the project and start/restart the nginx service to apply the new configuration.

If you are familiar with Docker, build the Docker image (`docker build -t <username>/files .`) using the `Dockerfile` at the root of the project. Once the Docker image is build, you can launch a new container by executing `docker run -P 80:80 -e <env vars list> <username>/files`

#### Environment Variables

**Files** must be configured with the following environment variables:

* `FILES_AWS_ACCESS_KEY_ID`: AWS access Key ID.
* `FILES_AWS_SECRET_ACCESS_KEY`: AWS secret key.
* `FILES_AWS_REGION`: AWS region.
* `FILES_AWS_S3_BUCKET`: AWS S3 bucket where the files will be stored.
* `FILES_HOST`: the host of the service. It **must not** contain the protocol (HTTP/HTTPS)

## Usage

To upload a file to S3, you must send a POST request with the content of the file and the `Content-Type` header at `/`:

```
curl --verbose --header "Content-Type: <mime type>" --data-binary @"<path to file" $FILES_HOST
```

Here is an example:

```
$ curl --verbose --header "Content-Type: text/plain" --data-binary @"/home/fertapric/document.txt" files.company.com
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

Internally, nginx will include an [AWS Signature Version 4](http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html) authorization header, proxy your request to AWS S3 and include the header `X-File-URL` with the URL of your uploaded file.

The [S3 key](http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingMetadata.html) is generated using a combination of the content type and an unique identifier (i.e. `image/png/6CEB99DE-E345-11E6-BBA6-C680ACE78BD7`).

**Files** currently supports `image/jpeg`, `image/png`, `image/gif` and `text/plain` formats.

Images can be dynamically resized by appending `w` (width) and `h` (height) query string parameters: `http://files.company.com/image/png/6CEB99DE-E345-11E6-BBA6-C680ACE78BD7?w=100`. **Files** does not stretch the image (`w` or `h` bigger than the original image) nor change its proportions (it will satisfy the minimum conditions if both `w` or `h` are provided).

The service uses the [ngx_http_image_filter_module](http://nginx.org/en/docs/http/ngx_http_image_filter_module.html) to provide image resizing. If you need a more advanced image manipulation, you can configure and load the [ngx_small_light](https://github.com/cubicdaiya/ngx_small_light) module.

## Testing

**Files** can be tested executing `script/test`.

Before running the script, be sure to provide the proper environment variables. **The test uploads several (small) files to S3, so it's recommended to use a dedicated S3 bucket for testing. The S3 bucket is not emptied after running the test suite for safety reasons.**

`script/test` can be used also for testing staging or production environments:

```
FILES_HOST=files.company.com script/test
```

## License

**Files** is released under the [MIT License](http://www.opensource.org/licenses/MIT).
