# docker-devkit
A collection of tools for a more developer-friendly experience with docker

## Features:
### docker-hosts
expose all containers with network aliases to the machines /etc/hosts file, so you dont need to take care about port bindings  
### docker-alias
dockerized tools 
### lazydocker
easy to use docker gui
### traefik
is needed to access containers in docker-desktop environments or enables you to access your containers from your network in linux environments (usefully for mobile-testing)

## Ubuntu (tested with Ubuntu 20.04)
### Requirements:
- unzip
- docker
- docker-compose
- zsh or bash
- sufficient permissions to execute docker commands (adduser int docker group)

### Installation
`wget -q -O - "https://gitlab.com/clecherbauer/tools/docker-devkit/-/raw/master/linux/setup.sh" | bash`


## Windows (tested with Windows 10 Pro)
### Requirements:
- Virtualization enabled in BIOS
- WSL2
- docker-desktop
- Ubuntu on WSL

### Installation of the Dependencies:
This part will install WSL2, docker-desktop and docker-hosts.

1. Make sure Windows is fully updated (and rebooted), and you are running an administrative PowerShell.
2. Execute the following commands:
`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://gitlab.com/clecherbauer/tools/docker-devkit/-/raw/master/windows/setup_dependencies.ps1'))
`
3. Wait - This step will take some time, so grab a cup of Coffee :)
4. Reboot your Machine
5. Go to the Microsoft App Store and pick Ubuntu 20.04 [tutorial](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-10#3-download-ubuntu)
6. wsl --install -d ubuntu
7. make ubuntu your default WSL Distro with `wsl --setdefault ubuntu` so you dont have to add `-d ubuntu` everytime.
8. Enable docker-desktop WSL Integration for your Ubuntu Distro, to do so please follow [this](https://docs.docker.com/desktop/windows/wsl/#:~:text=Start%20Docker%20Desktop%20from%20the,will%20be%20enabled%20by%20default).

   (docker-desktop -> settings -> Resources -> WSL-Integration -> Enable integration with my default WSL distro)


### Installation in WSL Ubuntu:
This part will install docker-alias, direnv and xy

1. Enable [WSL Metadata](https://alessandrococco.com/2021/01/wsl-how-to-resolve-operation-not-permitted-error-on-cloning-a-git-repository):
```
wsl
sudo su
echo "[automount]" > /etc/wsl.conf
echo "options = \"metadata\"" >> /etc/wsl.conf
exit
exit
wsl --shutdown
```
2. Restart Docker-Desktop
3. Switch back into WSL Ubuntu: `wsl`.
4. Execute the following command:
`wget -q -O - "https://gitlab.com/clecherbauer/tools/docker-devkit/-/raw/master/linux/setup.sh" | bash`

## macOS (tested with macOS xyz)
### Requirements:
- enabled virtualization
- docker-desktop
