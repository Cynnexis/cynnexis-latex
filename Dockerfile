FROM ubuntu:18.04
MAINTAINER Valentin Berger
LABEL maintainer="Valentin Berger"

USER root
ARG DEBIAN_FRONTEND=noninteractive

COPY *.sh /
RUN chmod +x install-latex.sh && sleep 1 && ./install-latex.sh && rm install-latex.sh

EXPOSE 3389 8080
