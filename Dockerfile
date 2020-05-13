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
RUN apt-get install -y build-essential wget curl xzdec zip unzip perl

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

COPY tlmgr-install-packages.txt texlive.profile /tmp/

# Install LaTeX
RUN mkdir -p /tmp/install-latex/ && \
	cd /tmp/install-latex/ && \
	url="" && \
	curl -L -o install-tl-unx.tar.gz http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
	mkdir installation-folder && \
	tar -xzf install-tl-unx.tar.gz -C installation-folder --strip-components 1 && \
	cd installation-folder && \
	if [ -z "$CTAN_MIRROR" ]; then \
		echo i | perl install-tl --profile=/tmp/texlive.profile; \
	else \
		echo i | perl install-tl --profile=/tmp/texlive.profile -- location $CTAN_MIRROR; \
	fi && \
	cd ~ && \
	rm -rf /tmp/install-latex/* && \
	rm -f /tmp/texlive.profile && \
	echo 'PATH=/usr/local/texlive/2020/bin/x86_64-linux:$PATH' >> ~/.bashrc

ENV PATH="/usr/local/texlive/2020/bin/x86_64-linux:${PATH}"

# Install LaTeX dependencies (with vim)
RUN apt-get install -y python-pygments gnuplot vim vim-latexsuite

# Install Microsoft Fonts
RUN apt-get install -y cabextract && \
	mkdir /root/.fonts && \
	cd /root/.fonts && \
	wget -qO- http://plasmasturm.org/code/vistafonts-installer/vistafonts-installer | bash && \
	cd ~

# Setup TLMGR & install packages
RUN tlmgr init-usertree && \
	if [ ! -z "$CTAN_MIRROR" ]; then tlmgr option repository $CTAN_MIRROR; fi && \
	tlmgr update --all

EXPOSE 3389 8080
