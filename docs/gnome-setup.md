# GNOME Configuration Guide

## Changes Made

I've configured your NixOS laptop to use GNOME Desktop Environment instead of i3. Here's what was changed:

### 1. New Module: `modules/desktop-gnome.nix`
Created a new desktop module with:
- GNOME Desktop Environment with GDM
- GNOME core utilities and keyring
- Keyboard layout (Caps Lock ↔ Escape swap)
- fcitx5 with Unikey for Vietnamese input
- XDG Desktop Portal for GNOME
- Useful GNOME extensions:
  - AppIndicator
  - Dash to Dock
  - Blur My Shell
  - User Themes
- GNOME Tweaks and dconf-editor

### 2. Updated: `hosts/laptop/default.nix`
- Changed import from `desktop-i3.nix` to `desktop-gnome.nix`
- Removed manual HiDPI scaling settings (GNOME handles this automatically)
- Added note about fractional scaling configuration

### 3. Updated: `modules/laptop.nix`
- Removed blueman (GNOME has built-in Bluetooth support)
- Removed libinput touchpad settings (GNOME handles this)

### 4. Updated: `home/users/dat-laptop.nix`
- Removed i3-specific dotfiles (i3 config, polybar, rofi, dunst, etc.)
- Removed i3-specific scripts (i3exit, random-wallpaper.sh, dunst-history.sh)
- Removed xsettingsd and X11 resource files
- Removed manual HiDPI environment variables
- Added GNOME-specific tools (gnome-tweaks, dconf-editor)
- Kept useful configs (ghostty, zathura, backgrounds)

## Next Steps

### 1. Rebuild Your System

```bash
sudo nixos-rebuild switch
```

### 2. Reboot
After rebuilding, reboot your system to start GNOME:

```bash
sudo reboot
```

### 3. Configure HiDPI Scaling in GNOME

For your 2880x1800 display, you'll want to enable fractional scaling:

**Method 1: Using GNOME Settings (GUI)**
1. Open Settings → Displays
2. Enable "Fractional Scaling" if not already enabled
3. Set scale to 150% or 200% (whichever looks better)

**Method 2: Using gsettings (Terminal)**
```bash
# Enable experimental fractional scaling
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

# Then use the GUI to select your preferred scale
```

### 4. Configure Touchpad Settings

1. Open Settings → Mouse & Touchpad
2. Enable:
   - Tap to Click
   - Natural Scrolling
   - Two-finger Scrolling
   - Disable While Typing

### 5. Install GNOME Extensions (Optional)

The extensions are already installed, but you may need to enable them:

1. Install GNOME Extensions browser extension from https://extensions.gnome.org/
2. Or use the Extensions app (included with GNOME Tweaks)
3. Enable desired extensions:
   - **Dash to Dock**: Ubuntu-style dock
   - **Blur My Shell**: Adds blur effects
   - **AppIndicator**: System tray support for apps
   - **User Themes**: Custom shell themes

### 6. Configure Vietnamese Input (fcitx5)

1. Open Settings → Keyboard → Input Sources
2. Add "Vietnamese (Unikey)" as input source
3. Or configure fcitx5 directly using `fcitx5-configtool`
4. Switch input methods with Super+Space

### 7. Customize GNOME

**GNOME Tweaks** (already installed):
- Appearance: Change themes, icons, fonts
- Extensions: Enable/disable extensions
- Fonts: Adjust font scaling
- Keyboard & Mouse: Additional input settings
- Top Bar: Show battery percentage, date, etc.

**dconf-editor** (already installed):
- Advanced settings browser
- Be careful when changing settings here

### 8. Keyboard Shortcuts

GNOME default shortcuts:
- `Super` - Activities overview
- `Super + L` - Lock screen
- `Super + A` - Show applications
- `Ctrl + Alt + T` - Terminal (if configured)
- `Alt + F2` - Run command
- `Super + Arrow Keys` - Snap windows

Your custom keyboard setting:
- `Caps Lock ↔ Escape` swap is already configured

## Differences from i3

### What You Gain:
- ✅ Modern, polished desktop environment
- ✅ Better HiDPI support out of the box
- ✅ Automatic touchpad gesture support
- ✅ Built-in Bluetooth manager
- ✅ Better multi-monitor support
- ✅ Wayland support (for better performance and security)
- ✅ Integrated settings for everything

### What You Lose:
- ❌ Tiling window management (can be partially replaced with extensions)
- ❌ Extreme customization through config files
- ❌ Polybar status bar (replaced by GNOME Shell top bar)
- ❌ Lightweight resource usage

### Optional: Add Tiling to GNOME

If you miss i3's tiling, you can install:
- **Material Shell** extension
- **Pop Shell** extension (from System76)
- **gTile** extension

Add to `modules/desktop-gnome.nix`:
```nix
gnomeExtensions.pop-shell  # or
gnomeExtensions.material-shell
```

## Reverting to i3

If you want to go back to i3, simply:

1. Edit `hosts/laptop/default.nix`:
   ```nix
   imports = [
     ./hardware-configuration.nix
     ../../modules/desktop-i3.nix  # Change back
     ../../modules/laptop.nix
   ];
   ```

2. Rebuild:
   ```bash
   sudo nixos-rebuild switch
   ```

## Troubleshooting

### GNOME doesn't start after reboot
- Check logs: `journalctl -xe`
- Try GDM restart: `sudo systemctl restart gdm`

### Fractional scaling not available
- Run: `gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"`
- Log out and log back in

### Bluetooth not working
- Check status: `systemctl status bluetooth`
- Restart: `sudo systemctl restart bluetooth`

### Vietnamese input not working
- Run `fcitx5-configtool` and verify Unikey is added
- Restart fcitx5: `fcitx5 -r`
- Check if fcitx5 is running: `ps aux | grep fcitx5`

## Additional Resources

- [GNOME Help](https://help.gnome.org/)
- [NixOS GNOME Wiki](https://nixos.wiki/wiki/GNOME)
- [GNOME Extensions](https://extensions.gnome.org/)
- [GNOME Tweaks Documentation](https://wiki.gnome.org/Apps/Tweaks)
