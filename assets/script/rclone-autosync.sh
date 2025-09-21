#!/usr/bin/env bash
# rclone auto-sync management script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

GDRIVE="gdrive-ptd170904"
SERVICE_NAME="rclone-auto-sync"
CONFIG_FILE="/etc/nixos/assets/sync_folders"
LOG_FILE="$HOME/.cache/rclone-sync.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log with timestamp (only to file, not terminal)
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to sync a single folder
sync_single_folder() {
    local remote_path="$1"
    local local_path="$2"
    
    # Expand ~ to home directory
    local_path="${local_path/#~/$HOME}"
    
    log_message "Starting sync: $GDRIVE:$remote_path -> $local_path"
    
    # Create local directory if it doesn't exist
    mkdir -p "$local_path"
    
    # Perform the sync (no progress bar for cleaner output)
    if rclone sync "$GDRIVE:$remote_path" "$local_path" --create-empty-src-dirs >> "$LOG_FILE" 2>&1; then
        log_message "✅ SUCCESS: $remote_path synced to $local_path"
        return 0
    else
        log_message "❌ FAILED: $remote_path sync to $local_path"
        return 1
    fi
}

# Function to run sync for all folders in config
run_sync_all() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "❌ ERROR: Config file not found: $CONFIG_FILE" >&2
        exit 1
    fi
    
    log_message "🔄 Starting multi-folder sync session"
    echo "🔄 Syncing folders from $CONFIG_FILE..."
    
    local success_count=0
    local failure_count=0
    local total_count=0
    
    # Read config file and sync each folder
    while IFS=',' read -r remote_path local_path; do
        # Skip empty lines and comments
        [[ -z "$remote_path" || "$remote_path" =~ ^[[:space:]]*# ]] && continue
        
        # Trim whitespace
        remote_path=$(echo "$remote_path" | xargs)
        local_path=$(echo "$local_path" | xargs)
        local expanded_path="${local_path/#~/$HOME}"
        
        total_count=$((total_count + 1))
        echo "  📁 Syncing: $remote_path → $expanded_path"
        
        if sync_single_folder "$remote_path" "$local_path"; then
            success_count=$((success_count + 1))
            echo "    ✅ Success"
        else
            failure_count=$((failure_count + 1))
            echo "    ❌ Failed"
        fi
        
    done < "$CONFIG_FILE"
    
    log_message "📊 Sync session completed: $success_count successful, $failure_count failed out of $total_count total"
    echo "📊 Completed: $success_count successful, $failure_count failed out of $total_count folders"
    
    if [ $failure_count -eq 0 ]; then
        log_message "🎉 All syncs completed successfully!"
        echo "🎉 All syncs completed successfully!"
        exit 0
    else
        log_message "⚠️  Some syncs failed. Check the log for details."
        echo "⚠️  Some syncs failed. Check logs with: $0 logs"
        exit 1
    fi
}

# Function to check service status
check_status() {
    echo -e "${YELLOW}📊 Auto-sync Service Status:${NC}"
    systemctl --user status "$SERVICE_NAME" --no-pager -l
    echo ""
    echo -e "${YELLOW}📅 Timer Status:${NC}"
    systemctl --user status "${SERVICE_NAME}.timer" --no-pager -l
}

# Function to show current sync folders
show_config() {
    echo -e "${YELLOW}📁 Current sync folders configuration:${NC}"
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${BLUE}Config file: $CONFIG_FILE${NC}"
        echo ""
        while IFS=',' read -r remote_path local_path; do
            [[ -z "$remote_path" || "$remote_path" =~ ^[[:space:]]*# ]] && continue
            remote_path=$(echo "$remote_path" | xargs)
            local_path=$(echo "$local_path" | xargs)
            # Show both original and expanded path
            local expanded_path="${local_path/#~/$HOME}"
            if [ "$local_path" != "$expanded_path" ]; then
                echo "  📤 $GDRIVE:$remote_path → $local_path (expands to: $expanded_path)"
            else
                echo "  📤 $GDRIVE:$remote_path → $local_path"
            fi
        done < "$CONFIG_FILE"
    else
        echo -e "${RED}❌ Config file not found: $CONFIG_FILE${NC}"
    fi
}

# Function to add a sync folder
add_folder() {
    local remote_path="$1"
    local local_path="$2"
    
    if [ -z "$remote_path" ] || [ -z "$local_path" ]; then
        echo -e "${RED}Usage: $0 add <remote_path> <local_path>${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}➕ Adding sync folder:${NC}"
    echo "  Remote: $GDRIVE:$remote_path"
    echo "  Local:  $local_path"
    
    echo "$remote_path,$local_path" >> "$CONFIG_FILE"
    
    echo -e "${GREEN}✅ Folder added to sync configuration!${NC}"
    echo -e "${BLUE}💡 Run 'sudo nixos-rebuild switch' if you want to rebuild the service${NC}"
}

# Function to edit sync folders
edit_config() {
    if command -v nano >/dev/null 2>&1; then
        nano "$CONFIG_FILE"
    elif command -v vim >/dev/null 2>&1; then
        vim "$CONFIG_FILE"
    else
        echo -e "${YELLOW}📝 Edit this file to modify sync folders:${NC}"
        echo "$CONFIG_FILE"
        echo ""
        echo -e "${BLUE}Format: remote_path,local_path${NC}"
        echo -e "${BLUE}Example: Study,/home/dat/Study${NC}"
    fi
}

# Function to enable auto-sync
enable_autosync() {
    echo -e "${YELLOW}� Enabling auto-sync service...${NC}"
    
    # Enable and start the timer
    systemctl --user enable "${SERVICE_NAME}.timer"
    systemctl --user start "${SERVICE_NAME}.timer"
    
    echo -e "${GREEN}✅ Auto-sync enabled!${NC}"
    echo -e "${BLUE}💡 Sync will run 2 minutes after login, then every 30 minutes${NC}"
    echo ""
    show_config
}

# Function to trigger manual sync
manual_sync() {
    echo -e "${YELLOW}🔄 Running manual sync...${NC}"
    systemctl --user start "$SERVICE_NAME"
    
    # Wait a moment then show status
    sleep 2
    systemctl --user status "$SERVICE_NAME" --no-pager -l
}

# Function to disable auto-sync
disable_autosync() {
    echo -e "${YELLOW}🛑 Disabling auto-sync...${NC}"
    
    systemctl --user stop "${SERVICE_NAME}.timer" 2>/dev/null || true
    systemctl --user disable "${SERVICE_NAME}.timer" 2>/dev/null || true
    
    echo -e "${GREEN}✅ Auto-sync disabled!${NC}"
}

# Function to show sync logs
show_logs() {
    echo -e "${YELLOW}📋 Recent sync logs from systemd:${NC}"
    journalctl --user -u "$SERVICE_NAME" --no-pager -n 50
    
    if [ -f "$LOG_FILE" ]; then
        echo ""
        echo -e "${YELLOW}📋 Detailed sync logs:${NC}"
        tail -50 "$LOG_FILE"
    fi
}

# Function to configure sync folder
configure_sync() {
    echo -e "${YELLOW}⚙️ Current auto-sync configuration:${NC}"
    echo "This would require rebuilding your NixOS configuration."
    echo ""
    echo -e "${BLUE}To change the sync folder:${NC}"
    echo "1. Edit /etc/nixos/home/common.nix"
    echo "2. Change 'gdrive-ptd170904:Study' to your desired folder"
    echo "3. Change '%h/Study' to your desired local path"
    echo "4. Run: sudo nixos-rebuild switch --flake /etc/nixos#\$(hostname)"
}

# Main script logic
case "$1" in
    status)
        check_status
        ;;
    config|show)
        show_config
        ;;
    add)
        add_folder "$2" "$3"
        ;;
    edit)
        edit_config
        ;;
    enable)
        enable_autosync
        ;;
    disable)
        disable_autosync
        ;;
    sync|run)
        manual_sync
        ;;
    run-sync)
        run_sync_all
        ;;
    logs)
        show_logs
        ;;
    configure)
        configure_sync
        ;;
    *)
        echo -e "${BLUE}🔄 rclone Auto-Sync Manager${NC}"
        echo "================================="
        echo "Usage: $0 {command} [options]"
        echo ""
        echo -e "${YELLOW}📊 Status Commands:${NC}"
        echo "  status                   - Show service and timer status"
        echo "  logs                     - Show recent sync logs"
        echo ""
        echo -e "${YELLOW}⚙️ Configuration Commands:${NC}"
        echo "  config                   - Show current sync folders"
        echo "  add <remote> <local>     - Add a new sync folder"
        echo "  edit                     - Edit sync folders config file"
        echo ""
        echo -e "${YELLOW}⚙️ Control Commands:${NC}"
        echo "  enable                   - Enable auto-sync service"
        echo "  disable                  - Disable auto-sync"
        echo "  sync                     - Run manual sync now (via systemd)"
        echo "  run-sync                 - Run sync directly (all folders from config)"
        echo "  configure               - Show how to change sync folders"
        echo ""
        echo -e "${YELLOW}📋 Examples:${NC}"
        echo "  $0 config                # Show current sync folders"
        echo "  $0 add Study ~/Study     # Add Study folder to sync"
        echo "  $0 enable                # Enable auto-sync service"
        echo "  $0 status                # Check if auto-sync is running"
        echo "  $0 sync                  # Manually trigger sync for all folders"
        echo ""
        echo -e "${GREEN}💡 Auto-sync runs 2 min after login, then every 30 minutes${NC}"
        ;;
esac
