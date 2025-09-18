#!/usr/bin/env bash
# rclone management script for Google Drive (no mounting needed)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Google Drive remote name
GDRIVE="gdrive-ptd170904"

# Function to list directories
list_dirs() {
    echo -e "${YELLOW}📁 Directories in Google Drive:${NC}"
    rclone lsd "$GDRIVE:$1"
}

# Function to list files
list_files() {
    local path="$1"
    local limit="${2:-20}"
    echo -e "${YELLOW}📄 Files in $path (showing first $limit):${NC}"
    rclone ls "$GDRIVE:$path" | head -$limit
}

# Function to download a file
download_file() {
    local remote_path="$1"
    local local_path="${2:-./}"
    
    echo -e "${YELLOW}⬇️ Downloading: $remote_path${NC}"
    rclone copy "$GDRIVE:$remote_path" "$local_path" -P
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Download completed!${NC}"
    else
        echo -e "${RED}❌ Download failed!${NC}"
    fi
}

# Function to upload a file
upload_file() {
    local local_path="$1"
    local remote_path="${2:-/}"
    
    echo -e "${YELLOW}⬆️ Uploading: $local_path to $remote_path${NC}"
    rclone copy "$local_path" "$GDRIVE:$remote_path" -P
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Upload completed!${NC}"
    else
        echo -e "${RED}❌ Upload failed!${NC}"
    fi
}

# Function to sync a specific folder
sync_folder() {
    local remote_path="$1"
    local local_path="$2"
    local direction="${3:-down}" # down or up
    
    if [ "$direction" = "down" ]; then
        echo -e "${YELLOW}⬇️ Syncing from Google Drive: $remote_path → $local_path${NC}"
        rclone sync "$GDRIVE:$remote_path" "$local_path" -P --dry-run
        echo -e "${BLUE}This is a dry run. Add --execute to actually sync.${NC}"
    else
        echo -e "${YELLOW}⬆️ Syncing to Google Drive: $local_path → $remote_path${NC}"
        rclone sync "$local_path" "$GDRIVE:$remote_path" -P --dry-run
        echo -e "${BLUE}This is a dry run. Add --execute to actually sync.${NC}"
    fi
}

# Function to search files
search_files() {
    local query="$1"
    echo -e "${YELLOW}🔍 Searching for: $query${NC}"
    rclone ls "$GDRIVE:" | grep -i "$query"
}

# Function to show disk usage
show_usage() {
    echo -e "${YELLOW}💾 Google Drive Usage:${NC}"
    rclone about "$GDRIVE:"
}

# Main script logic
case "$1" in
    list|ls)
        if [ -z "$2" ]; then
            list_dirs ""
        else
            list_dirs "$2"
        fi
        ;;
    files)
        list_files "${2:-}" "${3:-20}"
        ;;
    download|dl)
        if [ -z "$2" ]; then
            echo -e "${RED}Usage: $0 download <remote_file_path> [local_directory]${NC}"
            exit 1
        fi
        download_file "$2" "$3"
        ;;
    upload|ul)
        if [ -z "$2" ]; then
            echo -e "${RED}Usage: $0 upload <local_file_path> [remote_directory]${NC}"
            exit 1
        fi
        upload_file "$2" "$3"
        ;;
    sync)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo -e "${RED}Usage: $0 sync <remote_path> <local_path> [up|down]${NC}"
            exit 1
        fi
        sync_folder "$2" "$3" "$4"
        ;;
    search)
        if [ -z "$2" ]; then
            echo -e "${RED}Usage: $0 search <search_term>${NC}"
            exit 1
        fi
        search_files "$2"
        ;;
    usage)
        show_usage
        ;;
    config)
        echo -e "${YELLOW}Opening rclone configuration...${NC}"
        rclone config
        ;;
    *)
        echo -e "${BLUE}🚀 rclone Google Drive Manager${NC}"
        echo "================================="
        echo "Usage: $0 {command} [options]"
        echo ""
        echo -e "${YELLOW}📁 Browse Commands:${NC}"
        echo "  list [path]              - List directories in Google Drive"
        echo "  files [path] [limit]     - List files (default: 20 files)"
        echo "  search <term>            - Search for files containing term"
        echo ""
        echo -e "${YELLOW}📤 Transfer Commands:${NC}"
        echo "  download <remote> [local] - Download file from Google Drive"
        echo "  upload <local> [remote]   - Upload file to Google Drive"
        echo "  sync <remote> <local> [up|down] - Sync folder (dry-run)"
        echo ""
        echo -e "${YELLOW}ℹ️ Info Commands:${NC}"
        echo "  usage                    - Show Google Drive storage usage"
        echo "  config                   - Configure rclone remotes"
        echo ""
        echo -e "${YELLOW}📋 Examples:${NC}"
        echo "  $0 list                  # List root directories"
        echo "  $0 files Study 10        # List 10 files in Study folder"
        echo "  $0 download 'Study/file.pdf' ~/Downloads"
        echo "  $0 upload ~/document.pdf Study/"
        echo "  $0 search 'presentation'"
        echo ""
        echo -e "${GREEN}💡 Tip: No mounting needed! Work directly with cloud files.${NC}"
        ;;
esac
