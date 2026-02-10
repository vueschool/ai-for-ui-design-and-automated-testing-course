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
#   -i, --input-image FILE     Input image file(s) to use as reference
#                              (optional; may be repeated for multiple images)
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
#   # With multiple input images
#   ./generate-image.sh -p "Combine these" -i a.png -i b.png -o combined.png
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
INPUT_IMAGES=()
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

# Function to get MIME type from filename extension
get_mime_type() {
    local ext
    ext=$(echo "${1##*.}" | tr '[:upper:]' '[:lower:]')
    case "$ext" in
        png) echo "image/png" ;;
        jpg|jpeg) echo "image/jpeg" ;;
        *) echo "image/png" ;;
    esac
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
            INPUT_IMAGES+=("$2")
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

# Validate input images and build JSON array of parts (mimeType + data)
TEMP_IMAGE_PARTS=""
if [[ ${#INPUT_IMAGES[@]} -gt 0 ]]; then
    TEMP_IMAGE_PARTS=$(mktemp)
    for INPUT_IMAGE in "${INPUT_IMAGES[@]}"; do
        if [[ ! -f "$INPUT_IMAGE" ]]; then
            echo "Error: Input image file '$INPUT_IMAGE' does not exist." >&2
            exit 1
        fi
    done
    # Build JSON array of { mimeType, data } for each image
    # API requires single-line base64 (no newlines); macOS base64 wraps by default
    IMAGE_PARTS_JSON=$(for INPUT_IMAGE in "${INPUT_IMAGES[@]}"; do
        MIME=$(get_mime_type "$INPUT_IMAGE")
        if [[ "$(uname)" == "Darwin" ]]; then
            base64 -i "$INPUT_IMAGE" | tr -d '\n'
        else
            base64 -w 0 "$INPUT_IMAGE"
        fi | jq -Rs --arg mime "$MIME" '{mimeType: $mime, data: .}'
    done | jq -s .)
    echo -n "$IMAGE_PARTS_JSON" > "$TEMP_IMAGE_PARTS"
else
    TEMP_IMAGE_PARTS=$(mktemp)
    echo "[]" > "$TEMP_IMAGE_PARTS"
fi

# Create temporary file for API response
TEMP_RESPONSE=$(mktemp)
trap "rm -f $TEMP_RESPONSE $TEMP_IMAGE_PARTS" EXIT

echo "Generating image with prompt: $PROMPT"
if [[ ${#INPUT_IMAGES[@]} -gt 0 ]]; then
    echo "Using input image(s): ${INPUT_IMAGES[*]}"
fi
echo "Aspect ratio: $ASPECT_RATIO, Size: $IMAGE_SIZE"
echo "Sending request to Gemini API..."

# Create temporary file for JSON payload
TEMP_JSON=$(mktemp)
trap "rm -f $TEMP_RESPONSE $TEMP_JSON $TEMP_IMAGE_PARTS" EXIT

# Build JSON payload with jq (supports 0 or more input images)
jq -n \
    --slurpfile imgparts "$TEMP_IMAGE_PARTS" \
    --arg prompt "$PROMPT" \
    --arg ar "$ASPECT_RATIO" \
    --arg sz "$IMAGE_SIZE" \
    '{
      contents: [{
        parts: ([$imgparts[0][] | {inlineData: .}] + [{text: $prompt}])
      }],
      generationConfig: {
        imageConfig: {
          aspectRatio: $ar,
          imageSize: $sz
        }
      }
    }' > "$TEMP_JSON"

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

