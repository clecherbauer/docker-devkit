$DOCKER_HOSTS_VERSION = "v1.2.2"

# wsl
& wsl --install

# chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#docker-desktop
choco install docker-desktop -y --force

# install docker-hosts
iex ((New-Object System.Net.WebClient).DownloadString('https://gitlab.com/clecherbauer/tools/docker-hosts/-/raw/' + $DOCKER_HOSTS_VERSION + '/windows/online-installer.ps1'))
