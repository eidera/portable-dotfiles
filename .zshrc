# users generic .zshrc file for zsh(1)
# vim: fdm=marker :

## Option {{{
setopt IGNORE_EOF # ^Dでログアウトしないようにする

# bindkey -vの時にESCの反応が遅い対応
KEYTIMEOUT=1 # defaultは40[msec]
# }}}
## Environment variable configuration {{{
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac
# }}}
## Path {{{
typeset -U PATH path # PATHの重複を防ぐ
## various env path setting {{{
export GOPATH="${HOME}/.go"
#}}}
## path setting
case ${UID} in
0) # root
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:${PATH}
    ;;
*)
    # 全環境共通
    NEW_PATH=/usr/local/nvim/bin:/usr/local/bin:/usr/local/kotlin-native/bin

    # 環境依存system系
    case "$(uname -s)" in
      Darwin)
        NEW_PATH=/opt/homebrew/opt/libpq/bin:/opt/homebrew/opt/php@8.0/bin:/usr/local/Cellar/libpq/14.4/bin/:/opt/homebrew/bin:${NEW_PATH}:${HOME}/build/others/jetbrains/bin
      ;;
      Linux)
        # なし
      ;;
    esac

    # 全環境共通home系
    NEW_PATH=${HOME}/build/local/bin:${HOME}/bin:${HOME}/bin/personal:${GOPATH}/bin:${HOME}/.fzf/bin:${NEW_PATH}

    # 環境依存home系
    case "$(uname -s)" in
      Darwin)
        NEW_PATH=${HOME}/bin/mac:${HOME}/build/others/jetbrains/bin:${NEW_PATH}
      ;;
      Linux)
        NEW_PATH=${HOME}/bin/ubuntu:${NEW_PATH}
      ;;
    esac

    # 最後にカレントを入れる(全環境共通)
    # ログインシェルまたは screen 環境では PATH を完全に定義
    if [[ -o login ]] || [ "true" = "$SCREEN" ]; then
      export PATH=${NEW_PATH}:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:.
    else
      export PATH=${NEW_PATH}:${PATH}:.
    fi
    ;;
esac

## load library path
export LD_LIBRARY_PATH=/usr/local/lib
# }}}
# Prompt {{{
autoload colors; colors
autoload vcs_info
zmodload zsh/datetime
zmodload zsh/mathfunc

# --- vcs_info 設定 ---
zstyle ":vcs_info:*"       enable            git
zstyle ":vcs_info:git:*"   check-for-changes true
zstyle ":vcs_info:git:*"   formats           "[%b : %r] %F{magenta}%c%u%f"
zstyle ":vcs_info:git:*"   actionformats     "[%b : %r] %F{magenta}%c%u<%a>%f"
zstyle ":vcs_info:git:*"   unstagedstr       "M"
zstyle ":vcs_info:git:*"   stagedstr         "C"

# --- preexec / precmd ---
preexec() {
  _cmd_start=$EPOCHREALTIME
}

precmd() {
  # 実行時間の計算
  if [[ -n $_cmd_start ]]; then
    local elapsed=$(( EPOCHREALTIME - _cmd_start ))
    local total_sec=$(( int(elapsed) ))
    local ms=$(( int((elapsed - total_sec) * 1000) ))
    local h=$(( total_sec / 3600 ))
    local m=$(( total_sec % 3600 / 60 ))
    local s=$(( total_sec % 60 ))
    _cmd_elapsed="${h}h-${m}m-${s}s-${ms}ms ${total_sec}s"
  else
    _cmd_elapsed=""
  fi
  unset _cmd_start

  # git情報をキャッシュ
  vcs_info
  if [[ -z $vcs_info_msg_0_ ]]; then
    _git_info=""
    return
  fi

  local extras=""
  git status -s 2>/dev/null | grep -q "^??" && extras+="?"

  if [[ -n $(git remote 2>/dev/null) ]]; then
    local head=$(git rev-parse HEAD 2>/dev/null)
    git rev-parse --remotes 2>/dev/null | grep -qF "$head" || extras+="P"
  fi

  if git stash list 2>/dev/null | grep -q .; then
    [[ -n $extras ]] && extras+=" "
    extras+="{Has Stash}"
  fi

  local vcs_base="${vcs_info_msg_0_%\%f}"

  if [[ $vcs_base == *"%F{magenta}" && -z $extras ]]; then
    _git_info=" ${vcs_base% %F\{magenta\}}"
  else
    _git_info=" ${vcs_base}${extras}%f"
  fi
}

