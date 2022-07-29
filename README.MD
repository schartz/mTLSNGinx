
# mTLS on NGINX sample

This repository contains a simple implementation of mTLS on NGINX. mTLS is the TLS flavour of [mutual authentication](https://en.wikipedia.org/wiki/Mutual_authentication).  

For more details check [this article](https://schartz.github.io/blog/tls-and-mtls-deep-dive/).

## Running
You will need docker installed to see this in action.  

Clone this repository.
```bash
git clone https://github.com/schartz/mTLSNGinx.git
```
In the repository root make the `mtls_test.sh` file executable.
```bash
cd /where/this/repository/is/cloned

sudo chmod +x ./mtls_test.sh
```

Now simply run the bash file.
```bash
./mtls_test.sh
```

This shall start an interactive shell, which at the end will spin up a docker container of NGINX configures with mTLS.  

In a separate terminal curl the NGINX running in docker to verify the mTLS in action.

```bash
curl -v  --key certs/client.key --cert certs/client.crt https://127.0.0.1 --insecure 
```
Adding the `--insecure` argument is required, because, for this demo we are using self signed certificates.  

Curl should show something similar to following:

```bash
$ curl -v  --key certs/client.key --cert certs/client.crt https://127.0.0.1 --insecure                                                                                                    :( 127 22-07-29 - 12:10:05
*   Trying 127.0.0.1:443...
* Connected to 127.0.0.1 (127.0.0.1) port 443 (#0)
* ALPN: offers h2
* ALPN: offers http/1.1
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Request CERT (13):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Certificate (11):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS handshake, CERT verify (15):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384
* ALPN: server accepted http/1.1
* Server certificate:
*  subject: CN=*.test.server
*  start date: Jul 29 06:58:45 2022 GMT
*  expire date: Jul 29 06:58:45 2023 GMT
*  issuer: CN=*.test.server
*  SSL certificate verify result: self signed certificate (18), continuing anyway.
> GET / HTTP/1.1
> Host: 127.0.0.1
> User-Agent: curl/7.84.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Server: nginx/1.23.1
< Date: Fri, 29 Jul 2022 06:59:00 GMT
< Content-Type: application/octet-stream
< Content-Length: 55
< Connection: keep-alive
< 
* Connection #0 to host 127.0.0.1 left intact
```



