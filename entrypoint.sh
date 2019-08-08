#!/usr/bin/env bash
editor_exec() {
    /su-exec "$EDITOR_USER_NAME" "$@"
}
if [ ! -e /var/run/docker.sock ]; then
    echo "Error: /var/run/docker.sock not mounted"
    exit 1
fi
EDITOR_USER_NAME=editor
EDITOR_GROUP_NAME=editor
EDITOR_UID="${EDITOR_UID:-10001}"
EDITOR_GID="${EDITOR_GID:-10001}"
EDITOR_USER="${EDITOR_UID}:${EDITOR_GID}"

groupadd -g "$EDITOR_GID" "$EDITOR_GROUP_NAME" || \
    groupmod -n "$EDITOR_GROUP_NAME" $(getent group "$EDITOR_GID" | cut -d: -f1)
useradd -m -u "$EDITOR_UID" -g "$EDITOR_GID" -G 0 -s /bin/bash "$EDITOR_USER_NAME"

if mountpoint /files >/dev/null 2>&1; then
    editor_exec mkdir -p "/files/project"
    editor_exec ln -sf "/files/project" "/home/$EDITOR_USER_NAME/project"
else
    editor_exec mkdir -p "/home/$EDITOR_USER_NAME/project"
fi
editor_exec cp -f /completion.sh "/home/$EDITOR_USER_NAME/.bash_completion"
cd "/home/$EDITOR_USER_NAME/project"
if [ ! -z "$EDITOR_CLONE" ]; then
    editor_exec git clone "$EDITOR_CLONE" || true
fi

# Expose Docker unix socket as a TCP server
# https://github.com/cdr/code-server/issues/436
socat TCP-LISTEN:2376,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock &>/dev/null &
export DOCKER_HOST=tcp://127.0.0.1:2376
export DOCKER_CLI_EXPERIMENTAL=enabled

# Profile
touch /tmp/.versions
docker -v >> /tmp/.versions
docker-compose -v >> /tmp/.versions
echo ". /welcome.sh" >> "/home/$EDITOR_USER_NAME/.bashrc"

# Extensions
if [ ! -z "$EDITOR_EXTENSIONS" ]; then
    IFS=";"
    for EXTENSION in $EDITOR_EXTENSIONS; do
        editor_exec code-server --install-extension "$EXTENSION" || true
    done
fi

# Hosts
if [ ! -z "$EDITOR_LOCALHOST_ALIASES" ]; then
    set +e
    LOCALHOST="127.0.0.1"
    DOCKER_INTERNAL=$(host host.docker.internal | head -n1 | awk '{print $NF}')
    if [ ! -z "$DOCKER_INTERNAL" ]; then
        LOCALHOST="$DOCKER_INTERNAL"
        # include special hostname as an alias for localhost
        EDITOR_LOCALHOST_ALIASES="localhost;$EDITOR_LOCALHOST_ALIASES"
    fi
    set -e
    IFS=";"
    for LOCALHOST_ALIAS in $EDITOR_LOCALHOST_ALIASES; do
        echo "$LOCALHOST $LOCALHOST_ALIAS" >> /etc/hosts
    done
fi

EDITOR_LINE_ENDINGS="${EDITOR_LINE_ENDINGS:-LF}"
if [ "$EDITOR_LINE_ENDINGS" != "CRLF" ]; then
    editor_exec git config --global core.autocrlf false
    editor_exec mkdir -p /home/editor/.local/share/code-server/User
    editor_exec echo '{"files.eol": "\n"}' > /home/editor/.local/share/code-server/User/settings.json
fi

EDITOR_PORT="${EDITOR_PORT:-8443}"
if [ ! -z "$EDITOR_PASSWORD" ]; then
    export PASSWORD="$EDITOR_PASSWORD"
    editor_exec dumb-init code-server --port "$EDITOR_PORT" --allow-http
else
    editor_exec dumb-init code-server --port "$EDITOR_PORT" --allow-http --no-auth
fi
