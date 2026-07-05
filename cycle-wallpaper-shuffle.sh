#!/bin/bash
WALLPAPER_DIR="$HOME/wallpapers"
STATE_FILE="$HOME/.local/state/wallpaper_index"
ERROR_LOG="$HOME/.local/state/wallpaper_shuffle.log"

mkdir -p "$(dirname "$STATE_FILE")"

mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

NUM_WALLPAPERS=${#WALLPAPERS[@]}

if [ "$NUM_WALLPAPERS" -eq 0 ]; then
    echo "NUM_WALLPAPERS=0" > $ERROR_LOG
    exit 1
fi

if [ -f "$STATE_FILE" ]; then
    INDEX=$(cat "$STATE_FILE")
    if ! [[ "$INDEX" =~ ^[0-9]+$ ]] || [ "$INDEX" -ge "$NUM_WALLPAPERS" ]; then
        INDEX=0
    fi
else
    INDEX=0
fi

WALLPAPER_PATH="${WALLPAPERS[$INDEX]}"
URI="file://$WALLPAPER_PATH"
echo "WALLPAPER_PATH=$WALLPAPER_PATH" > $ERROR_LOG

gsettings set org.gnome.desktop.background picture-uri "$URI"
gsettings set org.gnome.desktop.background picture-uri-dark "$URI"

NEXT_INDEX=$(R -q -e "sample.int($NUM_WALLPAPERS+1, 1)-1" | grep "^\[1\]" | cut -d ' ' -f 2)
echo "$NEXT_INDEX" > "$STATE_FILE"
