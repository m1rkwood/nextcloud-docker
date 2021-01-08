FROM nextcloud:latest

RUN apt-get update

#
# packages for nextcloud video previews
RUN apt install -y ffmpeg imagemagick ghostscript 

#
# other packages I want to install
RUN apt install -y sudo vim
