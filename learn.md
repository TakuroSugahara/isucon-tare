## 手順

1. `./install/exec.sh` installコマンドで必要なツールをインストール
1. gitでapplication, `/etc/nginx/nginx.conf`, `/etc/mysql/my.cnf` のバックアップをとる
1. nginx.conf, my.confの設定を変更
1. `restart-and-bench.sh` のTODO箇所を変更して実行
1. ベンチマークのスコアが問題なく動けば環境構築完了

## +α

1. vim環境の構築
1. dbのconnectionの設定
1. db clientが表示できるか確認

TODO

- etc nginx, mysql周りの初期設定ファイルを準備する
- etc nginx, mysql周りのシンボリックリンクを設定する
- vimの設定が簡単にできるようにする
  - plugin周りも入れれたら嬉しい
  - clipboard, copyが大変だった
- dadbod uiを入れる
  - indexを見れるようにする
  - indexを作成できるようにする

## 勉強

- nginx.confの設定とチューニングについて学ぶ
  - sendfileの設定
  - UNIXドメインソケットについて
    - ネットワーク通信用のソケットよりも早く通信できるらしいが、、？
  - ggipによる圧縮によってどのぐらい変わるのか
  - 画像周りのファイルに対する expiresのチューニング
    - ネットワークの帯域が詰まることがあるらしいがどういうことだろうか？
  - keepaliveによるパフォーマンス変化
- mysqlのチューニングについて学ぶ
  - max_connectionについて
  - open file limitについて
  - query_cache_limit, query_cache_sizeの設定
    - どのぐらいまで設定するのが適切か？
    - isuconの場合は特にギリギリまで攻めたい
  - バッファプールサイズについて
  - innodbについて
- 画像ファイルのチューニングについて学ぶ
  - publicディレクトリにおいた場合
  - DBに画像ファイルをおいた場合
  - 画像をどのようにしてクライアントに返しているか
  - 画像がpublicにあればそれを返して、なければapplicationを見るってどうやるの？

## Test

### Install test


```sh
$ docker build -t tare .
$ docker run -v ${PWD}/install:/app/install --rm -it tare /bin/sh

./install/exec.sh
```
