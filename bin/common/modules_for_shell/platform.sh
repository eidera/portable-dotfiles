# platform.sh: 実行環境判定用の共通関数 (source して使う)
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/modules_for_shell/platform.sh"

# Termux 環境なら 0 を返す
# 判定条件は .vimrc の s:is_termux、.zshrc の is_termux と揃えている
is_termux() {
  [[ -n "${TERMUX_VERSION:-}" ]] \
    || [[ "${PREFIX:-}" == *com.termux* ]] \
    || [[ -d /data/data/com.termux ]]
}
