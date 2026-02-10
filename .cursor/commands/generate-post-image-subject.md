---
description: Generate a blog post image
---

1. First brainstorm photo realistic images that would best capture the essence of the article.
2. Then generate an image using the `generate-image.sh` script.

Run this command:

```bash
./generate-image.sh \
  --prompt "[description of the photo based on results of the brainstorm]. Note: person should be looking towards the camera" \
  --aspect-ratio "1:1" \
  --size "2K" \
  --output "public/blog/[post-slug]-subject-1x1.png"
```

3. Generate a 21:9 version by expanding the previous image using the script.

Run this command:

```bash
./generate-image.sh \
  --prompt "Expand the image. Keep the focus on the subject in the center but expand the environment at the edges" \
  --input-image "public/blog/[post-slug]-subject-1x1.png" \
  --aspect-ratio "21:9" \
  --size 2K \
  --output "public/blog/[post-slug]-subject-21x9.png"
```
4. You MUST read and evaluate the generated image for quality:
  1. Is the subject well composed and balanced?
  2. Is the image not too busy?
  3. Is the image related to the post?
5. If it is not good enough, generate again with adjustments to the prompt as required.
