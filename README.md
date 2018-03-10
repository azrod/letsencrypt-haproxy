# Let'sEncrypt For Haproxy (V0.1-Beta)

## Requirement
- Haproxy
- [Certbot](https://certbot.eff.org/)

## How to configure it
```sh
	editor letsencrypt-haproxy.sh
```
```sh
# --- Variable -----------------------------------------------------------------
sendmail="false" # -- Send mail if error in execution script
#
# --- Mail config
emailaddress="contact@example.com" # -- mail address for error mail
#
# --- Temp Directory
dir="/tmp/letsencrypt-generator/" # -- directory temporary for certbot
#
# --- List domain
# Do not fill in the www
listdomain="example.com other-example.com" # -- List of domains separated by spaces (example.com other-example.com)
#
# ------------------------------------------------------------------------------
```

## How to use it
### Generate a unit certificate
```sh
	./letsencrypt-haproxy.sh <domain>
```

### Generate the list of certificates
```sh
	./letsencrypt-haproxy.sh
```

### Use in a crontab
```sh
10 1 15 * * /bin/bash /path/to/directory/letsencrypt-haproxy.sh >/dev/null 2>&1
```

## Haproxy Configuration

### ACL for Let'sEncrypt
Write in Frontend or Listen
```sh
# LET'SENCRYPT
acl acl_letsencrypt path_beg /.well-known/acme-challenge/
```
### Declare a new backend
```sh
backend back_letsencrypt
        server letsencrypt 127.0.0.1:8888
```