# --- プロンプト設定 ---
setopt prompt_subst

local sc='%0(?|%{${fg[green]}%}|%{${fg[red]}%})'
local git_str="%{${fg[yellow]}%}"'${_git_info}'"%{${reset_color}%}"
local date_str="%{${fg[green]}%}%D %*%{${reset_color}%}"
local exec_time="%{${fg[cyan]}%}"'[${_cmd_elapsed}]'"%{${reset_color}%}"

PROMPT="$sc╭─%{${reset_color}%} %{${fg[green]}%}%m(\`whoami\`)[%c]%{${reset_color}%}$git_str $date_str $exec_time
$sc╰─❯%{${reset_color}%} "

RPROMPT="%{${fg[yellow]}%}%{${bg[black]}%}[%/]%{${reset_color}%}"

[[ $SCREEN == "true" ]] && PROMPT=$'\033k%~\033\134'$PROMPT
# }}}
## Useful setting {{{
setopt auto_cd
setopt auto_pushd
setopt correct
setopt list_packed
setopt noautoremoveslash
setopt nolistbeep

## Keybind configuration {{{
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# vi like keybind {{{
bindkey -v
bindkey -M viins '\er' history-incremental-pattern-search-forward
bindkey -M viins '^?'  backward-delete-char
bindkey -M viins '^A'  beginning-of-line
bindkey -M viins '^B'  backward-char
bindkey -M viins '^D'  delete-char-or-list
bindkey -M viins '^E'  end-of-line
bindkey -M viins '^F'  forward-char
bindkey -M viins '^G'  send-break
bindkey -M viins '^H'  backward-delete-char
bindkey -M viins '^K'  kill-line
bindkey -M viins '^P'  history-beginning-search-backward-end
bindkey -M viins '^N'  history-beginning-search-forward-end
bindkey -M viins '^R'  history-incremental-pattern-search-backward
bindkey -M viins '^U'  backward-kill-line
bindkey -M viins '^W'  backward-kill-word
bindkey -M viins '^Y'  yank

bindkey -r '^O' # self-insert を廃止

# viモード時にbuffer stack(コマンドラインスタック)を使用できるように設定する(emacsモードだとESC-Q)
setopt noflowcontrol
bindkey '^Q' push-line-or-edit
# }}}
# }}}
## Command history configuration
HISTFILE=${HOME}/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history        # share command history data

## Completion configuration
fpath=(${HOME}/.zsh/functions/Completion ${HOME}/.zsh/completions ${fpath})
autoload -U compinit
compinit

## zsh editor
autoload zed

