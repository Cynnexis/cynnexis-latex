#!/bin/bash

CACHE_DIR="/tmp/texlive-cache/$(date +'%Y')"
if [ -d "$CACHE_DIR" ]; then
	# If there is an installation in the Docker cache, use it instead of downloading it.
	mv "$CACHE_DIR" /usr/local/texlive/
	rm -rf /tmp/texlive-cache
else
	mkdir -p /tmp/install-latex/
	cd /tmp/install-latex/

	url=""
	curl -L -o install-tl-unx.tar.gz http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz

	mkdir installation-folder
	tar -xzf install-tl-unx.tar.gz -C installation-folder --strip-components 1
	cd installation-folder

	if [ -z "$CTAN_MIRROR" ]; then
		echo i | perl install-tl --profile=/tmp/texlive.profile
	else
		echo i | perl install-tl --profile=/tmp/texlive.profile -- location $CTAN_MIRROR
	fi
	cd ~
	rm -rf /tmp/install-latex/*
fi

rm -f /tmp/texlive.profile

echo 'PATH=/usr/local/texlive/2020/bin/x86_64-linux:$PATH' >> ~/.bashrc
