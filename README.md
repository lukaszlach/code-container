# lukaszlach / code-container

[![Docker pulls](https://img.shields.io/docker/pulls/lukaszlach/code-container.svg?label=docker+pulls)](https://hub.docker.com/r/lukaszlach/code-container)

[Microsoft Visual Studio Code](https://github.com/Microsoft/vscode) running in a Docker container, accessible through the web browser.

![](https://user-images.githubusercontent.com/5011490/59969073-b85e9880-9545-11e9-8d38-e58435cb26f9.png)

Code Container is based on the [Code Server](https://github.com/cdr/code-server) project and extends it by adding:

* configuration with environment variables
* possibility to run as any user and group, preserving credentials for files created in the editor
* automatic installation of editor extensions
* additional tools like `make`, `strace`, `envsubst` or `tldr`
* Docker client and docker-compose with bash completion
* Kubernetes client
* possibility to run in `pid` and `net` host modes, useful when doing Docker workshops
* detection of Docker Desktop and setting `localhost` accordingly

## Configuration

Set an environment variable to configure the editor entrypoint:

* `EDITOR_UID`, `EDITOR_GID` - optional, user id and group id to use, if you wish to map the host values directly pass `-e EDITOR_UID=$(id -u) -e EDITOR_GID=$(id -g)`
* `EDITOR_EXTENSIONS` - optional, semicolon-delimited list of extensions to install
* `EDITOR_PASSWORD` - optional, password required to access the editor
* `EDITOR_CLONE` - optional, repository URL to clone in the editor home directory
* `EDITOR_LOCALHOST_ALIASES` - optional, semicolon-delimited list of host names to map to localhost; if Docker Desktop is detected, `host.docker.internal` becomes an alias for `localhost` inside the editor container
* `EDITOR_BANNER` - optional, banner to display in a new terminal window
* `EDITOR_LINE_ENDINGS` - optional, either `LF` (default) or `CRLF`
* `EDITOR_PORT` - optional, port number to use, useful when using host network mode to run the editor

## Running

Docker container requires mounting `/var/run/docker.sock` from the host system. Set up a volume on target `/files` directory to preserve your work, files created in the editor will respect the user and group ids used to run the editor.

Basic example:

```bash
docker run -d --name code-container --hostname code-container \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e EDITOR_UID=$(id -u) -e EDITOR_GID=$(id -g) \
    -v "$HOME:/files" \
    -p 8443:8443 \
    lukaszlach/code-container
```

Complex example:

```bash
docker run -d --pid host --name code-container --hostname code-container \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$HOME:/files" \
    -e EDITOR_UID=$(id -u) -e EDITOR_GID=$(id -g) \
    -e EDITOR_CLONE="https://github.com/lukaszlach/orca.git" \
    -e EDITOR_EXTENSIONS="peterjausovec.vscode-docker" \
    -e EDITOR_BANNER=Hello \
    -e EDITOR_LOCALHOST_ALIASES="host.local;localtest.me" \
    -e EDITOR_PASSWORD=docker \
    -e EDITOR_PORT=8443 \
    -p 8443:8443 \
    lukaszlach/code-container
```

> Use `--pid host` if you want `htop`, `ps` and similar tools to work like on the host system.

> Set the `--hostname` so it looks nice in the inline terminal.

## Building

```bash
docker build -t lukaszlach/code-container .
```

## License

MIT License

Copyright (c) 2019 Łukasz Lach <llach@llach.pl>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.