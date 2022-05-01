#!/usr/bin/env bash
set -e

DOCKER_ALIAS_VERSION="v2.0.4"
DOCKER_HOSTS_VERSION="v1.1.1"

if [ ! -x "$(command -v docker)" ]; then
    echo "Please install docker"
    exit 1
fi
if [ ! -x "$(command -v docker-compose)" ]; then
    echo "Please install docker-compose"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "Please make sure docker is running and you have sufficient permissions"
    exit 1
fi

if [ ! -x "$(command -v unzip)" ]; then
    echo "unzip is missing!"
    sudo apt update
    sudo apt install unzip
fi


function report_on_error() {
    set +e
    ERROR=$(eval $1 2>&1)
    if [ "$?" -gt 0 ]; then
      echo "$ERROR"
      echo ""
    fi
    set -e
}

function setup_wsl() {
    echo "Setting up clecherbauer/docker-alias ..."
    report_on_error 'wget -qO- "https://gitlab.com/clecherbauer/tools/docker-alias/-/raw/"$DOCKER_ALIAS_VERSION"/linux/online-installer.sh" | bash'
    rm docker-alias.linux64.zip
    (
      SHELLS="zsh bash"
      for _SHELL in $SHELLS
      do
          SHELLRC="$HOME/.$_SHELL"rc
          COMMAND="docker-alias-daemon start"
          if [ -f "$SHELLRC" ]; then
              if ! grep -Fxq "$COMMAND" "$SHELLRC"; then
                  echo "$COMMAND" >> "$SHELLRC"
              fi
          fi
      done
    )
}

function setup_linux() {
    echo "Setting up clecherbauer/docker-alias ..."
    report_on_error 'wget -qO- "https://gitlab.com/clecherbauer/tools/docker-alias/-/raw/"$DOCKER_ALIAS_VERSION"/linux/online-installer.sh" | bash'
    rm docker-alias.linux64.zip
    (
      SHELLS="zsh bash"
      for _SHELL in $SHELLS
      do
          SHELLRC="$HOME/.$_SHELL"rc
          COMMAND="docker-alias-daemon start"
          if [ -f "$SHELLRC" ]; then
              if ! grep -Fxq "$COMMAND" "$SHELLRC"; then
                  echo "$COMMAND" >> "$SHELLRC"
              fi
          fi
      done
    )
}

function setup_general() {
    echo "Setting up direnv"
    (
      USER_BIN_DIR="$HOME/.local/bin"
      if [ ! -d "$USER_BIN_DIR" ]; then mkdir -p "$USER_BIN_DIR"; fi
      export bin_path="$HOME/.local/bin"
      wget -q -O - https://direnv.net/install.sh | bash > /dev/null 2>&1
      SHELLS="zsh bash"
      for _SHELL in $SHELLS
      do
          SHELLRC="$HOME/.$_SHELL"rc
          COMMAND="eval \"\$(direnv hook $_SHELL)\""
          if [ -f "$SHELLRC" ]; then
              if ! grep -Fxq "$COMMAND" "$SHELLRC"; then
                  echo "$COMMAND" >> "$SHELLRC"
              fi
          fi
      done
    )

    echo "Setting up jesseduffield/lazydocker"
    [ -d "$HOME/.local/bin/" ] || mkdir "$HOME/.local/bin/"
    report_on_error 'wget -qO- https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash'
    mv lazydocker "$HOME/.local/bin/"

    echo "Setting up lebokus/bindfs ..."
    if ! docker plugin ls | grep -q "lebokus/bindfs"; then
      report_on_error 'docker plugin install lebokus/bindfs --grant-all-permissions'
    fi

    echo "Setting up clecherbauer/docker-hosts ..."
    if docker ps -a | grep -q "docker-hosts" ; then
        docker kill docker-hosts || true > /dev/null 2>&1
        docker rm docker-hosts > /dev/null 2>&1
    fi
    report_on_error 'docker run -d --name docker-hosts --network none --restart always -v /etc/hosts:/etc/hosts -v /var/run/docker.sock:/var/run/docker.sock "registry.gitlab.com/clecherbauer/tools/docker-hosts:$DOCKER_HOSTS_VERSION"'

    echo "Setting up traefik ..."
    sudo tee /opt/traefik.toml > /dev/null <<EOT
defaultEntryPoints = ["http"]

[entryPoints]
  [entryPoints.dashboard]
    address = ":8080"
  [entryPoints.http]
    address = ":80"

[api]
entrypoint="dashboard"

[docker]
domain = "docker"
watch = true
network = "public"
EOT

    if docker ps -a | grep -q "traefik-proxy" ; then
        docker kill traefik-proxy || true > /dev/null 2>&1
        docker rm traefik-proxy > /dev/null 2>&1
    fi
    if ! docker network ls | grep -q "public" ; then
      docker network create public
    fi
    report_on_error 'docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 80:80 --name traefik-proxy --network public --net-alias traefik.docker -l traefik.frontend.rule=Host:traefik.docker -l traefik.port=8080 -v /opt/traefik.toml:/traefik.toml --restart always traefik:1.7-alpine'

    echo "In order to use direnv and docker-alias, please reload this shell!"
}

if grep -q WSL2 /proc/version; then
    setup_wsl
else
    setup_linux
fi
setup_general