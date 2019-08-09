#!/bin/sh

BASE_DIR=$(pwd)
DEPS_MISSING=false
DEPLOY_KEY_FE="deploy-fe.priv"
DEPLOY_KEY_BE="deploy-be.priv"
FRONTEND_REPO="git@github.com:tomislavperich/kanban-frontend.git"
BACKEND_REPO="git@github.com:tomislavperich/kanban-backend.git"

# Check dependencies
for cmd in git docker docker-compose; do
    if ! command -v $cmd 1>/dev/null; then
        echo "Please install ${cmd} to continue"
        DEPS_MISSING=true
    fi
done

if $DEPS_MISSING; then
    exit 1
fi

# Clone repositories
if [ -f $DEPLOY_KEY_FE ] && [ -f $DEPLOY_KEY_BE ]; then
    export GIT_SSH_COMMAND="ssh -i ${BASE_DIR}/${DEPLOY_KEY_FE}"
    git clone $FRONTEND_REPO

    export GIT_SSH_COMMAND="ssh -i ${BASE_DIR}/${DEPLOY_KEY_BE}"
    git clone $BACKEND_REPO
else
    echo "Missing deployment keys, exiting..."
    exit 1
fi

# Deploy
WORKDIR="kanban-frontend"
cd "${BASE_DIR}/${WORKDIR}" && sudo docker-compose up -d

WORKDIR="kanban-backend"
cd "${BASE_DIR}/${WORKDIR}" && sudo docker-compose up -d

echo "[+] You can see the project running at http://localhost/!"
