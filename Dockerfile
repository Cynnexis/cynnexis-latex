FROM ubuntu:18.04
LABEL maintainer="Valentin Berger"

ARG CTAN_MIRROR
ARG DEBUG

USER root
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm
ENV PATH="/usr/local/texlive/2020/bin/x86_64-linux:$PATH"

COPY install-texlive.sh texlive.profile /tmp/

RUN \
	echo "Update APT and add essential APT packages" && \
	apt-get update -y && \
	echo "Install basic Linux programs" && \
	apt-get install -y build-essential wget curl xzdec zip unzip perl dos2unix && \
	echo "Install fonts" && \
	apt-get install -y fontconfig \
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
	xfonts-terminus && \
	echo "Install LaTeX" && \
	dos2unix /tmp/install-texlive.sh /tmp/texlive.profile && \
	chmod a+x /tmp/install-texlive.sh && \
	. /tmp/install-texlive.sh && \
	echo "Install LaTeX dependencies (with vim)" && \
	apt-get install -y python-pygments gnuplot vim vim-latexsuite && \
	echo "Install Microsoft Fonts" && \
	apt-get install -y cabextract && \
	mkdir /root/.fonts && \
	cd /root/.fonts && \
	wget -qO- http://plasmasturm.org/code/vistafonts-installer/vistafonts-installer | bash && \
	cd ~ && \
	echo "Setup TLMGR & install packages" && \
	tlmgr --version && \
	tlmgr init-usertree && \
	tlmgr update --all && \
	echo "Remove apt list" && \
	rm -rf /var/lib/apt/lists/*

EXPOSE 3389 8080
