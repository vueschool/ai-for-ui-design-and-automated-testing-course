#!/bin/bash

################################################################################
# generate-image.sh
#
# Generate images using Google Gemini 3 Pro Image Preview (Nano Banana Pro)
# via the REST API.
#
# USAGE:
#   ./generate-image.sh [OPTIONS]
#
# OPTIONS:
#   -p, --prompt TEXT          Text prompt describing the image to generate
#                              (required)
#   -k, --api-key KEY          Google Gemini API key
#                              (required, or set GEMINI_API_KEY env var)
#   -i, --input-image FILE     Input image file to use as reference
#                              (optional)
#   -o, --output FILE          Output filename for the generated image
#                              (default: generated_image.png)
#   -a, --aspect-ratio RATIO   Aspect ratio: 1:1, 2:3, 3:2, 3:4, 4:3, 4:5,
#                              5:4, 9:16, 16:9, 21:9
#                              (default: 1:1)
#   -s, --size SIZE            Image size: 1K, 2K, or 4K
#                              (default: 1K)
#   -h, --help                 Show this help message
#
# EXAMPLES:
#   # Basic usage with prompt
#   ./generate-image.sh -p "A futuristic cityscape at sunset"
#
#   # Specify aspect ratio and size
#   ./generate-image.sh -p "A serene mountain landscape" -a 16:9 -s 2K
#
#   # Custom output filename
#   ./generate-image.sh -p "Abstract art" -o my_image.png
#
#   # Using environment variable for API key
#   export GEMINI_API_KEY="your-api-key-here"
#   ./generate-image.sh -p "A cute cat"
#
#   # With input image reference
#   ./generate-image.sh -p "Extract the blob" -i hero.png -o blob.png
#
# NOTES:
#   - All generated images include a SynthID watermark
#   - The API endpoint used is: gemini-3-pro-image-preview
#   - Aspect ratio and size options are validated
#   - The script saves images as PNG format
#   - Requires: curl, jq (for JSON parsing)
#
# API DOCUMENTATION:
#   https://ai.google.dev/gemini-api/docs/image-generation#rest
#
################################################################################

set -euo pipefail

# Default values
PROMPT=""
API_KEY="${GEMINI_API_KEY:-}"
INPUT_IMAGE=""
OUTPUT_FILE="generated_image.png"
ASPECT_RATIO="1:1"
IMAGE_SIZE="1K"

# Valid options
VALID_ASPECT_RATIOS=("1:1" "2:3" "3:2" "3:4" "4:3" "4:5" "5:4" "9:16" "16:9" "21:9")
VALID_SIZES=("1K" "2K" "4K")

# API endpoint
API_ENDPOINT="https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent"

# Function to display usage
show_help() {
    sed -n '/^# USAGE:/,/^# API DOCUMENTATION:/p' "$0" | sed 's/^# //'
}

# Function to validate aspect ratio
validate_aspect_ratio() {
    local ratio=$1
    for valid_ratio in "${VALID_ASPECT_RATIOS[@]}"; do
        if [[ "$ratio" == "$valid_ratio" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to validate image size
validate_size() {
    local size=$1
    for valid_size in "${VALID_SIZES[@]}"; do
        if [[ "$size" == "$valid_size" ]]; then
            return 0
        fi
    done
    return 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--prompt)
            PROMPT="$2"
            shift 2
            ;;
        -k|--api-key)
            API_KEY="$2"
            shift 2
            ;;
        -i|--input-image)
            INPUT_IMAGE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -a|--aspect-ratio)
            ASPECT_RATIO="$2"
            shift 2
            ;;
        -s|--size)
            IMAGE_SIZE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$PROMPT" ]]; then
    echo "Error: Prompt is required. Use -p or --prompt to specify it." >&2
    exit 1
fi

if [[ -z "$API_KEY" ]]; then
    echo "Error: API key is required. Use -k or --api-key, or set GEMINI_API_KEY environment variable." >&2
    exit 1
fi

# Validate aspect ratio
if ! validate_aspect_ratio "$ASPECT_RATIO"; then
    echo "Error: Invalid aspect ratio '$ASPECT_RATIO'. Valid options: ${VALID_ASPECT_RATIOS[*]}" >&2
    exit 1
fi

# Validate image size
if ! validate_size "$IMAGE_SIZE"; then
    echo "Error: Invalid image size '$IMAGE_SIZE'. Valid options: ${VALID_SIZES[*]}" >&2
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq to use this script." >&2
    exit 1
fi

