# Termux 用 0xProto Nerd Font セットアップ
#   make / make all       : 未ダウンロード時のみダウンロードし、~/.termux/font.ttf に反映
#   make reset / update   : 強制的に最新版を再ダウンロードして反映
#   make clean            : ダウンロード済みファイルを削除
#   make FONT_FILE=0xProtoNerdFont-Regular.ttf  : Mono 以外のフォントを使う
# 必要: pkg install make curl unzip termux-api

FONT_NAME := 0xProto
FONT_FILE ?= 0xProtoNerdFontMono-Regular.ttf
URL       := https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$(FONT_NAME).zip
CACHE_DIR := $(HOME)/setting/setup/termux/$(FONT_NAME)
ZIP       := $(CACHE_DIR)/$(FONT_NAME).zip
TTF       := $(CACHE_DIR)/$(FONT_FILE)
DEST      := $(HOME)/.termux/font.ttf

.PHONY: all install reset update clean check-deps

all: install

# 内容が変わったときだけコピーして再読み込みする
install: $(TTF)
	@mkdir -p $(dir $(DEST))
	@if cmp -s $(TTF) $(DEST); then \
	  echo "変更なし: $(DEST)"; \
	else \
	  cp $(TTF) $(DEST) && termux-reload-settings && echo "反映しました: $(DEST)"; \
	fi

$(TTF): $(ZIP)
	unzip -o -j $(ZIP) $(FONT_FILE) -d $(CACHE_DIR)
	@touch $@

# 一時ファイルに落としてから置き換え、失敗時に壊れた zip を残さない
$(ZIP): | check-deps
	@mkdir -p $(CACHE_DIR)
	curl -fL -o $@.tmp $(URL)
	@mv $@.tmp $@

check-deps:
	@for c in curl unzip termux-reload-settings; do \
	  command -v $$c >/dev/null || { echo "$$c がありません: pkg install curl unzip termux-api" >&2; exit 1; }; \
	done

# -B で全ターゲットを作り直す (先に削除しないので、ダウンロード失敗時も旧版が残る)
reset:
	$(MAKE) -B all

update: reset

clean:
	rm -f $(ZIP) $(TTF)
