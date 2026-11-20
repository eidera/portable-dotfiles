#compdef webrick.sh

_webrick.sh() {
  _arguments -s \
    '-p[Port number (default: 3000)]:port number:(3000 8000 8080)' \
    '-d[Document root directory (default: ./)]:directory:_files -/' \
    '-s[Silent mode (do not open browser)]' \
    '-h[Show usage]'
}

_webrick.sh "$@"
