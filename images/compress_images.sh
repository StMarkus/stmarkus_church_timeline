#!/bin/bash

# Directory to process (default: current directory)
DIR=${1:-.}

# Maximum width in pixels
MAX_WIDTH=${2:-700}

# Maximum file size in KB (for info only)
MAX_SIZE_KB=${3:-500}

echo "Processing images in $DIR..."

find "$DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) -print0 | while IFS= read -r -d '' file; do
    echo "Processing $file"

    # Resize if width is bigger than MAX_WIDTH
    width=$(sips -g pixelWidth "$file" | awk '/pixelWidth:/ {print $2}')
    if [ "$width" -gt "$MAX_WIDTH" ]; then
        echo " - Resizing to width $MAX_WIDTH"
        sips --resampleWidth "$MAX_WIDTH" "$file" >/dev/null
    fi

    # Compress PNG
    if [[ "$file" == *.png ]]; then
        pngquant --force --ext .png --quality=65-80 "$file"
    fi

    # Compress JPEG
    if [[ "$file" == *.jpg ]] || [[ "$file" == *.jpeg ]]; then
        jpegoptim --max=80 --strip-all "$file"
    fi

    # Check file size
    filesize_kb=$(du -k "$file" | cut -f1)
    if [ "$filesize_kb" -gt "$MAX_SIZE_KB" ]; then
        echo " - Note: File still larger than ${MAX_SIZE_KB}KB ($filesize_kb KB)"
    fi
done

echo "All images processed and overwritten!"
