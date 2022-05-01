# :bookmark_tabs: cynnexis/latex

[![Project Release](https://img.shields.io/github/release/Cynnexis/cynnexis-latex.svg?logo=github)][project-release]
[![repo size](https://img.shields.io/github/repo-size/Cynnexis/cynnexis-latex)][project-release]
[![total release download](https://img.shields.io/github/downloads/Cynnexis/cynnexis-latex/total)][project-release]
[![license](https://img.shields.io/github/license/Cynnexis/cynnexis-latex)](LICENSE)

Docker image containing latex & fonts packages, based on the [ubuntu image](https://hub.docker.com/_/ubuntu).

[![Github repo](https://img.shields.io/badge/GitHub%20repo-100000?style=for-the-badge&logo=github&logoColor=white)][github-link]

[![Docker Hub](https://img.shields.io/badge/docker%20hub-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)][dockerhub-link]

## :whale: Download from the Docker Hub

```bash
docker pull cynnexis/latex
```

## :hammer_and_pick: Build

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

### :pencil: Modifying the Dockerfile

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

## :arrow_forward: Run

In iteractive mode:

```bash
docker run -it cynnexis/latex bash
```

With a volume (the folder `./latex` in the host):

```bash
docker run -it -v ./latex:/latex cynnexis/latex bash
```

## :pencil2: Example

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

## :building_construction: Built with

[![LaTeX](https://img.shields.io/badge/LaTeX-47A141?style=for-the-badge&logo=LaTeX&logoColor=white)](https://www.latex-project.org/get/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/)
[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/)
[![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/features/actions)

## :handshake: Contributing

To contribute to this project, please read our [`CONTRIBUTING.md`][contributing] file.

We also have a [code of conduct][code-of-conduct] to help create a welcoming and friendly environment.

## :writing_hand: Authors

Please see the [`CONTRIBUTORS.md`][contributors] file.

## :page_facing_up: License

This project is under the MIT License. Please see the [LICENSE][license] file for more detail (it's a really fascinating story written in there!).

[github-link]: https://github.com/Cynnexis/cynnexis-latex
[project-release]: https://github.com/Cynnexis/cynnexis-latex/releases
[dockerhub-link]: https://hub.docker.com/r/cynnexis/latex
[cynnexis]: https://github.com/Cynnexis
[contributing]: CONTRIBUTING.md
[contributors]: CONTRIBUTORS.md
[code-of-conduct]: CODE_OF_CONDUCT.md
[license]: LICENSE
