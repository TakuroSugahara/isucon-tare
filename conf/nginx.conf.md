<details>

- http://nginx.org/en/docs/ngx_core_module.html
- `/etc/nginx/nginx.conf` に以下を設定。
  - worker_rlimit_nofile は fd 数上限。worker_connections の 3 ~ 4倍推奨
    - cf. http://www.1x1.jp/blog/2013/02/nginx_too_many_open_files_error.html
  - static file の配信( `location ~ ^/(stylesheets|images)/` の部分)
  - unix domain socket ( `server unix:/tmp/unicorn.sock の部分` )
  - tcp_nopush や tcp_nodelay が気になったら  https://heartbeats.jp/hbblog/2012/02/nginx03.htmlや http://blog.nomadscafe.jp/2013/09/benchmark-g-wan-and-nginx.html?_=123 を見る
  - etag はキャッシュしたコンテンツを 200 で返すためのもの http://qiita.com/syokenz/items/e3c8ed4b4a6dfed51a83
  - index は `/` 終端を `/index.html` 終端として扱うための directive。app へ流せてるか確認しながら設定すべき。
  - gzip は ネットワークが圧迫してる時用。
    - http://qiita.com/cubicdaiya/items/2763ba2240476ab1d9dd#gzip_static%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB%E3%81%A7%E5%9C%A7%E7%B8%AE%E6%B8%88%E3%81%BF%E3%81%AE%E3%82%B3%E3%83%B3%E3%83%86%E3%83%B3%E3%83%84%E3%82%92%E9%85%8D%E4%BF%A1%E3%81%99%E3%82%8B
- worker_processes はコア数で設定しても良い(multiproces へ)
- http://lxyuma.hatenablog.com/entry/2015/08/29/200443
- https://gist.github.com/koudaiii/735ef14b83ee31ac0967
- https://heartbeats.jp/hbblog/2012/06/nginx06.html
- https://serverfault.com/questions/763597/why-is-multi-accept-off-as-default-in-nginx
- https://qiita.com/iwai/items/1e29adbdd269380167d2
- http://tetsuyai.hatenablog.com/entry/20111220/1324466655
- https://askubuntu.com/questions/162229/how-do-i-increase-the-open-files-limit-for-a-non-root-user
- https://github.com/firehol/netdata/wiki/high-performance-netdata#2b-increase-open-files-limit-systemd
- https://www.nginx.com/blog/websocket-nginx/
- https://qiita.com/zaru/items/c41072e29b9550c2e6a8
- https://github.com/openresty/lua-resty-redis#set_keepalive

</details>

