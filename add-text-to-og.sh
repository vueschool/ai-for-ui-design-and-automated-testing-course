#!/usr/bin/env bash
# Add title and optional subtitle to an OG image. Requires ImageMagick (magick, identify).
# Fonts: set TITLE_FONT / SUBTITLE_FONT if Outfit-Bold or Inter are not available.
set -euo pipefail

# Text configuration (base sizes for 1920x1080)
# Title font scales by length: TITLE_REF_SIZE at TITLE_REF_CHARS, clamped to floor/ceiling
TITLE_REF_CHARS=45
TITLE_REF_SIZE=110
TITLE_FONT_FLOOR=60
TITLE_FONT_CEILING=130
TITLE_LINE_HEIGHT_RATIO=105   # proportional: at TITLE_REF_SIZE → this line height
TITLE_LINE_HEIGHT_CUTOFF=105  # for font size above this, subtract TITLE_LINE_HEIGHT_EXTRA
TITLE_LINE_HEIGHT_EXTRA=5     # subtract from line height when font > cutoff
SUBTITLE_FONT_SIZE=48
SUBTITLE_LINE_HEIGHT=60
GAP=40

# Text box position/size (relative to 1920x1080)
BOX_LEFT=190
BOX_TOP=200
BOX_WIDTH_REF=856
BOX_HEIGHT_REF=838

# Fonts (ImageMagick font names or paths; adjust for your system)
TITLE_FONT="${TITLE_FONT:-Outfit-Bold}"
SUBTITLE_FONT="${SUBTITLE_FONT:-Inter}"

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  -i, --input <path>     Path to the input image (required)
  -o, --output <path>    Path to the output image (required)
  -t, --title <text>     Title text (required)
  -s, --subtitle <text>  Subtitle text (optional)
  -h, --help             Show this help message
EOF
}

# Parse arguments
INPUT=""
OUTPUT=""
TITLE=""
SUBTITLE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--input)    INPUT="$2";  shift 2 ;;
    -o|--output)   OUTPUT="$2"; shift 2 ;;
    -t|--title)    TITLE="$2";   shift 2 ;;
    -s|--subtitle) SUBTITLE="$2"; shift 2 ;;
    -h|--help)     usage; exit 0 ;;
    *)             echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$INPUT" || -z "$OUTPUT" || -z "$TITLE" ]]; then
  echo "Error: --input, --output, and --title are required" >&2
  usage >&2
  exit 1
fi