## Command Logger: 実行したコマンドとその結果をクリップボードにコピーしつつ、結果は標準出力にも表示する {{{
function commandLogger() {
    # 実行時のコマンド名を取得
    local cmd_name="${funcstack[1]:-$0}"
    cmd_name=$(basename "$cmd_name")

    # オプションと実行コマンドを格納する変数
    local show_timestamp=false
    local show_time=false

    # オプションの解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--timestamp)
                show_timestamp=true
                shift
                ;;
            --time)
                show_time=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # コマンドが空の場合は使い方を表示
    if (( $# == 0 )); then
        echo "Usage: $cmd_name [-t|--timestamp] [--time] command [args...]"
        return 1
    fi

    # コマンドライン全体を1つの文字列として結合
    local cmd=""
    for arg in "$@"; do
        if [[ -z "$cmd" ]]; then
            cmd="$arg"
        else
            # スペースを含む引数は適切にクォート
            if [[ "$arg" =~ [[:space:]] ]]; then
                cmd="$cmd '$arg'"
            else
                cmd="$cmd $arg"
            fi
        fi
    done

    # 実行時間計測の準備
    local start_time=""
    local end_time=""
    local elapsed=""
    local time_str=""
    local output=""

    # コマンドを1回だけ実行して結果を保存
    if $show_time; then
        start_time=$(date +%s.%N)
        output=$(eval "$cmd")
        end_time=$(date +%s.%N)
        elapsed=$(echo "$end_time - $start_time" | bc)
        elapsed=$(printf "%.2f" $elapsed)

        # 秒数を時分秒に変換
        local hours=$(echo "$elapsed/3600" | bc)
        local mins=$(echo "($elapsed-$hours*3600)/60" | bc)
        local secs=$(echo "$elapsed-$hours*3600-$mins*60" | bc)
        secs=$(printf "%.2f" $secs)

        if (( ${hours%.*} > 0 )); then
            time_str="${hours%.*}h${mins%.*}m${secs}s"
        elif (( ${mins%.*} > 0 )); then
            time_str="${mins%.*}m${secs}s"
        else
            time_str="${secs}s"
        fi
    else
        output=$(eval "$cmd")
    fi

    # クリップボードへコピー
    if $show_timestamp || $show_time; then
        local timestamp=""
        local suffix=""

        if $show_timestamp; then
            timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            suffix="# $timestamp"
        fi

        {
            echo "$ $cmd    $suffix"
            echo "$output"

            if $show_time; then
                echo "Time: ${elapsed}s ($time_str)"
            fi
        } | pbcopy
    else
        {
            echo "$ $cmd"
            echo "$output"
        } | pbcopy
    fi

    # 標準出力に表示
    echo "$output"
    if $show_time; then
        echo "Time: ${elapsed}s ($time_str)" >&2
    fi
}
alias cl='commandLogger'

# 補完設定
function _commandLogger() {
    local context state state_descr line
    typeset -A opt_args

    # clコマンドのオプション定義
    _arguments \
        '(-t --timestamp)'{-t,--timestamp}'[Add timestamp]' \
        '--time[Show execution time]' \
        '*:: :->command' \
        && return 0

    # オプション以外の引数の補完
    case $state in
        command)
            # 通常のコマンド補完を実行
            _normal
            ;;
    esac
}

# 補完の登録
compdef _commandLogger commandLogger
compdef _commandLogger cl

function wrap-in-cl() {
    BUFFER="cl '$BUFFER'"
    CURSOR=$#BUFFER
}
zle -N wrap-in-cl

# Ctrl+tにバインド
bindkey '^t' wrap-in-cl
## }}}
# 指定したファイルが存在するまでディレクトリを遡ってcdする {{{
# cdf - cd to the nearest ancestor directory containing a specific file
#
# Usage: cdf <filename>
#   Searches from the current directory up to / for <filename>.
#   If found in a parent directory, cd to that directory.
#   If found in the current directory, do nothing.

cdf() {
  if [[ -z "$1" ]]; then
    echo "Usage: cdf <filename>" >&2
    return 1
  fi

  local target="$1"
  local dir="$PWD"

  if [[ -e "$dir/$target" ]]; then
    echo "'$target' is in the current directory." >&2
    return 0
  fi

  while true; do
    dir="${dir%/*}"
    [[ -z "$dir" ]] && dir="/"

    if [[ -e "$dir/$target" ]]; then
      cd "$dir" || return 1
      echo "$dir" >&2
      return 0
    fi

    [[ "$dir" == "/" ]] && break
  done

  echo "'$target' not found." >&2
  return 1
}
# }}}
# 長い処理時間がかかった場合に処理時間を表示する {{{
#REPORTTIME=30	# 30 sec

# 長い処理時間がかかった場合に通知センター又はgrowlに通知する(3秒)

local COMMAND=""
local COMMAND_TIME=""
local PREVIOUS_COMMAND_TIME=""
precmd() {
  if [ "$COMMAND_TIME" -ne "0" ] ; then
    local d=`date +%s`
    d=`expr $d - $COMMAND_TIME`
    if [ "$d" -ge "3" ] ; then
      COMMAND="$COMMAND "
      case "$(uname -s)" in
        Linux) # linux
          notify-send -t 5000 "$COMMAND" "DONE! $d [sec]\nzsh on iTerm"
        ;;
      esac
      case "$(uname -s)" in
        Darwin) # mac
          terminal-notifier -title "$COMMAND" -subtitle "DONE! $d [sec]" -message "zsh on iTerm"
        ;;
      esac
    fi
  fi
  COMMAND="0"
  COMMAND_TIME="0"
}
preexec () {
  COMMAND="${1}"
  COMMAND_TIME=`date +%s`
  PREVIOUS_COMMAND_TIME="${COMMAND_TIME}"
}
# }}}
# }}}
## Extension setting {{{
case "$(uname -s)" in
  Linux) # linux
    export EDITOR="/usr/bin/vi"
  ;;
