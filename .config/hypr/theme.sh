#!/bin/bash
WALLPAPER_DIR="$HOME/code/imgrepo/wallpaper"
STARTUP_DIR="$HOME/.config/hypr/wallpaper.conf"
OBSIDIAN_THEME_DIR="$HOME/obisidan/.obsidian/themes/Minimal"
STYLE_SETTINGS_DIR="$HOME/obsidian/.obsidian/plugins/obsidian-style-settings"
ICON_DIR="$HOME/.local/share/icons/wallpapers"

# check dependencies
for cmd in rofi awww wal python3 oomox-cli jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "$cmd could not be found, please install it first."
    exit 1
  fi
done

# ask user to choose theme mode first
THEME_MODE=$(echo -e "Light\nDark" | rofi -dmenu -p "Choose theme mode")
if [ -z "$THEME_MODE" ]; then
  exit 1
fi
THEME_MODE=$(echo "$THEME_MODE" | tr '[:upper:]' '[:lower:]')

# generate wallpaper icons for rofi
mkdir -p "$ICON_DIR"
wallpapers=($(ls "$WALLPAPER_DIR"))
for wallpaper in "${wallpapers[@]}"; do
  ln -sf "$WALLPAPER_DIR/$wallpaper" "$ICON_DIR/$wallpaper.png"
done

# list wallpapers in rofi
rofi_list=""
for wallpaper in "${wallpapers[@]}"; do
  rofi_list+="$wallpaper\0icon\x1f$ICON_DIR/$wallpaper.png\n"
done

WALLPAPER=$(echo -en "$rofi_list" | rofi -dmenu -p "Select a wallpaper" -show-icons -icon-theme "Papirus")
WALLPAPER_PATH="$WALLPAPER_DIR/$WALLPAPER"
if [ -z "$WALLPAPER" ]; then
  exit 1
fi

# set wallpaper + generate pywal theme
awww img "$WALLPAPER_PATH"

# apply appropriate theme based on user selection
if [ "$THEME_MODE" = "light" ]; then
  wal -i "$WALLPAPER_PATH" -n -l
else
  wal -i "$WALLPAPER_PATH" -n
fi

# set discord theme by launching pywal-discord
bash $HOME/.config/hypr/pywal-discord.sh

json="$HOME/.cache/wal/colors.json"
theme="$HOME/.config/vesktop/themes/system24.css"
out="$HOME/.config/vesktop/themes/system24-wal.css"

# Extract pywal colors
bg=$(jq -r '.special.background' "$json")
fg=$(jq -r '.special.foreground' "$json")
c0=$(jq -r '.colors.color0' "$json")
c1=$(jq -r '.colors.color1' "$json")
c2=$(jq -r '.colors.color2' "$json")
c3=$(jq -r '.colors.color3' "$json")
c4=$(jq -r '.colors.color4' "$json")

# Replace relevant color definitions with pywal equivalents
sed -e "s|oklch(19% 0 0)|$bg|g" \
  -e "s|oklch(23% 0 0)|$bg|g" \
  -e "s|oklch(27% 0 0)|$bg|g" \
  -e "s|oklch(31% 0 0)|$bg|g" \
  -e "s|oklch(95% 0 0)|$fg|g" \
  -e "s|oklch(85% 0 0)|$fg|g" \
  -e "s|oklch(75% 0 0)|$fg|g" \
  -e "s|oklch(60% 0 0)|$fg|g" \
  -e "s|oklch(40% 0 0)|$fg|g" \
  -e "s|oklch(75% 0.13 0)|$c0|g" \
  -e "s|oklch(70% 0.13 0)|$c0|g" \
  -e "s|oklch(65% 0.13 0)|$c0|g" \
  -e "s|oklch(75% 0.12 170)|$c4|g" \
  -e "s|oklch(70% 0.12 170)|$c4|g" \
  -e "s|oklch(75% 0.11 215)|$c2|g" \
  -e "s|oklch(70% 0.11 215)|$c2|g" \
  -e "s|oklch(80% 0.12 90)|$c3|g" \
  -e "s|oklch(75% 0.12 90)|$c3|g" \
  -e "s|oklch(75% 0.12 310)|$c1|g" \
  -e "s|oklch(70% 0.12 310)|$c1|g" \
  "$theme" >"$out"
# set starship theme
python3 .config/hypr/update_starship.py

# generate & apply pywal gtk theme
PYWAL_COLORS="$HOME/.cache/wal/colors-oomox"
GTK_THEME_NAME="pywal_theme"
oomox-cli "$PYWAL_COLORS" --output "$GTK_THEME_NAME"
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME"
gsettings set org.gnome.desktop.wm.preferences theme "$GTK_THEME_NAME"
gsettings set org.gnome.desktop.interface color-scheme "default"
killall waybar
waybar &

# set wallpaper to persist after reboot
cat >"$STARTUP_DIR" <<EOF
exec-once = awww img "$WALLPAPER_PATH"
exec-once = gsettings set org.gnome.desktop.interface color-scheme "prefer-$THEME_MODE"
EOF

killall -SIGUSR2 ghostty
killall -SIGUSR1 kitty

# set obsidian theme
COLORS_JSON="$HOME/.cache/wal/colors.json"
MINIMAL_CSS="$OBSIDIAN_THEME_DIR/theme.css"
bg_color=$(jq -r '.special.background' "$COLORS_JSON")
fg_color=$(jq -r '.colors.color5' "$COLORS_JSON")

STYLE_SETTINGS_JSON=$(
  cat <<EOF
{
  "minimal-style@@ax1@@$THEME_MODE": "$fg_color",
  "minimal-style@@sp1@@$THEME_MODE": "$bg_color",
  "minimal-style@@tx1@@$THEME_MODE": "$fg_color",
  "minimal-style@@icon-color@@$THEME_MODE": "$fg_color",
  "minimal-style@@base@@$THEME_MODE": "$bg_color",
  "minimal-style@@bg1@@$THEME_MODE": "$bg_color",
  "minimal-style@@tx2@@$THEME_MODE": "$fg_color",
  "minimal-style@@bold-color@@$THEME_MODE": "$fg_color",
  "minimal-style@@italic-color@@$THEME_MODE": "$fg_color",
  "minimal-style@@text-formatting@@$THEME_MODE": "$fg_color",
  "minimal-style@@tx3@@$THEME_MODE": "$fg_color"
}
EOF
)

STYLE_SETTINGS_FILE="$STYLE_SETTINGS_DIR/data.json"
echo "$STYLE_SETTINGS_JSON" >"$STYLE_SETTINGS_FILE"

# relaunch dunst to apply theme
source ~/.config/dunst/launch_dunst.sh
