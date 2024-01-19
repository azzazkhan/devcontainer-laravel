if (-not (Test-Path -Path ".\.devcontainer" -PathType Container)) {
    New-Item -ItemType Directory -Path ".\.devcontainer" | Out-Null
}

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/azzazkhan/devcontainer-laravel/master/.devcontainer/devcontainer.json" -OutFile ".\.devcontainer\devcontainer.json"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/azzazkhan/devcontainer-laravel/master/docker-compose.yml" -OutFile "docker-compose.yml"
Invoke-WebRequest -Uri "https://github.com/azzazkhan/devcontainer-laravel/raw/master/sail" -OutFile "sail"

Write-Host "Setup complete!"
