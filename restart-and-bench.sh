# nginx のログを削除
# TODO: 起動しているservicedの変更

NGINX_LOG=/var/log/nginx/access.log
NGINX_TMP_LOG=/tmp/access.txt
NGINX_ERROR_LOG=/var/log/nginx/error.log
MYSQL_LOG=/var/log/mysql/mysql-slow.log
MYSQL_ERROR_LOG=/var/log/mysql/error.log
MYSQL_TMP_LOG=/tmp/digest.txt

echo ":: CLEAR LOGS       ====>"
sudo truncate -s 0 -c $NGINX_ERROR_LOG
sudo truncate -s 0 -c $MYSQL_ERROR_LOG
sudo truncate -s 0 -c $NGINX_LOG
sudo truncate -s 0 -c $MYSQL_LOG

# 各種サービスの再起動
echo
echo ":: RESTART SERVICES ====>"

cd "$HOME/private_isu/webapp/golang" && make
cd "$HOME/private_isu"

sudo systemctl daemon-reload
sudo systemctl restart isu-go

sudo systemctl restart mysql
sudo systemctl restart nginx

sleep 5
echo ":: PLEASE RUN BENCH ====>"
read _

echo
echo ":: ACCESS LOG       ====>"
# TODO: リクエストpathに合わせて変更する, /posts/[:id]などをまとめたりする
sudo cat $NGINX_LOG | alp json --sort sum -r -m "/posts/[0-9]+,/@\w+","/image/[0-9]+,/@\w" -o "count,1xx,2xx,3xx,4xx,5xx,method,uri,min,max,sum,avg,min_body,max_body,avg_body" > $NGINX_TMP_LOG

cat $NGINX_TMP_LOG

echo
echo ":: SLOW LOG       ====>"
sudo pt-query-digest $MYSQL_LOG > $MYSQL_TMP_LOG
cat $MYSQL_TMP_LOG
