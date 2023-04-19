# isucon秘伝のタレ

TODO

- etc nginx, mysql周りの初期設定ファイルを準備する
- etc nginx, mysql周りのシンボリックリンクを設定する
- buildをできるようにする
- vimの設定が簡単にできるようにする
  - plugin周りも入れれたら嬉しい
  - clipboard, copyが大変だった


## Test

### Install test


```sh
$ docker build -t tare .
$ docker run -v ${PWD}/install:/app/install --rm -it tare /bin/sh

./install/exec.sh
```
