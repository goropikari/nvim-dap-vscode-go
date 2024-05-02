#!/bin/bash

container_id=$(devcontainer up --workspace-folder=. | tail -n1 | jq -r .containerId)
devcontainer exec --workspace-folder=. mkdir -p /home/vscode/.ssh
docker cp ~/.ssh/id_rsa.pub $container_id:/home/vscode/.ssh/authorized_keys
devcontainer exec --workspace-folder=. bash -c 'chmod 644 /home/vscode/.ssh/authorized_keys'
devcontainer exec --workspace-folder=. bash -c 'chmod 700 /home/vscode/.ssh'
ssh -t -i ~/.ssh/id_rsa -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -p 2222 vscode@localhost
