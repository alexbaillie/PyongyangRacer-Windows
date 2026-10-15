"""Re-renders the painted road markings (yellow centre line, white dashes) of a road texture at SCALE x resolution
with crisp edges, so they stay sharp when the camera is close to the road."""
import numpy as np
from PIL import Image
from scipy import ndimage

SCALE = 3

def smoothstep(a, lo, hi):
    t = np.clip((a - lo) / (hi - lo), 0, 1)
    return t * t * (3 - 2 * t)

def sharpen_markings(img, scale=SCALE):
    a = np.asarray(img.convert("RGB")).astype(np.float32)
    h, w, _ = a.shape
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    # soft masks of marking pixels
    yellow = np.clip((np.minimum(r, g) - b - 40) / 90.0, 0, 1)
    white = np.clip((np.minimum(np.minimum(r, g), b) - 150) / 70.0, 0, 1) * (1 - yellow)
    # base: smooth bicubic upscale of the picture with the markings painted out by the surroundings
    # paint the markings (and their dark/bright fringe) out of the base using the surrounding road colour
    area = ndimage.binary_dilation((yellow + white) > 0.04, iterations=2)
    keep = (~area).astype(np.float32)
    filled = a.copy()
    num = ndimage.gaussian_filter(a * keep[..., None], sigma=(4, 4, 0))
    den = ndimage.gaussian_filter(keep, sigma=4)[..., None]
    filled[area] = (num / np.maximum(den, 1e-3))[area]
    big = Image.fromarray(np.clip(filled, 0, 255).astype(np.uint8)).resize((w * scale, h * scale), Image.LANCZOS)
    base = np.asarray(big).astype(np.float32)
    out = base.copy()
    for mask, core_sel in ((yellow, lambda m: m > 0.85), (white, lambda m: m > 0.85)):
        if mask.max() < 0.3:
            continue
        sel = core_sel(mask)
        if sel.sum() < 4:
            continue
        colour = a[sel].mean(axis=0)
        mb = np.asarray(Image.fromarray((mask * 255).astype(np.uint8)).resize((w * scale, h * scale), Image.BICUBIC)).astype(np.float32) / 255.0
        alpha = smoothstep(mb, 0.35, 0.65)
        # fill the marking area of the base with the neighbouring road colour so no halo shows
        out = out * (1 - alpha[..., None]) + colour[None, None, :] * alpha[..., None]
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8))

if __name__ == "__main__":
    import sys
    im = Image.open(sys.argv[1])
    sharpen_markings(im).save(sys.argv[2])
