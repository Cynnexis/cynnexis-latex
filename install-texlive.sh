#!/bin/bash
set -euo pipefail

get_texlive_install_folder() {
	find /usr/local/texlive/ -maxdepth 1 -type d | grep -Pe '\d{4,}' | sort | tail -n1 | xargs readlink -f
}

echo "Installing TeX Live..."
CACHE_DIR="/tmp/texlive-cache/$(date +'%Y')"
if [[ -d $CACHE_DIR ]]; then
	# If there is an installation in the Docker cache, use it instead of downloading it.
	echo "Using cache \"$CACHE_DIR\"."
	mv "$CACHE_DIR" /usr/local/texlive/
	rm -rf /tmp/texlive-cache
	texlive_installation_folder=$(get_texlive_install_folder)
else
	mkdir -p /tmp/install-latex/
	cd /tmp/install-latex/

	echo "Downloading TeX Live installer..."
	curl -L -o install-tl.tar.gz http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz

	mkdir installation-folder
	echo "Extracting..."
	tar -xzf install-tl.tar.gz -C installation-folder --strip-components 1
	cd installation-folder

	INSTALLATION_ARGS=""
	if [[ -f "/tmp/texlive.profile" ]]; then
		INSTALLATION_ARGS="--profile=/tmp/texlive.profile"
	fi

	if [[ ! -v CTAN_MIRROR || -z $CTAN_MIRROR ]]; then
		echo "Installing TeX Live..."
	else
		echo "Installing TeX Live through the CTAN mirror \"$CTAN_MIRROR\"..."
		INSTALLATION_ARGS="$INSTALLATION_ARGS --location=$CTAN_MIRROR"
	fi
	set +eo pipefail
	yes i | perl install-tl "$INSTALLATION_ARGS"
	exit_code=$?
	texlive_installation_folder=$(get_texlive_install_folder)
	if [[ $exit_code -ne 0 ]]; then
		echo "The installation of TeX Live failed. Error code: $exit_code"
		if [[ -r "$texlive_installation_folder/install-tl.log" ]]; then
			echo "$texlive_installation_folder/install-tl.log:"
			cat "$texlive_installation_folder/install-tl.log"
		fi
		exit $exit_code
	fi
	set -eo pipefail
	cd ~
	rm -rf /tmp/install-latex/*
fi

# Get the texlive installation folder (if not defined)
if [[ ! -v texlive_installation_folder || -z $texlive_installation_folder ]]; then
	texlive_installation_folder=$(get_texlive_install_folder)
fi

rm -f /tmp/texlive.profile
rm -f "$texlive_installation_folder/install-tl.log"

# Export executables to directory in PATH (as symbolic links)
bin_dir=/usr/local/bin
find -L "$texlive_installation_folder/bin/x86_64-linux" -maxdepth 1 -type f -executable -exec ln -st "$bin_dir/" "{}" +

echo "TeX Live has been successfully installed at $(which tlmgr) with version:"
tlmgr --version
