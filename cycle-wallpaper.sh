#!/bin/bash

WALLPAPER_DIR="$HOME/wallpapers"
STATE_FILE="$HOME/.local/state/wallpaper_index"
ERROR_LOG="$HOME/.local/state/wallpaper_next.log"

export PATH="$PATH:/opt/qt6/bin"

mkdir -p "$(dirname "$STATE_FILE")"

mapfile -t WALLPAPERS < <(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) |
    sort
)

NUM_WALLPAPERS=${#WALLPAPERS[@]}

if (( NUM_WALLPAPERS == 0 )); then
    echo "NUM_WALLPAPERS=0" > "$ERROR_LOG"
    exit 1
fi

if [[ -f "$STATE_FILE" ]]; then
    INDEX=$(<"$STATE_FILE")
    if ! [[ "$INDEX" =~ ^[0-9]+$ ]] ||
       (( INDEX < 1 || INDEX > NUM_WALLPAPERS )); then
        INDEX=1
    fi
else
    INDEX=1
fi
if (( INDEX < NUM_WALLPAPERS )); then
    INDEX=$((INDEX + 1))
else
    INDEX=1
fi


WALLPAPER_PATH="${WALLPAPERS[$((INDEX-1))]}"
URI="file://$WALLPAPER_PATH"

echo "WALLPAPER_PATH=$WALLPAPER_PATH" >> "$ERROR_LOG"

echo "WALLPAPER_PATH=$WALLPAPER_PATH"
echo "URI=$URI"
if [[ "$XDG_SESSION_DESKTOP" == "GNOME" ]]; then
    gsettings set org.gnome.desktop.background picture-uri "$URI"
    gsettings set org.gnome.desktop.background picture-uri-dark "$URI"

elif [[ "$XDG_SESSION_DESKTOP" == "KDE" ]]; then
    qdbus org.kde.plasmashell /PlasmaShell \
        org.kde.PlasmaShell.evaluateScript "
        var ds = desktops();
        for (var i = 0; i < ds.length; i++) {
            ds[i].wallpaperPlugin = 'org.kde.image';
            ds[i].currentConfigGroup =
                ['Wallpaper','org.kde.image','General'];
            ds[i].writeConfig('Image', '$URI');
        }"
fi

echo "$INDEX" > "$STATE_FILE"
