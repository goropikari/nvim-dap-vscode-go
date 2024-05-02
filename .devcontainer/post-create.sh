#!/bin/bash

cargo install stylua

mkdir -p ~/.config
ln -sf /workspaces/nvim-dap-vscode-go/.devcontainer/config/nvim /home/vscode/.config/nvim
mkdir -p ~/.local/share/nvim
wget https://github.com/golang/vscode-go/releases/download/v0.41.4/go-0.41.4.vsix -O ~/.local/share/nvim/vscode-go.vsix
unzip ~/.local/share/nvim/vscode-go.vsix -d ~/.local/share/nvim/vscode-go

cargo install stylua
go install github.com/go-delve/delve/cmd/dlv@latest
