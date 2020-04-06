# cynnexis/latex

Docker image containing latex & fonts apt packages, based on the [ubuntu image](https://hub.docker.com/_/ubuntu).

[Github][github-link]

[Docker Hub][dockerhub-link]

# Download from the Dockerhub

```bash
docker pull cynnexis/latex
```

# Build

```bash
git clone https://github.com/Cynnexis/cynnexis-latex.git
cd cynnexis-latex
docker build -t cynnexis/latex .
```

## Modifying the Dockerfile

Compiling the Dockerfile can take a lot of time, because of all the packages to download. One way to reduce this time
is to download all the packages only once using the `-d` option with apt-get, then collect all downloaded packages,
save them on the host machine, and finally copy all packages to the container when compiling the image. To achieve this,
follow those steps:

1. In the Dockerfile, add the `-d` option in the APT lines you want to optimize. For instance, the APT lines that
download and install the `texlive` packages is:
```Dockerfile
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y texlive texlive-latex-extra texlive-pictures texlive-full texlive-lang-all
```
and is now transformed into:
```Dockerfile
RUN DEBIAN_FRONTEND=noninteractive apt-get install -dy texlive texlive-latex-extra texlive-pictures texlive-full texlive-lang-all
```

2. Once finished, open a second terminal, and enter:
```bash
docker run --rm -it cynnexis/latex bash
```
In your main terminal, enter:
```bash
docker cp <CONTAINER_ID>:/var/cache/apt/archives <HOST_PATH>
```
where `<CONTAINER_ID>` is the ID of the container running on the second terminal and `<HOST_PATH>` the path where you
want to put all the archives on your host.
> Note that if your `docker build` in step 1 failed, you can still execute the intermediate docker image instead of
> `cynnexis/latex`. To do so, execute `docker images` and take the image ID of the most recent image (it should be at
> the top of the list, with the name `<none>`).

3. Add the following command in the Dockerfile, before any APT commands:
```Dockerfile
ADD <HOST_PATH> /var/cache/apt/archives
```

4. Remove all `-d` APT option in the Dockerfile.

Now, your build should be faster.

# Run

In iteractive mode:

```bash
docker run -it cynnexis/latex bash
```

With a volume (the folder `./latex` in the host):

```bash
docker run -it -v ./latex:/latex cynnexis/latex bash
```

# Docker Compose

Example of `docker-compose.yml`:

```yaml
version: '3.7'
services:
  my-container:
    container_name: my-container
    image: cynnexis/latex
    volumes:
      - './latex:/latex'
```

Example of `Dockerfile`:

```Dockerfile
FROM cynnexis/latex

RUN mkdir /latex
WORKDIR /latex

COPY . .
CMD [ "bash", "-c", "DEBIAN_FRONTEND=noninteractive pdflatex -shell-escape -halt-on-error /latex/my-latex.tex" ]
```

[github-link]: https://github.com/Cynnexis/cynnexis-latex
[dockerhub-link]: https://hub.docker.com/r/cynnexis/latex
