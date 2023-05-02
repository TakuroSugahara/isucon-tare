# nginx のログを削除
# TODO: 起動しているservicedの変更
SERVICE=isu-go.service

NGINX_LOG=/var/log/nginx/access.log
NGINX_TMP_LOG=/tmp/access.txt
MYSQL_LOG=/var/log/mysql/mysqld-slow.log
MYSQL_TMP_LOG=/tmp/digest.txt

echo ":: CLEAR LOGS       ====>"
sudo truncate -s 0 -c NGINX_LOG
sudo truncate -s 0 -c MYSQL_LOG

# 各種サービスの再起動
echo
echo ":: RESTART SERVICES ====>"

# TODO: serviceのbuildが必要, buildをどのようにしているか調べる
# ex: cd webaap/golang && make && cd ..
sudo systemctl daemon-reload
sudo systemctl restart SERVICE

sudo systemctl restart mysql
sudo systemctl restart nginx

sleep 5
echo ":: PLEASE RUN BENCH ====>"
read

echo
echo ":: ACCESS LOG       ====>"
# TODO: リクエストpathに合わせて変更する, /posts/[:id]などをまとめたりする
# NOTE: alpのバージョンによってoptionが異なるので注意
# sudo cat NGINX_LOG | alp --sum -r --aggregates "/posts/[0-9]+,/@\w+","/image/[0-9]+,/@\w" > NGINX_TMP_LOG
cat NGINX_TMP_LOG

echo
echo ":: SLOW LOG       ====>"
pt-query-digest MYSQL_LOG > MYSQL_TMP_LOG
cat MYSQL_TMP_LOG