esac
case "$(uname -s)" in
  Darwin) # mac
    export EDITOR="/usr/local/bin/vi"
  ;;
esac

# fzf {{{
## C-Rの履歴をfzfで選択 {{{
function fzf-select-history() {
    BUFFER=$(fc -l -r -n 1 | fzf --prompt '[Command HISTORY] ')
    CURSOR=$#BUFFER
    zle redisplay
}

zle -N fzf-select-history
bindkey '^r' fzf-select-history
## }}}
## C-o C-fでファイルを複数選択 {{{
# git管理下の場合はgit statusで出力されるファイルが対象。
# git管理外の場合はカレントディレクトリのみが対象。
function fzf-select-file() {
    local source_files=$(git status --short)
    if [ ! -n "$source_files" ] ; then
      # git変更なし
      local source_files=$(ls)
      if [ ! -n "$source_files" ] ; then
        return
      fi
      BUFFER="$BUFFER$(echo $source_files | fzf --prompt '[current dir file] ' --preview 'bat --color=always --style=header,grid,numbers --line-range=:100 $(echo {} | sed -e "s/[*/]$//")' | /usr/bin/awk -F ' ' '{print $NF}')"
    else
      BUFFER="$BUFFER$(echo $source_files | fzf --prompt '[git status file] ' --preview 'result=$(git diff $(echo {} | sed -e "s/^ *[^ ][^ ]*//")) && if [ -n "$result" ] ; then echo $result ; else bat --color=always --style=header,grid,numbers --line-range=:100 $(echo {} | sed -e "s/^ *[^ ][^ ]*//") ; fi' | /usr/bin/awk -F ' ' '{print $NF}')"
    fi

    CURSOR=$#BUFFER

    zle redisplay
}
zle -N fzf-select-file
bindkey "^o^f" fzf-select-file
## }}}
## C-o C-bでbranch一覧を表示 {{{
function fzf-select-branch() {
    local branches=$(git branch 2> /dev/null)
    if [ ! -n "$branches" ] ; then
      return
    fi

    BUFFER="$BUFFER$(echo $branches | fzf --prompt '[GIT branch] ' | /usr/bin/awk -F ' ' '{print $NF}')"
    CURSOR=$#BUFFER
    zle redisplay
}
zle -N fzf-select-branch
bindkey "^o^b" fzf-select-branch
## }}}
## C-o C-p pでbmのブックマークのパスを取得 {{{
function fzf-select-bookmark() {
    local bookmarks=$(bm list 2> /dev/null)
    if [ ! -n "$bookmarks" ] ; then
      return
    fi

    BUFFER="$BUFFER$(echo $bookmarks | fzf --prompt '[SELECT BOOKMARK: path] ' | sed 's/^[^:]*: //')"
    CURSOR=$#BUFFER
    zle redisplay
}
zle -N fzf-select-bookmark
bindkey "^o^pp" fzf-select-bookmark
## }}}
## C-o C-p iでbmのブックマークのidentityを取得 {{{
function fzf-select-identity() {
    local bookmarks=$(bm list 2> /dev/null)
    if [ ! -n "$bookmarks" ] ; then
      return
    fi

    BUFFER="$BUFFER$(echo $bookmarks | fzf --prompt '[SELECT BOOKMARK: identity] ' | /usr/bin/awk -F ' ' '{print $1}')"
    CURSOR=$#BUFFER
    zle redisplay
}
zle -N fzf-select-identity
bindkey "^o^pi" fzf-select-identity
## }}}
## C-o C-oでbmのブックマークをオープン {{{
# ディレクトリだったらcd
# ファイルだったらgvimでオープン
function fzf-open-bookmark() {
    local bookmarks=$(bm list 2> /dev/null)
    if [ ! -n "$bookmarks" ] ; then
      return
    fi

    local target_path="$(echo $bookmarks | fzf --prompt '[OPEN BOOKMARK] ' | sed 's/^[^:]*: //')"
    if [ ! -n "$target_path" ] ; then
      return
    fi

    if [ -f "$target_path" ]; then
      BUFFER="gvim ${(q)target_path}"
    fi
    if [ -d "$target_path" ]; then
      BUFFER="cd ${(q)target_path}"
    fi
    #zle reset-prompt
    zle accept-line
}
zle -N fzf-open-bookmark
bindkey "^o^o" fzf-open-bookmark
## }}}
## C-o C-p fでカレントディレクトリ以下のファイルパスを取得 {{{
function fzf-open-under-file() {
    # ディレクトリ移動と同様にfind使おうと思ったが良く分からない挙動のデバッグする時間がなかったのでagを使う方式で一旦実装
    local target_path="$(lt -f | fzf --prompt '[SELECT FILEPATH] ' --preview 'bat --color=always --style=header,grid,numbers --line-range=:100 {}')"
    if [ ! -n "$target_path" ] ; then
      return
    fi

    BUFFER="$BUFFER$target_path"
    CURSOR=$#BUFFER
    zle redisplay
}
zle -N fzf-open-under-file
bindkey "^o^pf" fzf-open-under-file
## }}}
## C-o C-p dでカレントディレクトリ以下のディレクトリに移動 {{{
function fzf-open-under-directory() {
    local target_path="$(lt -d | fzf --prompt '[OPEN DIR] ')"
    if [ ! -n "$target_path" ] ; then
      return
    fi
    BUFFER="cd $target_path"
    zle accept-line
}
zle -N fzf-open-under-directory
bindkey "^o^pd" fzf-open-under-directory
# }}}
## C-o C-p rfでプロジェクトルート以下のファイルパスを取得 {{{
function fzf-open-project-under-file() {
    # ディレクトリ移動と同様にfind使おうと思ったが良く分からない挙動のデバッグする時間がなかったのでagを使う方式で一旦実装
    local target_path="$(lt -pf | fzf --prompt '[SELECT PROJECT FILEPATH] ' --preview 'bat --color=always --style=header,grid,numbers --line-range=:100 {}')"
    if [ ! -n "$target_path" ] ; then
      return
    fi

    BUFFER="$BUFFER$target_path"
    CURSOR=$#BUFFER
    zle redisplay
}
zle -N fzf-open-project-under-file
bindkey "^o^prf" fzf-open-project-under-file
## }}}
## C-o C-p rdでプロジェクトルート以下のディレクトリに移動 {{{
function fzf-open-project-under-directory() {
    local target_path="$(lt -pd | fzf --prompt '[OPEN PROJECT DIR] ')"
    if [ ! -n "$target_path" ] ; then
      return
    fi
    BUFFER="cd $target_path"
    zle accept-line
}
zle -N fzf-open-project-under-directory
bindkey "^o^prd" fzf-open-project-under-directory
# }}}
# }}}
# extended cd {{{
# ref: https://qiita.com/arks22/items/8515a7f4eab37cfbfb17
export EXTENDED_CD_HISTORY_PATH="$HOME/.extended_cd.log"

