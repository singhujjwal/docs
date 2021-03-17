# Web Concepts
Here I will again practice creating a website using the latest technology with mobile native application and 
containerized backend, I just hope to keep the steam till the end this time :)

Starting with creating a personal blog --> Later will make it informational for any mid level software engineer to level up
few topics needed for 
1. Mobile apps
2. Websites
3. AI/ML application
4. Cloud Native backend
5. De-coupled code.
6. Not much emphasis on beauty for now, just a working model but with all the extendable tech and build anywhere deploy everywhere.

## SSL Certificates for website

### Certbot
Certbot is used to create letsencrypt certificates for websites


```
certbot certonly   \
-d singhjee.in \
--logs-dir /home/centos/letsencrypt/log/    \
--config-dir /home/centos/letsencrypt/config/    \
--work-dir /home/centos/letsencrypt/work/ \
-m myemail@gmail.com \
--agree-tos --manual --preferred-challenges dns
```