``` nginx
worker_processes  auto;  # コア数と同じ数まで増やすと良いかも

# nginx worker の設定
worker_rlimit_nofile  4096;  # worker_connections の 4 倍程度（感覚値）
events {
  worker_connections  1024;  # 大きくするなら worker_rlimit_nofile も大きくする（file descriptor数の制限を緩める)
  # multi_accept on;  # error が出るリスクあり。defaultはoff。
  # accept_mutex_delay 100ms;
}

http {
  log_format main '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $request_time';   # kataribe 用の log format
  access_log  /var/log/nginx/access.log  main;   # これはしばらく on にして、最後に off にすると良さそう。
  # access_log  off; 
  
  # 基本設定
  sendfile    on;
  tcp_nopush  on;
  tcp_nodelay on;
  types_hash_max_size 2048;
  server_tokens    off;
  # open_file_cache max=100 inactive=20s; file descriptor のキャッシュ。入れた方が良い。
  
  # proxy buffer の設定。白金動物園が設定してた。
  # proxy_buffers 100 32k;
  # proxy_buffer_size 8k;
  
  # mime.type の設定
  include       /etc/nginx/mime.types;  
 
  # Keepalive 設定
  keepalive_timeout 65;
  keepalive_requests 500;

  # Proxy cache 設定。使いどころがあれば。1mでkey8,000個。1gまでcache。
  proxy_cache_path /var/cache/nginx/cache levels=1:2 keys_zone=zone1:1m max_size=1g inactive=1h;
  proxy_temp_path  /var/cache/nginx/tmp;
  # オリジンから来るCache-Controlを無視する必要があるなら。。。
  #proxy_ignore_headers Cache-Control;
  
  # Lua 設定。
  # Lua の redis package を登録
  lua_package_path /home/isucon/lua/redis.lua;
  init_by_lua_block { require "resty.redis" }

  # unix domain socket 設定1
  upstream app {
    server unix:/run/unicorn.sock;  # systemd を使ってると `/tmp` 以下が使えない。appのディレクトリに`tmp`ディレクトリ作って配置する方がpermissionでハマらずに済んで良いかも。
  }
  
  # 複数serverへ proxy
  upstream app {
    server 192.100.0.1:5000 weight=2;  // weight をつけるとproxyする量を変更可能。defaultは1。多いほどたくさんrequestを振り分ける。
    server 192.100.0.2:5000;
    server 192.100.0.3:5000;
    # keepalive 60; app server への connection を keepalive する。app が対応できるならした方が良い。
  }

  server {
    # HTTP/2 (listen 443 の後ろに http2 ってつけるだけ。ブラウザからのリクエストの場合ssl必須）
    listen 443 ssl http2;
    
    # TLS の設定
    listen 443 default ssl;
    # server_name example.jp;  # オレオレ証明書だと指定しなくても動いた
    ssl on;
    ssl_certificate /ssl/oreore.crt;
    ssl_certificate_key /ssl/oreore.key;
    # SSL Sesssion Cache
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1m;  # cacheする時間。1mは1分。
  
    # reverse proxy の 設定
    location / {
      proxy_pass http://localhost:3000;
      # proxy_http_version 1.1;          # app server との connection を keepalive するなら追加
      # proxy_set_header Connection "";  # app server との connection を keepalive するなら追加
    }

    # Unix domain socket の設定2。設定1と組み合わせて。
    location / {
      proxy_pass http://app;
    }
    
    # For Server Sent Event
    location /api/stream/rooms {
      # "magic trio" making EventSource working through Nginx
      proxy_http_version 1.1;
      proxy_set_header Connection '';
      chunked_transfer_encoding off;
      # These are not an official way
      # proxy_buffering off;
      # proxy_cache off;
      proxy_pass http://localhost:8080;
    }
  
    # For websocket
    location /wsapp/ {
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_pass http://wsbackend;
    }
    
    # Proxy cache
    location /cached/ {
      proxy_cache zone1;
      # proxy_set_header X-Real-IP $remote_addr;
      # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      # proxy_set_header Host $http_host;
      proxy_pass http://localhost:9292/;
      # デフォルトでは 200, 301, 302 だけキャッシュされる。proxy_cache_valid で増やせる。
      # proxy_cache_valid 200 301 302 3s;
      # cookie を key に含めることもできる。デフォルトは $scheme$proxy_host$request_uri;
      # proxy_cache_key $proxy_host$request_uri$cookie_jessionid;
      # レスポンスヘッダにキャッシュヒットしたかどうかを含める
      add_header X-Nginx-Cache $upstream_cache_status;
    }   
    
    # Lua
    location /img {
      # default_type 'image/svg+xml; charset=utf-8';
      content_by_lua_file /home/isucon/lua/img.lua;
    }
    
    # WebDav 設定。使いどころがあれば。
    location /img {
      client_body_temp_path /dev/shm/client_temp;
      dav_methods PUT DELETE MKCOL COPY MOVE;
      create_full_put_path  on;
      dav_access            group:rw  all:r;
     
      # IPを制限する場合
      # limit_except GET HEAD {
      #   allow 192.168.1.0/32;
      #   deny  all;
      # }
    }

    # static file の配信用の root
    root /home/isucon/webapp/public/;

    location ~ .*\.(htm|html|css|js|jpg|png|gif|ico) {
      expires 24h;
      add_header Cache-Control public;
      
      open_file_cache max=100  # file descriptor などを cache

      gzip on;  # cpu 使うのでメリット・デメリット見極める必要あり。gzip_static 使えるなら事前にgzip圧縮した上でそちらを使う。
      gzip_types text/css application/javascript application/json application/font-woff application/font-tff image/gif image/png image/jpeg image/svg+xml image/x-icon application/octet-stream;
      gzip_disable "msie6";
      gzip_static on;  # nginx configure時に --with-http_gzip_static_module 必要
      gzip_vary on;
    }
  }
}
```

## unicorn 側の設定（unix domain socket にするため）

```ruby
# unicorn_config.rb
listen "/run/unicorn.sock"
```

## puma 側の設定(unix domain socket にするため)
起動オプションで `-b [socket]` を指定。
cf. https://github.com/puma/puma

```ruby
$ bundle exec puma -b unix:///var/run/puma.sock
```