function chpwd() {
  extended_cd_add_log
}

function extended_cd_add_log() {
  local i=0
  cat "$EXTENDED_CD_HISTORY_PATH" | while read line; do
    (( i++ ))
    if [ i = 30 ]; then
      sed -i -e "30,30d" "$EXTENDED_CD_HISTORY_PATH"
    elif [ "$line" = "$PWD" ]; then
      sed -i -e "${i},${i}d" "$EXTENDED_CD_HISTORY_PATH"
    fi
  done
  echo "$PWD" >> "$EXTENDED_CD_HISTORY_PATH"
}

function extended_cd() {
  if [ $# = 0 ]; then
    # 環境によってはgtacではなく `tac` や `tail -r`
    cd "$(gtac "$EXTENDED_CD_HISTORY_PATH" | fzf)"
  elif [ $# = 1 ]; then
    cd $1
  else
    echo "extended_cd: too many arguments"
  fi
}

_extended_cd() {
  _files -/
}

compdef _extended_cd extended_cd

[ -e "$EXTENDED_CD_HISTORY_PATH" ] || touch "$EXTENDED_CD_HISTORY_PATH"

alias c="extended_cd"
# }}}
## terminal configuration {{{
#
case "${TERM}" in
screen)
    TERM=xterm
    ;;
esac

case "${TERM}" in
xterm|xterm-color)
    #export LSCOLORS=exfxcxdxbxegedabagacad
    #export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
kterm-color)
    stty erase '^H'
    #export LSCOLORS=exfxcxdxbxegedabagacad
    #export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
kterm)
    stty erase '^H'
    ;;
cons25)
    unset LANG
    #export LSCOLORS=ExFxCxdxBxegedabagacad
    #export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=;34;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
