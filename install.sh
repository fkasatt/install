#!/bin/bash

# 必要なパッケージのインストール
sudo pacman -Syu
sudo vi /etc/pacman.conf
sudo pacman -S jq vivaldi wezterm xorg-xwayland qt5-wayland wget man-db man-pages neofetch screenfetch rsync httpie \
	go fzf wl-clipboard typst zathura zathura-pdf-mupdf go base-devel discord krita unzip mako grim slurp \
	noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-dejavu otf-ipafont otf-ipamjfont \
	ufw thunar gvfs gvfs-smb sshfs tumbler wofi ranger tlp \
	lightdm bluez bluez-utils blueman network-manager-applet ufw \
	fcitx5 fcitx5-skk fcitx5-im fcitx5-configtool skk-jisyo 

# Rustのインストール
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install lsd fd-find dusk ripgrep bat cargo-update
source $HOME/.cargo/env

# paruの導入
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
rm -rf paru

# PlemolJPなど日本語フォントを規定のフォントにする
wget https://github.com/yuru7/PlemolJP/releases/download/v1.6.0/PlemolJP_NF_v1.6.0.zip
unzip PlemolJP_NF_v1.6.0.zip
sudo mv PlemolJP_NF_v1.6.0/PlemolJPConsole_NF /usr/share/fonts/
rm -rf PlemolJP_NF_v1.6.0.zip PlemolJP_NF_v1.6.0
sudo mv local.conf /etc/fonts/local.conf
fc-cache -vf

# 環境変数の設定
mkdir -p $HOME/.config
mkdir -p $HOME/.cache
mkdir -p $HOME/.local/share/go
mkdir $HOME/scripts
echo 'export XDG_CONFIG_HOME="${HOME}/.config"' > $HOME/.profile
echo 'export XDG_CACHE_HOME="${HOME}/.cache"' > $HOME/.profile
echo 'export XDG_DATA_HOME="${HOME}/.local/share"' > $HOME/.profile
echo 'export XDG_STATE_HOME="${HOME}/.local/state"' > $HOME/.profile
echo 'export GOPATH="${XDG_DATA_HOME}/go"' > $HOME/.profile
echo 'export PATH="${PATH}:${GOPATH}/bin"' > $HOME/.profile
echo 'export GTK_IM_MODULE=fcitx' > $HOME/.xprofile
echo 'export QT_IM_MODULE=fcitx' > $HOME/.xprofile
echo 'export XMODIFIERS=@im=fcitx' > $HOME/.xprofile
source $HOME/.profile
source $HOME/.xprofile

# gitの設定
git config --global init.defaultBranch main
git config --global user.name "name"
git config --global user.email "mail"

# ファイアウォールの設定
sudo systemctl start ufw.service
sudo systemctl enable ufw.service
sudo ufw enable
sudo ufw default deny

# 時刻の同期設定
sudo vi /etc/systemd/timesyncd.conf
sudo timedatectl set-ntp true

# クリップボード
go install github.com/yory8/clipman@lastest
sudo ln -s $GOPATH/bin/clipman /usr/bin/clipman
cp myclipman $HOME/scripts/

# その他
sudo systemctl enable graphical.target
sudo systemctl enable lightdm

sudo systemctl enable bluetooth
sudo systemctl start bluetooth

sudo systemctl enable tlp

sudo useradd -G video owner

# swayの設定
cp /etc/sway/config $HOME/.config/sway/config
cp -r /etc/xdg/waybar $HOME/.config/
config="${HOME}/.config/sway/config"
cat $config | sed 's/^font /font pango:PlemolJP Console NF 10/' | cat > tmp
cat tmp | sed 's/^set $term .*/set $term wezterm/' | cat > $config
cat config | cat >> $config