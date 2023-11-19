### とりあえず

```my.cnf
[mysqld]
slow_query_log=1
slow_query_log_file=/var/log/mysql/mysql-slow.sql
long_query_time=1

query_cache_type = 1
query_cache_limit = 2M
query_cache_size = 32M
```

### max connections
Too many connections error が出る時は、max connections を大きくする。
ただし、`5_os` にしたがって「OS 側での connection, open file limit の設定の更新」をする必要がある（OS側で制限されてると、mysql 側ではその制限の範囲内でしか設定を変えれない）

`/etc/mysql/my.cnf` このファイルは初期でないことがあるので注意
似たようなファイルがあるが、このファイルに設定しないと反映されない

```
# /etc/mysql/my.cnf

max_connections=10000  # <- connection の limit を更新
```

`SHOW variables LIKE "%max_connection%";` で確認

### slow query

```
[mysqld]
slow_query_log=1
slow_query_log_file=/var/log/mysql/mysql-slow.sql
long_query_time=0
```

`SHOW variables like 'slow_query%';` で確認

### query cache

可能な限り大きくおきたい

```
[mysqld]
query_cache_type = 1
query_cache_limit = 2M
query_cache_size = 32M
```

### innodb buffer 
http://www.slideshare.net/kazeburo/mysql-casual7isucon

```
innodb_buffer_pool_size = 1GB # ディスクイメージをメモリ上にバッファさせる値をきめる設定値
innodb_flush_log_at_trx_commit = 2 # 1に設定するとトランザクション単位でログを出力するが 2 を指定すると1秒間に1回ログファイルに出力するようになる
innodb_flush_method = O_DIRECT # データファイル、ログファイルの読み書き方式を指定する(実験する価値はある)

# バッファプールのウォームアップを有効にする
## デフォルト25%になっているので100%読み込むように。
## 再起動に時間がかかっても構わないので、再起動時に全部読み込むようにしておく
innodb_buffer_pool_dump_pct  = 100
innodb_buffer_pool_dump_at_shutdown= 1
innodb_buffer_pool_load_at_startup = 1
```

### mysql2-cs-bind gem

`mysql2-cs-bind` gemを使うと扱いやすくなる
https://github.com/tagomoris/mysql2-cs-bind

### 参考

[ISUCONの勝ち方 YAPC::Asia Tokyo 2015](http://www.slideshare.net/kazeburo/isucon-yapcasia-tokyo-2015/50)より抜粋

### キャッシュヒット率の確認

キャッシュヒット率が低い場合はかなり効果がある可能性が高い
とりあえず8割ぐらいをバッファプールに設定する(`innodb_buffer_pool_size = 7GB`)


### dbdump

ダンプ作成
```
mysqldump -u user dbname | gzip > dbname.dump.gz 
```

転送
```
scp isucon@13.78.120.149:~/isucon.dump.gz ~  
```

リストア

```
gzcat isucon.dump.gz | mysql -u root isuconp
```
