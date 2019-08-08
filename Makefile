build:
	docker build -t code-editor .

list:
	docker images | grep code-editor

run:
	rm -rf test/ && mkdir test/
	docker run --rm -it --name code-editor -v /var/run/docker.sock:/var/run/docker.sock -e EDITOR_UID=$$(id -u) -e EDITOR_GID=$$(id -g) -e EDITOR_CLONE="https://github.com/lukaszlach/orca.git" -e EDITOR_EXTENSIONS="peterjausovec.vscode-docker" -e EDITOR_BANNER=code-container -e EDITOR_LOCALHOST_ALIASES="local;localtest.me" -e EDITOR_PASSWORD=docker -e EDITOR_PORT=8443 -p 8443:8443 -v $$(pwd)/test:/files --hostname workshop --pid host code-editor

push:
	docker tag code-editor lukaszlach/code-container
	docker push lukaszlach/code-container