# Validate input image if provided
if [[ -n "$INPUT_IMAGE" ]]; then
    if [[ ! -f "$INPUT_IMAGE" ]]; then
        echo "Error: Input image file '$INPUT_IMAGE' does not exist." >&2
        exit 1
    fi
    # Detect MIME type based on file extension
    INPUT_IMAGE_EXT="${INPUT_IMAGE##*.}"
    INPUT_IMAGE_EXT_LOWER=$(echo "$INPUT_IMAGE_EXT" | tr '[:upper:]' '[:lower:]')
    case "$INPUT_IMAGE_EXT_LOWER" in
        png)
            INPUT_MIME_TYPE="image/png"
            ;;
        jpg|jpeg)
            INPUT_MIME_TYPE="image/jpeg"
            ;;
        *)
            echo "Warning: Unknown image format '$INPUT_IMAGE_EXT'. Assuming PNG." >&2
            INPUT_MIME_TYPE="image/png"
            ;;
    esac
    # Encode image to base64
    if [[ "$(uname)" == "Darwin" ]]; then
        INPUT_IMAGE_B64=$(base64 -i "$INPUT_IMAGE")
    else
        INPUT_IMAGE_B64=$(base64 -w 0 "$INPUT_IMAGE")
    fi
fi

# Create temporary file for API response
TEMP_RESPONSE=$(mktemp)
trap "rm -f $TEMP_RESPONSE" EXIT

echo "Generating image with prompt: $PROMPT"
if [[ -n "$INPUT_IMAGE" ]]; then
    echo "Using input image: $INPUT_IMAGE"
fi
echo "Aspect ratio: $ASPECT_RATIO, Size: $IMAGE_SIZE"
echo "Sending request to Gemini API..."

# Create temporary files for JSON payload
TEMP_JSON=$(mktemp)
TEMP_PROMPT=$(mktemp)
trap "rm -f $TEMP_RESPONSE $TEMP_JSON $TEMP_PROMPT" EXIT

# Escape prompt and write to temp file
echo -n "$PROMPT" | jq -Rs . > "$TEMP_PROMPT"
ESCAPED_PROMPT=$(cat "$TEMP_PROMPT")

# Build JSON payload
if [[ -n "$INPUT_IMAGE" ]]; then
    # Write base64 data to temp file to avoid command-line length limits
    TEMP_B64=$(mktemp)
    echo -n "$INPUT_IMAGE_B64" > "$TEMP_B64"
    trap "rm -f $TEMP_RESPONSE $TEMP_JSON $TEMP_PROMPT $TEMP_B64" EXIT

    # Build JSON manually to avoid argument length limits
    cat > "$TEMP_JSON" <<EOF
{
  "contents": [{
    "parts": [
      {
        "inlineData": {
          "mimeType": "$INPUT_MIME_TYPE",
          "data": "$INPUT_IMAGE_B64"
        }
      },
      {
        "text": $ESCAPED_PROMPT
      }
    ]
  }],
  "generationConfig": {
    "imageConfig": {
      "aspectRatio": "$ASPECT_RATIO",
      "imageSize": "$IMAGE_SIZE"
    }
  }
}
EOF
else
    # Build JSON without input image
    cat > "$TEMP_JSON" <<EOF
{
  "contents": [{
    "parts": [
      {
        "text": $ESCAPED_PROMPT
      }
    ]
  }],
  "generationConfig": {
    "imageConfig": {
      "aspectRatio": "$ASPECT_RATIO",
      "imageSize": "$IMAGE_SIZE"
    }
  }
}
EOF
fi

# Make API request
HTTP_CODE=$(curl -s -w "%{http_code}" -o "$TEMP_RESPONSE" \
    -X POST \
    "$API_ENDPOINT" \
    -H "x-goog-api-key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d @"$TEMP_JSON")

# Check HTTP status code
if [[ "$HTTP_CODE" -ne 200 ]]; then
    echo "Error: API request failed with HTTP status code $HTTP_CODE" >&2
    echo "Response:" >&2
    cat "$TEMP_RESPONSE" >&2
    exit 1
fi

# Extract image data from response
# The response structure: candidates[0].content.parts[].inlineData.data
IMAGE_DATA=$(jq -r '.candidates[0].content.parts[] | select(.inlineData != null) | .inlineData.data' "$TEMP_RESPONSE" | head -n 1)

if [[ -z "$IMAGE_DATA" || "$IMAGE_DATA" == "null" ]]; then
    echo "Error: No image data found in API response." >&2
    echo "Full response:" >&2
    cat "$TEMP_RESPONSE" >&2
    exit 1
fi

# Decode base64 and save to file
echo "$IMAGE_DATA" | base64 -d > "$OUTPUT_FILE"

if [[ ! -f "$OUTPUT_FILE" ]]; then
    echo "Error: Failed to save image to $OUTPUT_FILE" >&2
    exit 1
fi

# Get file size for confirmation
FILE_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo "unknown")

echo "✓ Image generated successfully!"
echo "  Saved to: $OUTPUT_FILE"
echo "  File size: $FILE_SIZE bytes"

