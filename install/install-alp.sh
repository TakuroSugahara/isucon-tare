#!/bin/sh

# alpがインストールされているか確認する
if command -v alp >/dev/null 2>&1; then
  echo "alp is already installed."
else
  # alpをダウンロードして展開する
  wget https://github.com/tkuchiki/alp/releases/download/v0.3.1/alp_linux_amd64.zip
  unzip alp_linux_amd64.zip

  # alpをパスの通ったディレクトリにインストールする
  sudo chmod 777 /usr/local/bin
  sudo install ./alp /usr/local/bin

  rm ./percona-toolkit_3.0.10-1.xenial_amd64.deb
  rm ./alp_linux_amd64.zip
  rm ./alp

  echo "alp has been installed successfully."
fi

# alpのバージョンを確認する
alp --version