# Title font size from character count (45 chars = 110px, clamped to floor/ceiling)
TITLE_CHARS=${#TITLE}
TITLE_FONT_SIZE=$((TITLE_REF_SIZE * TITLE_REF_CHARS / TITLE_CHARS))
[[ $TITLE_FONT_SIZE -lt $TITLE_FONT_FLOOR ]] && TITLE_FONT_SIZE=$TITLE_FONT_FLOOR
[[ $TITLE_FONT_SIZE -gt $TITLE_FONT_CEILING ]] && TITLE_FONT_SIZE=$TITLE_FONT_CEILING
TITLE_LINE_HEIGHT=$((TITLE_FONT_SIZE * TITLE_LINE_HEIGHT_RATIO / TITLE_REF_SIZE))
[[ $TITLE_FONT_SIZE -gt $TITLE_LINE_HEIGHT_CUTOFF ]] && TITLE_LINE_HEIGHT=$((TITLE_LINE_HEIGHT - TITLE_LINE_HEIGHT_EXTRA))

# Resolve paths
INPUT="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
OUTPUT="$(cd "$(dirname "$OUTPUT")" 2>/dev/null && pwd)/$(basename "$OUTPUT")" || OUTPUT="$(pwd)/$OUTPUT"
TEMPOUT="${OUTPUT}.temp.png"

# Get image dimensions (ImageMagick identify)
DIM=$(identify -format "%w %h" "$INPUT")
read -r WIDTH HEIGHT <<< "$DIM"
echo "Image size: $WIDTH x $HEIGHT (title: ${TITLE_CHARS} chars → font ${TITLE_FONT_SIZE}px)"

# Bounds (relative to 1920x1080)
BOX_X=$((WIDTH * BOX_LEFT / 1920))
BOX_Y=$((HEIGHT * BOX_TOP / 1080))
BOX_WIDTH=$((WIDTH * BOX_WIDTH_REF / 1920))
BOX_HEIGHT=$((HEIGHT * BOX_HEIGHT_REF / 1080))

# Scale factor and scaled sizes
SCALE_NUM=$WIDTH
SCALE_DEN=1920
TITLE_FS=$((TITLE_FONT_SIZE * SCALE_NUM / SCALE_DEN))
TITLE_LH=$((TITLE_LINE_HEIGHT * SCALE_NUM / SCALE_DEN))
SUBTITLE_FS=$((SUBTITLE_FONT_SIZE * SCALE_NUM / SCALE_DEN))
SUBTITLE_LH=$((SUBTITLE_LINE_HEIGHT * SCALE_NUM / SCALE_DEN))
CURRENT_GAP=$((GAP * SCALE_NUM / SCALE_DEN))

echo "Box dimensions: x=$BOX_X y=$BOX_Y w=$BOX_WIDTH h=$BOX_HEIGHT"

# Estimate text width (chars * fontSize * 0.55); use integer math
estimate_width() {
  local text="$1"
  local fs="$2"
  local len=${#text}
  echo $((len * fs * 55 / 100))
}

# Word-wrap: prints one line per line of output (newline-separated)
wrap_text() {
  local text="$1"
  local fs="$2"
  local max_w="$3"
  local cur="" line width
  local -a words
  IFS=' ' read -ra words <<<"$text"
  for word in "${words[@]}"; do
    if [[ -z "$cur" ]]; then
      cur="$word"
    else
      line="$cur $word"
      width=$(estimate_width "$line" "$fs")
      if [[ $width -lt $max_w ]]; then
        cur="$line"
      else
        echo "$cur"
        cur="$word"
      fi
    fi
  done
  [[ -n "${cur:-}" ]] && echo "$cur"
}

# Wrap title and subtitle (bash-friendly: no newlines in words)
TITLE_LINES_ARR=()
while IFS= read -r line; do
  [[ -n "$line" ]] && TITLE_LINES_ARR+=("$line")
done < <(wrap_text "$TITLE" "$TITLE_FS" "$BOX_WIDTH")

SUBTITLE_LINES_ARR=()
while IFS= read -r line; do
  [[ -n "$line" ]] && SUBTITLE_LINES_ARR+=("$line")
done < <(wrap_text "$SUBTITLE" "$SUBTITLE_FS" "$BOX_WIDTH")

# Total text height and starting Y for vertical center
TITLE_LINES_COUNT=${#TITLE_LINES_ARR[@]}
SUBTITLE_LINES_COUNT=${#SUBTITLE_LINES_ARR[@]}
TOTAL_H=$((TITLE_LINES_COUNT * TITLE_LH + CURRENT_GAP + SUBTITLE_LINES_COUNT * SUBTITLE_LH))
START_Y=$((BOX_Y + (BOX_HEIGHT - TOTAL_H) / 2))

# ImageMagick uses points: 1 pt ≈ 1.333 px at 96 dpi, so pt ≈ px * 3/4
TITLE_PT=$((TITLE_FS * 3 / 4))
SUBTITLE_PT=$((SUBTITLE_FS * 3 / 4))
[[ $TITLE_PT -lt 1 ]] && TITLE_PT=1
[[ $SUBTITLE_PT -lt 1 ]] && SUBTITLE_PT=1

# Build convert args: draw text for each line (escape single quotes for shell: ' -> '\'')
CONVERT_OPTS=()
CURRENT_Y=$START_Y
for line in "${TITLE_LINES_ARR[@]}"; do
  safe_line="${line//\'/\'\\\'\'}"
  CONVERT_OPTS+=(-font "$TITLE_FONT" -fill white -pointsize "$TITLE_PT" -draw "text $BOX_X,$CURRENT_Y '$safe_line'")
  CURRENT_Y=$((CURRENT_Y + TITLE_LH))
done
CURRENT_Y=$((CURRENT_Y - TITLE_LH + CURRENT_GAP + SUBTITLE_LH))
for line in "${SUBTITLE_LINES_ARR[@]}"; do
  safe_line="${line//\'/\'\\\'\'}"
  CONVERT_OPTS+=(-font "$SUBTITLE_FONT" -fill white -pointsize "$SUBTITLE_PT" -draw "text $BOX_X,$CURRENT_Y '$safe_line'")
  CURRENT_Y=$((CURRENT_Y + SUBTITLE_LH))
done

magick "$INPUT" "${CONVERT_OPTS[@]}" "$TEMPOUT"
mv "$TEMPOUT" "$OUTPUT"

echo "Image created successfully at: $OUTPUT"
echo "Title wrapped to: ${#TITLE_LINES_ARR[@]} lines"
echo "Subtitle wrapped to: ${#SUBTITLE_LINES_ARR[@]} lines"
