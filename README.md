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
    build:
     context: .
     dockerfile: Dockerfile
    volumes:
      - './latex:/latex'
```

Example of `Dockerfile`:

```Dockerfile
FROM cynnexis/latex

RUN mkdir /latex
WORKDIR /latex

COPY . .
CMD [ "bash", "-c", "DEBIAN_FRONTEND=noninteractive pdflatex -shell-escape -halt-on-error -interaction=batchmode /latex/my-latex.tex" ]
```

[github-link]: https://github.com/Cynnexis/cynnexis-latex
[dockerhub-link]: https://hub.docker.com/r/cynnexis/latex
