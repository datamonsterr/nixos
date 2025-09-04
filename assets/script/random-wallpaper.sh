#!/bin/sh

# Random wallpaper script using nitrogen
# Sets a random wallpaper from the backgrounds directory

WALLPAPER_DIR="/etc/nixos/assets/backgrounds"

# Check if directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory $WALLPAPER_DIR does not exist"
    exit 1
fi

# Find all image files (case insensitive)
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.tiff" \) 2>/dev/null)

# Check if any wallpapers were found
if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "Error: No image files found in $WALLPAPER_DIR"
    exit 1
fi

# Select a random wallpaper
random_wallpaper=${wallpapers[$RANDOM % ${#wallpapers[@]}]}

echo "Setting wallpaper: $random_wallpaper"

# Set the wallpaper using nitrogen
nitrogen --set-zoom-fill "$random_wallpaper" --save

echo "Wallpaper set successfully!"
