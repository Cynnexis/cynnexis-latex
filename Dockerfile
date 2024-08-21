# DOCKERFILE
#
# cynnexis/latex
#
# This Dockerfile contains a LaTeX environment to compile TeX documents.
#
# Build it with:
# docker build -t cynnexis/latex .
#
# The build arguments are:
# * PROJECT_VERSION: Required argument representing the project version. It
#   should be the content of the "VERSION" file, without line breaks, nor
#   trailing whitespaces.
# * APT_UBUNTU_MIRROR: Optional URL to use an APT mirror instead of default
#   Ubuntu servers. Please make sure that the given value starts with the
#   protocol (http://, https://, ftp://, ...) and ends with a slash ("/").
# * CTAN_MIRROR: Optional argument. The CTAN mirror to use during build.
# * DEBUG: Optional argument. Set it to "true" to activate debug build. Do NOT
#   do this in production. It is recommended to tag the image with ":debug".
# * DEBIAN_FRONTEND: Optional argument, defaults to "noninteractive".
# * TERM: Optional argument. The term environment variable, defaults to "xterm".

# The base image name, it should be a Debian-based distribution.
ARG BASE_IMAGE="ubuntu"

# The tag of the image.
ARG BASE_TAG="20.04"

FROM ${BASE_IMAGE}:${BASE_TAG}

# Inherit arguments from global scope
ARG BASE_IMAGE
ARG BASE_TAG

# The creation date of this image, conforming to RFC 3339: YYYY-MM-DDThh:mm:ssZ
ARG CREATE_DATE

ARG BASE_DIGEST

# The project version. It should be the content of the "VERSION" file, without
# line breaks, nor trailing whitespaces.
ARG PROJECT_VERSION

# Define labels
LABEL org.opencontainers.image.title="cynnexis-latex"
LABEL org.opencontainers.image.description="Docker image containing latex & fonts packages, based on the ubuntu image."
LABEL org.opencontainers.image.base.name="${BASE_IMAGE}:${BASE_TAG}"
LABEL org.opencontainers.image.base.digest="${BASE_DIGEST}"
LABEL org.opencontainers.image.version="$PROJECT_VERSION"
LABEL org.opencontainers.image.authors="Valentin Berger"
LABEL org.opencontainers.image.url="https://github.com/Cynnexis/cynnexis-latex"
LABEL org.opencontainers.image.documentation="https://github.com/Cynnexis/cynnexis-latex"
LABEL org.opencontainers.image.source="https://github.com/Cynnexis/cynnexis-latex"
LABEL org.opencontainers.image.created="${CREATE_DATE}"

# Arguments to use an APT mirror instead of default Ubuntu servers. Please make
# sure that the given value starts with the protocol (http://, https://,
# ftp://, ...) and ends with a slash ("/").
ARG APT_UBUNTU_MIRROR
# The CTAN mirror to use during build.
ARG CTAN_MIRROR
# Set it to "true" to activate debug build. Do NOT do this in production. It is
# recommended to tag the image with ":debug".
ARG DEBUG

USER root
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive
ENV OSFONTDIR="/usr/share/fonts:/usr/local/share/fonts:/root/.fonts" \
	TERM=xterm

COPY install-texlive.sh texlive.profile /tmp/

RUN \
	# Change the APT mirror
	if [[ -n $APT_UBUNTU_MIRROR ]]; then \
		cp /etc/apt/sources.list /etc/apt/sources.bak.list && \
		sed "s@http://archive.ubuntu.com/@$APT_UBUNTU_MIRROR@" -i /etc/apt/sources.list ; \
	fi && \
	echo "Update APT and add essential APT packages" && \
	apt-get update -y && \
	echo "Install basic Linux programs" && \
	apt-get install -qqy build-essential wget curl xzdec zip unzip perl && \
	echo "Install fonts" && \
	apt-get install -qqy \
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
		xfonts-terminus && \
	echo "Install LaTeX" && \
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
	echo "Update font cache" && \
	luaotfload-tool --update && \
	echo "Clean-up" && \
	apt-get autoremove --purge -qqy build-essential wget curl xzdec zip unzip && \
	rm -f /tmp/install-texlive.sh /tmp/texlive.profile && \
	echo "Remove apt list" && \
	# Change back the APT mirror
	if [[ -f /etc/apt/sources.bak.list ]]; then \
		cp /etc/apt/sources.bak.list /etc/apt/sources.list ; \
	fi && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*
