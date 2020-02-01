#!/bin/bash

# Measure time
STARTTIME=$(date +%s)

# Update APT packages list
apt-get update -qq
apt-get install -qy dialog
apt-get install -qy apt-utils
apt-get install -qy software-properties-common
apt-get update -qq

# Update APT packages
apt-get upgrade -qq

# Install basic Linux programs
apt-get install -qy wget
apt-get install -qy xzdec

# Install fonts
apt-get install -qy gsfonts gsfonts-other gsfonts-x11 ttf-mscorefonts-installer t1-xfree86-nonfree fonts-alee ttf-ancient-fonts fonts-arabeyes fonts-arphic-bkai00mp fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp fonts-arphic-gkai00mp fonts-atarismall fonts-dustin fonts-f500 fonts-sil-gentium ttf-georgewilliams ttf-isabella fonts-larabie-deco fonts-larabie-straight fonts-larabie-uncommon ttf-sjfonts ttf-staypuft ttf-summersby fonts-ubuntu-title ttf-xfree86-nonfree xfonts-intl-european xfonts-jmk xfonts-terminus

# Install LaTeX
apt-get install -qy texlive
DEBIAN_FRONTEND=noninteractive apt-get install -qy texlive-latex-extra
apt-get install -qy texlive-pictures
apt-get install -qy texlive-full
apt-get install -qy texlive-lang-all

# Install LaTeX dependencies
apt-get install -qy python-pygments
apt-get install -qy gnuplot

# Install vim and its LaTeX plugin
apt-get install -qy vim
apt-get install -qy vim-latexsuite

# Install Microsoft Fonts
apt-get install -qy cabextract
mkdir /root/.fonts
cd /root/.fonts
wget -qO- http://plasmasturm.org/code/vistafonts-installer/vistafonts-installer | bash
cd ~

ENDTIME=$(date +%s)
echo "Time for installation: $(($ENDTIME - $STARTTIME)) seconds"
