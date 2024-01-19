#!/bin/bash

if [ ! -d ".devcontainer" ]; then
    mkdir .devcontainer
fi

curl -sSL https://raw.githubusercontent.com/azzazkhan/devcontainer-laravel/master/.devcontainer/devcontainer.json -o .devcontainer/devcontainer.json
curl -sSLO https://raw.githubusercontent.com/azzazkhan/devcontainer-laravel/master/docker-compose.yml
curl -sSLO https://github.com/azzazkhan/devcontainer-laravel/raw/master/sail

chmod +x sail
