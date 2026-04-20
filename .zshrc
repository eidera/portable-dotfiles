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
    NEW_PATH=${HOME}/build/local/bin:${HOME}/bin:${GOPATH}/bin:${HOME}/.fzf/bin:${NEW_PATH}

    # 環境依存home系
    case "$(uname -s)" in
      Darwin)
        NEW_PATH=${HOME}/build/others/jetbrains/bin:${NEW_PATH}
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
case "${TERM}" in
screen)
    TERM=xterm
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

alias projectlocal="vi -c 'silent call MakeProjectFileForProjectlocal() | quit'"
alias pvi='vi -c "set paste"'

## other settings {{{
eval "$(direnv hook zsh)"
eval "$(~/.local/bin/mise activate zsh)"
export FZF_DEFAULT_OPTS='--reverse --multi --cycle --tiebreak=index --bind=ctrl-a:toggle-all'
## }}}

# 各環境用の設定相違点の吸収用
if [ -e ~/.zsh_local/local.zshrc ] ; then
  source ~/.zsh_local/local.zshrc
fi
