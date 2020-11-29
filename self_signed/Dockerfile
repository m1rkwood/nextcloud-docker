FROM nextcloud:apache

RUN apt-get update

#
# packages for nextcloud video previews
RUN apt install -y ffmpeg imagemagick ghostscript 

#
# other packages I want to install
RUN apt install -y sudo vim

#
# if you want to use a self-signed certificate
RUN openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -subj "/C=CA/ST=QC/L=Local/O=Dev/CN=localhost" -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem
RUN a2enmod ssl
RUN a2ensite default-ssl

#
# expose necessary ports
EXPOSE 8080
EXPOSE 443
