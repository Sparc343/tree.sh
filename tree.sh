
#!/bin/bash

# ==========================================
# Linux TREE - DOS/Windows TREE equivalent
# Supports /F, /A, /H and /?
# DOS-style switches are case-insensitive
# ==========================================

SHOW_FILES=false
SHOW_HIDDEN=false
ASCII_MODE=false
ROOT="."

# ==========================================
# Help screen
# ==========================================

show_help() {
    cat << 'EOF'

TREE - Directory Structure Viewer for Linux

Usage:
    tree.sh [path] [/F] [/A] [/H] [/?]

Arguments:
    path       Directory to display.
               Defaults to current directory.

DOS/Windows Switches:
    /F or /f  Display files as well as directories.
    /A or /a  Use ASCII characters.
    /H or /h  Display hidden files and directories.
    /?        Display this help message.

Linux Switches:
    -f         Same as /F
    -a         Same as /A
    -h         Display help
    --help     Display help
    --hidden   Same as /H

Examples:
    ./tree.sh
    ./tree.sh /home/user
    ./tree.sh /F
    ./tree.sh /f
    ./tree.sh /A
    ./tree.sh /h
    ./tree.sh /F /H
    ./tree.sh /f /a /h
    ./tree.sh /home/user /F /A /H
    ./tree.sh --hidden
    ./tree.sh -f -a --hidden
    ./tree.sh /?

Description:
    Displays the directory structure of a specified
    directory and all its subdirectories.

    Hidden files and directories are excluded by default.
    Use /H or /h to include hidden items.

EOF
}

# ==========================================
# Parse command-line arguments
# ==========================================

for ARG in "$@"; do
    case "$ARG" in

        # Help
        '/?'|-h|--help)
            show_help
            exit 0
            ;;

        # Show files
        /F|/f|-f)
            SHOW_FILES=true
            ;;

        # ASCII characters
        /A|/a|-a)
            ASCII_MODE=true
            ;;

        # Show hidden items
        /H|/h|--hidden)
            SHOW_HIDDEN=true
            ;;

        # Unknown Linux-style switches
        -*)
            echo "ERROR: Unknown switch: $ARG"
            echo "Use /? or -h for help."
            exit 1
            ;;

        # Directory path
        *)
            ROOT="$ARG"
            ;;
    esac
done

# ==========================================
# Select tree characters
# ==========================================

if $ASCII_MODE; then
    BRANCH='|-- '
    LAST='`-- '
    PIPE='|   '
    SPACE='    '
else
    BRANCH='+-- '
    LAST='+-- '
    PIPE='¦   '
    SPACE='    '
fi

# ==========================================
# Recursive tree function
# ==========================================

show_tree() {
    local DIR="$1"
    local PREFIX="$2"
    local NEXT_PREFIX
    local ITEM
    local NAME
    local COUNT
    local INDEX=0

    local ITEMS=()

    # Collect directory contents
    if $SHOW_HIDDEN; then
        while IFS= read -r -d '' ITEM; do
            if [[ -d "$ITEM" ]] || $SHOW_FILES; then
                ITEMS+=("$ITEM")
            fi
        done < <(
            find "$DIR" -mindepth 1 -maxdepth 1 \
                -print0 2>/dev/null | sort -z
        )
    else
        while IFS= read -r -d '' ITEM; do
            if [[ -d "$ITEM" ]] || $SHOW_FILES; then
                ITEMS+=("$ITEM")
            fi
        done < <(
            find "$DIR" -mindepth 1 -maxdepth 1 \
                ! -name '.*' -print0 2>/dev/null | sort -z
        )
    fi

    COUNT=${#ITEMS[@]}

    for ITEM in "${ITEMS[@]}"; do
        ((INDEX++))

        NAME="${ITEM##*/}"

        if (( INDEX == COUNT )); then
            printf '%s%s%s' "$PREFIX" "$LAST" "$NAME"
            NEXT_PREFIX="${PREFIX}${SPACE}"
        else
            printf '%s%s%s' "$PREFIX" "$BRANCH" "$NAME"
            NEXT_PREFIX="${PREFIX}${PIPE}"
        fi

        if [[ -d "$ITEM" ]]; then
            printf '/\n'
            show_tree "$ITEM" "$NEXT_PREFIX"
        else
            printf '\n'
        fi
    done
}

# ==========================================
# Validate root directory
# ==========================================

if [[ ! -d "$ROOT" ]]; then
    echo "ERROR: Directory not found: $ROOT"
    exit 1
fi

# ==========================================
# Display tree
# ==========================================

echo "$ROOT"
show_tree "$ROOT" ""

