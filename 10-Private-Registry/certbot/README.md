source: https://www.digitalocean.com/community/tutorials/how-to-acquire-a-let-s-encrypt-certificate-using-dns-validation-with-acme-dns-certbot-on-ubuntu-18-04
## Install Certbot
```shell
$ sudo apt-add-repository ppa:certbot/certbot
$ sudo apt install certbot
$ certbot --version
#certbot 0.40.0
```
## Fetch the acme-dns-auth.py or use existing one 
```shell
$ wget https://github.com/joohoi/acme-dns-certbot-joohoi/raw/master/acme-dns-auth.py
$ chmod +x acme-dns-auth.py
$ nano acme-dns-auth.py
# change python to python3
# #!/usr/bin/env python3

$ sudo cp acme-dns-auth.py /etc/letsencrypt/
```

## Generate certificate for kuruhurma.com (my private domain)
```shell
$ sudo rm -rf /etc/letsencrypt/acmedns.json
$ sudo certbot certonly --manual --manual-auth-hook /etc/letsencrypt/acme-dns-auth.py --preferred-challenges dns --debug-challenges -d \*.kuruhurma.com -d kuruhurma.com
```