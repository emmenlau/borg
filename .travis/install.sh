#!/bin/bash

set -e
set -x

chown -R $USER $HOME/.cache/pip || true

if [[ "$(uname -s)" == 'Darwin' ]]; then
    brew update || brew update

    if [[ "${OPENSSL}" != "0.9.8" ]]; then
        brew outdated openssl || brew upgrade openssl
    fi

    if which pyenv > /dev/null; then
        eval "$(pyenv init -)"
    fi

    brew install lz4
    brew install xz  # required for python lzma module
    brew outdated pyenv || brew upgrade pyenv
    brew install pkg-config
    brew install Caskroom/versions/osxfuse-beta

    case "${TOXENV}" in
        py34)
            pyenv install --skip-existing 3.4.3
            pyenv global 3.4.3
            ;;
        py35)
            pyenv install --skip-existing 3.5.1
            pyenv global 3.5.1
            ;;
    esac
    pyenv rehash
    python -m pip install --user 'virtualenv<14.0'
else
    pip install 'virtualenv<14.0'
    sudo apt-get update
    sudo apt-get install -y liblz4-dev
    sudo apt-get install -y libacl1-dev
    sudo apt-get install -y libfuse-dev fuse pkg-config  # optional, for FUSE support
fi

# Always keep pip/setuptools/wheel up to date so that wheels can be successfully built.
pip install -U pip setuptools wheel

python -m virtualenv ~/.venv
source ~/.venv/bin/activate
pip install -r requirements.d/development.txt
pip install codecov
pip install -e .[fuse]
