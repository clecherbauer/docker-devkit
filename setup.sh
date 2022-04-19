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


echo "Setting up clecherbauer/docker-alias ..."
REPO_PATH="/opt/docker-alias"
AUTO_DOCKER_ALIAS_PATH="/usr/local/bin/auto-docker-alias"
DOCKER_ALIAS_PATH="/usr/local/bin/docker-alias"

[ -e "$REPO_PATH" ] && sudo rm -Rf "$REPO_PATH"
sudo git clone --depth 1 --branch 1.3.0 https://github.com/clecherbauer/docker-alias /opt/docker-alias > /dev/null 2>&1

[ -e "$AUTO_DOCKER_ALIAS_PATH" ] && sudo rm "$AUTO_DOCKER_ALIAS_PATH"
[ -e "$DOCKER_ALIAS_PATH" ] && sudo rm "$DOCKER_ALIAS_PATH"
sudo ln -s /opt/docker-alias/auto-docker-alias "$AUTO_DOCKER_ALIAS_PATH"
sudo ln -s /opt/docker-alias/docker-alias "$DOCKER_ALIAS_PATH"
sudo chmod 750 /opt/docker-alias/auto-docker-alias
sudo chmod 750 /opt/docker-alias/docker-alias
sudo chmod 555 "$AUTO_DOCKER_ALIAS_PATH"
sudo chmod 555 "$DOCKER_ALIAS_PATH"


echo "Enable clecherbauer/docker-alias ..."
COMMAND="source auto-docker-alias"
SHELLRCS="$HOME/.zshrc $HOME/.bashrc"
for SHELLRC in $SHELLRCS
do
    if [ -f "$SHELLRC" ]; then
        if ! grep -Fxq "$COMMAND" "$SHELLRC"; then
            echo "$COMMAND" >> "$SHELLRC"
        fi
    fi
done

echo "Setting up lebokus/bindfs ..."
if ! docker plugin ls | grep -q "lebokus/bindfs"; then
  docker plugin install lebokus/bindfs --grant-all-permissions > /dev/null 2>&1
fi

echo "Setting up costela/docker-etchosts ..."
if docker ps -a | grep -q "docker-etchosts" ; then
    docker kill docker-etchosts || true > /dev/null 2>&1
    docker rm docker-etchosts > /dev/null 2>&1
fi
docker run -d --name docker-etchosts --network none --restart always -v /etc/hosts:/etc/hosts -v /var/run/docker.sock:/var/run/docker.sock costela/docker-etchosts > /dev/null 2>&1

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
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 80:80 --name traefik-proxy --network public --net-alias traefik.docker -l traefik.frontend.rule=Host:traefik.docker -l traefik.port=8080 -v /opt/traefik.toml:/traefik.toml --restart always traefik:1.7-alpine > /dev/null 2>&1

echo "Please close this shell instance and start a new one to load docker-alias"

