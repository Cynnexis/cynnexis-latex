FROM ubuntu:18.04
LABEL maintainer="Valentin Berger"

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Update APT and add essential APT packages
RUN apt-get update -y && \
	apt-get install -y dialog apt-utils software-properties-common && \
	apt-get update -y

# Update APT packages
RUN apt-get upgrade -y

# Install basic Linux programs
RUN apt-get install -y build-essential wget curl xzdec zip unzip

# Install fonts
RUN apt-get install -y \
	fontconfig \
	fonts-alee \
	fonts-arabeyes \
	fonts-arphic-bkai00mp \
	fonts-arphic-bsmi00lp \
	fonts-arphic-gbsn00lp \
	fonts-arphic-gkai00mp \
	fonts-atarismall \
	fonts-dustin \
	fonts-f500 \
	fonts-larabie-deco \
	fonts-larabie-straight \
	fonts-larabie-uncommon \
	fonts-sil-gentium \
	fonts-ubuntu-title \
	gsfonts \
	gsfonts-other \
	gsfonts-x11 \
	t1-xfree86-nonfree \
	ttf-ancient-fonts \
	ttf-georgewilliams \
	ttf-isabella \
	ttf-mscorefonts-installer \
	ttf-sjfonts \
	ttf-staypuft \
	ttf-summersby \
	ttf-xfree86-nonfree \
	xfonts-intl-european \
	xfonts-jmk \
	xfonts-terminus

# Install LaTeX
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
	texlive \
	texlive-full \
	texlive-lang-all \
	texlive-latex-extra \
	texlive-pictures

# Install LaTeX dependencies (with vim)
RUN apt-get install -y python-pygments gnuplot vim vim-latexsuite

# Install Microsoft Fonts
RUN apt-get install -y cabextract && \
	mkdir /root/.fonts && \
	cd /root/.fonts && \
	wget -qO- http://plasmasturm.org/code/vistafonts-installer/vistafonts-installer | bash && \
	cd ~

# Setup TLMGR
RUN tlmgr init-usertree ; \
	tlmgr option repository ftp://tug.org/historic/systems/texlive/2017/tlnet-final && \
	tlmgr update --all

EXPOSE 3389 8080
