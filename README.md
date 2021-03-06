# cynnexis/latex

Docker image containing latex & fonts apt packages, based on the [ubuntu image](https://hub.docker.com/_/ubuntu).

[Github][github-link]

[Docker Hub][dockerhub-link]

## Download from the Docker Hub

```bash
docker pull cynnexis/latex
```

## Build

```bash
git clone https://github.com/Cynnexis/cynnexis-latex.git
cd cynnexis-latex
make build
```

To use a specific CTAN mirror, you can specify it through a build argument like this:

```bash
make build CTAN_MIRROR=https://mirrors.ircam.fr/pub/CTAN/systems/texlive/tlnet/
```

To know which mirror is best for you, you can either ignore the `CTAN_MIRROR` argument (thus the TeX Live installer will automatically choose the best mirror for you), or you can use this [bash scrip](https://gist.github.com/Cynnexis/1b9ce548f1d74bbff9fb13d6c89de268) to take the best mirror according to the ping.

### Modifying the Dockerfile

Compiling the Dockerfile can take a lot of time, because of all the packages to download.
One way to reduce this time is to download all the packages only once using the `-d` option with apt-get, then collect all downloaded packages, save them on the host machine, and finally copy all packages to the container when compiling the image.
To achieve this, follow those steps:

1. In the Dockerfile, add the `-d` option in the APT lines you want to optimize.

2. Once finished, open a second terminal, and enter:
	```bash
	docker run --rm -it cynnexis/latex bash
	```
	In your main terminal, enter:
	```bash
	docker cp <CONTAINER_ID>:/var/cache/apt/archives <HOST_PATH>
	```
	where `<CONTAINER_ID>` is the ID of the container running on the second terminal and `<HOST_PATH>` the path where you want to put all the archives on your host.
	> Note that if your `docker build` in step 1 failed, you can still execute the intermediate docker image instead of `cynnexis/latex`. To do so, execute `docker images` and take the image ID of the most recent image (it should be at the top of the list, with the name `<none>`).

3. Add the following command in the Dockerfile, before any APT commands:
	```Dockerfile
	ADD <HOST_PATH> /var/cache/apt/archives
	```

4. Remove all `-d` APT option in the Dockerfile.

Now, your build should be faster.

## Run

In iteractive mode:

```bash
docker run -it cynnexis/latex bash
```

With a volume (the folder `./latex` in the host):

```bash
docker run -it -v ./latex:/latex cynnexis/latex bash
```

## Example

Example of `Dockerfile` with the [LNCS](https://www.springer.com/gp/computer-science/lncs/conference-proceedings-guidelines) template and building a LaTeX file:

```Dockerfile
FROM cynnexis/latex

RUN mkdir /latex
WORKDIR /latex

# Install LLNCS LaTeX template
RUN mkdir -p $HOME/texmf/tex/latex/llncs && \
	curl -o /tmp/llncs2e.zip ftp://ftp.springernature.com/cs-proceeding/llncs/llncs2e.zip && \
	unzip /tmp/llncs2e.zip -d /tmp/ && \
	mv /tmp/llncs.cls /tmp/splncs04.bst $HOME/texmf/tex/latex/llncs/ && \
	rm -rf /tmp/* && \
	mktexlsr --verbose $HOME/texmf && \
	tree $HOME/texmf

COPY . .
CMD [ "bash", "-c", "DEBIAN_FRONTEND=noninteractive pdflatex -shell-escape -halt-on-error /latex/my-latex.tex" ]
```

[github-link]: https://github.com/Cynnexis/cynnexis-latex
[dockerhub-link]: https://hub.docker.com/r/cynnexis/latex
