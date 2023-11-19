# isucon秘伝のタレ

## sshまで

1. pemファイルもらう
1. `chmod 600 ./private-isu.pem` で権限を変更
1. `ssh -i ./private-isu.pem <isucon-server-ip>` でssh接続

## 当日マニュアル

1. sshする
1. ベンチマーカー動かす
1. ユーザーの作成
1. gitの設定
1. 言語切り替える
1. データベースの確認
1. nginx.conf変更
1. alp, pt-query-digestのインストール
1. bench-marker.sh scriptを実行

## ユーザーの作成

```sh
# afrouユーザーを作成
sudo adduser afrou
# sudo権限を付与
sudo gpasswd -a afrou sudo
sudo su - afrou

touch ~/.vimrc
vim ~/.vimrc
vim ~/.bashrc
source ~/.bashrc
```

## gitの設定

```sh
sudo su - isucon
ssh-keygen 
# enter, enter

# 公開鍵をgithubに登録
# https://github.com/settings/keys

# 接続確認
ssh -T git@github.com

cd ~/private-isu
git init

# git ignoreしたいものがあれば作成
touch .gitignore

# 作成している新しいrepoにpush
git add .
git commit -m "init"
...
```

## 言語切り替える

```sh
$ sudo systemctl stop isu-ruby
$ sudo systemctl disable isu-ruby
$ sudo systemctl start isu-go
$ sudo systemctl enable isu-go
```

## データベースの確認


```sh
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf

slow_query_log=1
slow_query_log_file=/var/log/mysql/mysql-slow.sql
long_query_time=0.1

query_cache_type = 1
query_cache_limit = 2M
query_cache_size = 32M
```

```sh
# slow query確認
SHOW variables like 'slow_query%'; で確認
```

```sh
SHOW databases;
USE {table_name};
SHOW tables;

# index確認
SHOW INDEX FROM {table_name};

# index作成
ALTER TABLE comments ADD INDEX post_id_idx (post_id, created_at DESC);

```

## alp, pt-query-digestのインストール

```sh

cd private-isu
mkdir install

touch alp.sh
touch pt-query-digest.sh

sudo chmod 777 alp.sh
sudo chmod 777 pt-query-digest.sh

# tareからコピーしてきて実行
# https://github.com/TakuroSugahara/isucon-tare/blob/73ccd78e7498d604228c07f63182f342216292b5/install/install-alp.sh#L11
# https://github.com/TakuroSugahara/isucon-tare/blob/73ccd78e7498d604228c07f63182f342216292b5/install/install-pt-query-digest.sh#L1

./alp.sh
./pt-query-digest.sh

```

