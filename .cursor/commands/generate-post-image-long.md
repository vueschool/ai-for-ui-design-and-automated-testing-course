---
description: Generate a long blog post image for the top of a single post from a template
---

Generate an image using the `generate-image.sh` script.

* `image-templates/blog-post-long-template.png` is a template for the image that appears at the top of the blog post page.
* The image found at `public/blog/[post-slug]-subject-21x9.png` is an image that well represents the subject of the blog post.

## Prompt
You are given two images: a template image with two glassy boxes (windows) and a subject image representing the theme of a blog post. 

Replace the large box on the left of the template with the central portion of the subject image, 
and the smaller box on the right with the far-right section of the same subject image, 
so that together the boxes form a continuous panoramic scene from the subject image.

The subject of the image should NOT appear in the right box.

Make sure the right box visually continues the scene from the left (not a repeat). 
Preserve all background areas and glassy visual effects of the template exactly as they are, including its flat background color. 

The result should be a seamless composite where only the contents of the glassy boxes are replaced by the appropriate portions of the subject image.

## Steps:

1. Run the following command:

```bash
./generate-image.sh \
  --prompt "[insert prompt here]" \
  --input-image "image-templates/blog-post-long-template.png" \
  --input-image "public/blog/[post-slug]-subject-21x9.png" \
  --aspect-ratio "21:9" \
  --size 2K \
  --output "public/blog/[post-slug]-long.png"
```
2. You MUST read and evaluate the generated image for quality:
  1. Is the right box visually continuing the scene from the left?
  2. Is the subject of the image not appearing in the right box?
3. If it is not good enough, generate again with adjustments to the prompt as required.
