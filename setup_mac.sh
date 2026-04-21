#! /bin/sh

TOOLS_DIR="$HOME/tools"

setup_brew() {
  brew install terminal-notifier the_silver_searcher ripgrep jq yq jc tree direnv w3m wget bat nkf telnet gawk coreutils gh
  brew install --cask aquaskk keepassxc shifty stay swift-shift hammerspoon visual-studio-code
}

setup_fzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
}

setup_git() {
  git config --global core.excludesfile ~/.gitignore_global
  git config --global init.defaultBranch main
  git config --global pull.rebase false

  local git_format="%Cgreen%h %Creset%cd(%cr) %G? %Cblue%an <%ae> %Creset%s %b %Cred%d"
  local git_date_format="%Y-%m-%d %H:%M:%S %z"
  local git_common_options="--date=format:'"${git_date_format}"' --decorate=short --pretty=format:'"${git_format}"'"

  git config --global alias.sl "log --oneline ${git_common_options}"
  git config --global alias.sls "log --oneline --name-status ${git_common_options}"
  git config --global alias.graph "log --graph ${git_common_options}"
  git config --global alias.graphs "log --graph --name-status ${git_common_options}"
  git config --global alias.agraph "log --graph --all ${git_common_options}"
  git config --global alias.agraphs "log --graph --all --name-status ${git_common_options}"

  git config --global alias.all-fetch '!git fetch --all --prune'
  git config --global alias.force-pull '!git fetch --all --prune && git reset --hard origin/$(git symbolic-ref --short HEAD)'
  git config --global alias.cancel-conflict-by-stashpop '!git checkout --ours . && git reset && git checkout .'

  git config --global alias.word-diff '!git diff --word-diff-regex="\w+"'

  git config --global core.pager "LESSCHARSET=utf-8 less"

  git config --global core.quotepath false # for mac
}

setup_vscode() {
  code --install-extension vscodevim.vim
  code --install-extension k--kato.intellij-idea-keybindings
  code --install-extension generalov.open-in-editor-vscode
  code --install-extension ryanolsonx.solarized
  code --install-extension janisdd.vscode-edit-csv
  code --install-extension mechatroner.rainbow-csv
  code --install-extension ms-vsliveshare.vsliveshare
  code --install-extension MS-CEINTL.vscode-language-pack-ja
  code --install-extension grapecity.gc-excelviewer
  code --install-extension streetsidesoftware.code-spell-checker
  code --install-extension eamodio.gitlens
  code --install-extension wmaurer.change-case
  code --install-extension asuka.insertnumbers
  code --install-extension jebbs.plantuml
  code --install-extension arjun.swagger-viewer
  code --install-extension asciidoctor.asciidoctor-vscode

  code --install-extension VisualStudioExptTeam.vscodeintellicode
  code --install-extension christian-kohler.path-intellisense
  code --install-extension oderwat.indent-rainbow
  code --install-extension MariusAlchimavicius.json-to-ts
  code --install-extension redhat.vscode-yaml
  code --install-extension bierner.markdown-mermaid
}

setup_mise() {
  curl https://mise.run | sh
}

setup_mac_terminal() {
  mkdir -p "${TOOLS_DIR}"
  cd "${TOOLS_DIR}"

  git clone https://github.com/tomislav/osx-terminal.app-colors-solarized solarized.git

  cd -
}

setup_font() {
  mkdir -p "${TOOLS_DIR}"
  cd "${TOOLS_DIR}"

  local latest_tag=$(curl -s https://api.github.com/repos/0xType/0xProto/releases/latest | jq -r '.tag_name')
  local file="0xProto_$(echo $latest_tag | tr '.' '_').zip"
  local url="https://github.com/0xType/0xProto/releases/download/${latest_tag}/${file}"
  echo "$url"
  curl -L -O "$url"

  cd -
}

setup_skk_dict() {
  mkdir -p "${TOOLS_DIR}"
  cd "${TOOLS_DIR}"

  git clone https://github.com/skk-dev/dict.git skk-dict
}

################################################################################
# main

setup_brew
setup_fzf
setup_git
setup_vscode
setup_font
setup_mac_terminal

# 以下必要に応じてコメントアウト解除
#setup_skk_dict
#setup_mise
