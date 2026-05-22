#!/bin/bash

DEFAULT_PORT_NO="3000"
DEFAULT_DIRECTORY="./"
OPEN_BROWSER=true
#DEFAULT_HOST="0.0.0.0"

NETWORK_TARGETS="en0 en1"

# 終了時の後処理を行う関数
cleanup() {
    # サーバープロセスが存在する場合は終了
    if [ ! -z "$server_pid" ]; then
        kill $server_pid 2>/dev/null
    fi
    exit 0
}

# シグナルハンドラーの設定
trap cleanup INT TERM

usage_exit() {
  echo 1>&2 "Usage: $0 [-p num] [-d dir] [-s]"
  echo 1>&2 "  -s: サイレントモード(ブラウザを開かない)"
  exit 1
}

while getopts 'p:d:sh' OPT
do
  case $OPT in
    p)  PORT_NO=$OPTARG
      ;;
    d)  DIRECTORY=$OPTARG
      ;;
    s)  OPEN_BROWSER=false
      ;;
    h)  usage_exit
      ;;
    \?) usage_exit
      ;;
  esac
done

open_browser() {
  # OSによって適切なコマンドを使用
  case "$(uname)" in
    "Darwin")  # macOS
      open "http://127.0.0.1:$PORT_NO"
      ;;
    "Linux")   # Linux
      if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "http://127.0.0.1:$PORT_NO"
      elif command -v gnome-open >/dev/null 2>&1; then
        gnome-open "http://127.0.0.1:$PORT_NO"
      fi
      ;;
    "MINGW"*)  # Windows
      start "http://127.0.0.1:$PORT_NO"
      ;;
  esac
}

shift $((OPTIND - 1))

if [ "$PORT_NO" = "" ] ; then
  PORT_NO="$DEFAULT_PORT_NO"
fi

if [ "$DIRECTORY" = "" ] ; then
  DIRECTORY="$DEFAULT_DIRECTORY"
fi

for network_target in $NETWORK_TARGETS
do
  ip_address=$(ifconfig ${network_target} | grep 'inet ' | awk '{print $2}')
  if [ ! -z "$ip_address" ] ; then
    echo MyIP is $ip_address
  fi
done

#ruby -rwebrick -e "WEBrick::HTTPServer.new(DocumentRoot: '$DIRECTORY', Host: '$DEFAULT_HOST', Port: $PORT_NO).start"
#ruby -rwebrick -e "WEBrick::HTTPServer.new(DocumentRoot: '$DIRECTORY', Port: $PORT_NO).start"


# バックグラウンドでWEBrickサーバーを起動
ruby -rwebrick -e "WEBrick::HTTPServer.new(DocumentRoot: '$DIRECTORY', Port: $PORT_NO).start" &
server_pid=$!

# サーバーが起動するまで少し待つ
sleep 1

# -s オプションが指定されていない場合はブラウザを開く
if $OPEN_BROWSER; then
  open_browser
fi

# サーバープロセスが終了するまで待機
wait $server_pid
