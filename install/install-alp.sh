#!/bin/sh

# alpがインストールされているか確認する
if command -v alp >/dev/null 2>&1; then
  echo "alp is already installed."
else
  # alpをダウンロードして展開する
  wget https://github.com/tkuchiki/alp/releases/download/v1.0.21/alp_linux_amd64.zip
  unzip alp_linux_amd64.zip

  # alpをパスの通ったディレクトリにインストールする
  sudo chmod 711 /usr/local/bin
  sudo install ./alp /usr/local/bin

  echo "alp has been installed successfully."
fi