jfbterm-color)
    #export LSCOLORS=gxFxCxdxBxegedabagacad
    #export LS_COLORS='di=01;36:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=;36;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
esac

# set terminal title including current directory
#
case "${TERM}" in
xterm|xterm-color|kterm|kterm-color)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# }}}
## Alias configuration {{{
# expand aliases before completing
setopt complete_aliases     # aliased ls needs if file/dir completions work

alias szshrc="source ~/.zshrc"
alias where="command -v"

# ls関連 {{{
case "${OSTYPE}" in
freebsd*|darwin*)
    alias ls="ls -F"
    ;;
linux*)
    alias ls="ls -F --color=auto"
    ;;
esac

alias la="ls -a"
alias ll="ls -l"
alias lla="ls -la"
alias lsd='ls | grep / ; ls | grep @'
alias lad='la | grep / ; ls | grep @'
alias lsf='ls | grep -v /'
alias laf='la | grep -v /'
alias llo="ll -O"
# }}}

alias du="du -h"
alias df="df -h"

alias su="su -l"

alias mv='mv -i'       # no spelling correction on mv
alias cp='cp -i'       # no spelling correction on cp
alias rm='rm -i'       # no spelling correction on rm

alias -g @P='| fzfcut'

alias projectlocal="vi -c 'silent call MakeProjectFileForProjectlocal() | quit'"
alias pvi='vi -c "set paste"'

case "$(uname -s)" in
  Darwin)
    alias fcd='cd `fcd.sh`'
  ;;
  Linux)
    # なし
  ;;
esac

delBackupFiles() {
  local recursive=false
  local target_dir="."

  for arg in "$@"; do
    case "$arg" in
      -r) recursive=true ;;
      -*) echo "不明なオプション: $arg" >&2; return 1 ;;
      *) target_dir="$arg" ;;
    esac
  done

  if [[ ! -d "$target_dir" ]]; then
    echo "ディレクトリが見つかりません: $target_dir" >&2
    return 1
  fi

  local dir="${target_dir%/}"
  local files
  if $recursive; then
    files=("${dir}"/**/*~(N) "${dir}"/**/.*~(N))
  else
    files=("${dir}"/*~(N) "${dir}"/.*~(N))
  fi

  (( ${#files} == 0 )) && echo "対象ファイルなし" && return
  print -l $files
  read "ans?削除しますか? [y/N]: "
  [[ $ans == [yY] ]] && rm -f $files && echo "削除しました。" || echo "キャンセルしました。"
}

delMacMetadata() {
  local files=("${(@f)$(find . \( -name "._*" -o -name ".DS_Store" \) -type f)}")
  (( ${#files} == 0 )) || [[ -z "$files[1]" ]] && echo "対象ファイルなし" && return
  print -l $files
  echo ""
  read "answer?本当に削除しますか? (y/N): "
  if [[ "$answer" == "y" ]]; then
    find . \( -name "._*" -o -name ".DS_Store" \) -type f -print0 | xargs -0 rm -v
    echo "削除完了！"
  else
    echo "キャンセルしました"
  fi
}

alias mu='echo 1>&2 "1又は複数のURLを含む文字列をペーストして<C-d>を入力してください。全てのURLをデフォルトブラウザで開きます。" ; cat | multiple_url_opener.rb'

alias cdp='cdf .projectfile'

# Mac用 {{{
case "$(uname -s)" in
  Darwin) # mac
    #alias vi='vi -c "set bg=light"'		# for Solarized on iTerm2
    alias vi='/Applications/MacVim.app/Contents/MacOS/Vim -c "set bg=light"'
    alias gvim='/Applications/MacVim.app/Contents/bin/mvim --remote-tab'
    alias gitx="open -a gitx"
    alias yoink='open -a Yoink'
  ;;
esac
# }}}

## other settings {{{
eval "$(direnv hook zsh)"

if [ -e ~/.local/bin/mise ] ; then
  eval "$(~/.local/bin/mise activate zsh)"
fi

export FZF_DEFAULT_OPTS='--reverse --multi --cycle --tiebreak=index --bind=ctrl-a:toggle-all'
## }}}

# 各環境用の設定相違点の吸収用
if [ -e ~/.zsh_local/local.zshrc ] ; then
  source ~/.zsh_local/local.zshrc
fi
