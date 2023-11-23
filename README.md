# isucon秘伝のタレ

## 当日担当

- 初期設定をする人
  - 当日マニュアルを元にサーバーに計測環境を設定する
- コードを読む人
  - どこがボトルネックになっていそうか確認する
  - 必要なエンドポイントが何かを確認する
- レギュレーションを確認する人
  - 違反する可能性があるものを確認する
  - 逆に普通はだめそうだけどレギュレーション的にはOKなものを確認する

## sshまで

1. pemファイルもらう
1. `chmod 600 ./private-isu.pem` で権限を変更
1. `ssh -i ./private-isu.pem <isucon-server-ip>` でssh接続

## 当日マニュアル

1. sshする
1. ベンチマーカー動かす
1. ユーザーの作成
1. gitの設定
1. 権限の変更 
1. 言語切り替える
1. データベースの確認
1. nginx.conf変更
1. alp, pt-query-digestのインストール
1. bench-marker.sh scriptを実行(build scriptのしゅうせい)

## sshまで

1. pemファイルもらう
1. `chmod 600 ./private-isu.pem` で権限を変更
1. `ssh -i ./private-isu.pem <isucon-server-ip>` でssh接続

## ベンチマーカー動かす

たぶん、リーダーボードからボタンポチ

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

cd ~/private_isu
git init

# リポジトリを作成
# https://github.com/new

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
slow_query_log_file=/var/log/mysql/mysql-slow.log
long_query_time=0
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

## nginx.conf変更

```sh
  log_format json escape=json '{"time":"$time_iso8601",'
                            '"host":"$remote_addr",'
                            '"port":$remote_port,'
                            '"method":"$request_method",'
                            '"uri":"$request_uri",'
                            '"status":"$status",'
                            '"body_bytes":$body_bytes_sent,'
                            '"referer":"$http_referer",'
                            '"ua":"$http_user_agent",'
                            '"request_time":"$request_time",'
                            '"response_time":"$upstream_response_time"}';

  access_log /var/log/nginx/access.log json;
```

## alp, pt-query-digestのインストール

```sh

cd "$HOME/private_isu"
mkdir install && cd install

touch alp.sh
touch pt-query-digest.sh

sudo chmod 777 alp.sh
sudo chmod 777 pt-query-digest.sh

# tareからコピーしてきて実行
# NOTE: pt-query-digest.shから実行すること
# https://github.com/TakuroSugahara/isucon-tare/blob/73ccd78e7498d604228c07f63182f342216292b5/install/install-pt-query-digest.sh#L1
# https://github.com/TakuroSugahara/isucon-tare/blob/f8583f1b347bfd89d72917c42dd373f7ba0698ce/install/install-alp.sh#L8

./alp.sh
./pt-query-digest.sh

```

