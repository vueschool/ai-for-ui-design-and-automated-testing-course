---
description: Generate a blog post OG image from a template
---

1. First brainstorm photo realistic images that would best capture the essence of the article.
2. Then generate an image using the generate-image.sh script the following instructions:

`image-templates/blog-post-og-template.png` is a placeholder image for blog posts.
Use it (and NO other images) as inspiration to generate images for blog posts.

You MUST send this reference image to the generate-image.sh script to generate the images for your blog post along with the prompt:

```
# Generate an image that matches the provided image but with 2 things changed:

## 1. The placeholder text on the left hand side
Replace it with the [post-title] and [subtitle - optional]

## 2. The placeholder image on the right hand side 
[description of the photo based on results of the brainstorm]

You can vary the shape and position of the blobs in the background but keep the same color theme. The background color MUST remain the same.

```
Must generate images that are aspect ratio 16:9 (1920px x 1080px)
Move the resulting image to `/public/blog/[post-slug]-og.png` only if the file path doesn't already exist. (Warn me if it does)

Check the generated image for quality (spelling issues, too busy, unrelated to the post, etc.) and if it is not good enough, generate again with adjustments to the prompt as required.

Update the related blog post markdown file with the new image path.
