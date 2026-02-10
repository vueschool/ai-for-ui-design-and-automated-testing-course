---
description: Generate an OG image for a blog post based on the subject image
---

1. **Generate the OG Image**

   Run the `generate-image.sh` script to combine the template and the subject image.

   - **Template**: `image-templates/blog-post-og-template.png`
   - **Subject**: `public/blog/[post-slug]-subject-1x1.png`
   - **Output**: `public/blog/[post-slug]-og.png`
   - **Ratio**: 16:9

   **Prompt**:
   ```
   This image is made up of 4 parts:
   1. a background with blobs
   2. A box centered on top of the background split into 2 columns
   2. a right column with a placeholder image and logo in the bottom right corner
   3. a left column with a frosted/glassy look and placeholder text

   Your job is to:

   1. Replace the placeholder image in the right column with the subject image. Position, scale, and crop the subject image to fit the space in a balanced way.

   2. Replace the placeholder text in the left column with the title and subtitle of the blog post (adjust font size as needed to fit the available space in the column)
   
   3. Keep the logo in the bottom right corner of the right column as it is in the template.

   Notes:
   Crop the subject image to fit the space of the placeholder image. ALWAYS take up the exact same position and space as the placeholder image in the tamplate

   You can vary the shape and position of the blobs in the background but keep the same color theme. The background color MUST remain the same.

   Do NOT alter the layout.

   Do NOT alter the size of the left hand column next to the placeholder image. It's size must remain unchanged from the template
   ```

   **Example Command**:
   ```bash
   @generate-image.sh \
     --prompt "[insert prompt here]" \
     --input-image image-templates/blog-post-og-template.png \
     --input-image public/blog/[post-slug]-subject-1x1.png \
     --aspect-ratio 16:9 \
     --size 4K \
     --output public/blog/[post-slug]-og.png
   ```
2. You MUST read and evaluate the generated image for quality:
  1. Is the right column image well composed and balanced?
  2. Is the left column text well composed and balanced?
  3. Is the text legible?
  4. Is the text font free from squishing or stretching?
  3. Is the logo in the bottom right corner of the right column the same as the template?
3. If it is not good enough, generate again with adjustments to the prompt as required.
