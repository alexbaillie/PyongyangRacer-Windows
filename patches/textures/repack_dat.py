import sys, struct, zlib, io, os
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sharpen_tex import sharpen_markings

src, dst = sys.argv[1], sys.argv[2]
data = zlib.decompress(open(src, 'rb').read(), -15)
i = 0; n = struct.unpack_from('<i', data, i)[0]; i += 4
infos = []
for _ in range(n):
    l = data[i]; i += 1; name = data[i:i + l]; i += l; t = data[i]; i += 1; infos.append((name, t))
blocks = []
for _ in range(n):
    l = struct.unpack_from('<i', data, i)[0]; i += 4; blocks.append(data[i:i + l]); i += l
assert i == len(data), "trailing bytes"

def has_markings(img):
    a = np.asarray(img.convert("RGB")).astype(np.int32)
    yellow = ((np.minimum(a[..., 0], a[..., 1]) - a[..., 2]) > 110).sum()
    white = ((a.min(axis=2)) > 215).sum()
    return yellow, white

changed = []
for k, ((name, t), b) in enumerate(zip(infos, blocks)):
    nm = name.decode('latin-1')
    if t != 10 or not nm.startswith('Resource/texture/'): continue
    low = nm.lower()
    if not any(s in low for s in ('road', 'asp', 'cross', 'tile')): continue
    try: img = Image.open(io.BytesIO(b)); img.load()
    except Exception: continue
    if img.width * img.height > 600000: continue
    y, w = has_markings(img)
    if y + w < 30: continue
    sharp = sharpen_markings(img.convert("RGB"))
    buf = io.BytesIO()
    if img.format == "JPEG": sharp.save(buf, "JPEG", quality=90, subsampling=0)
    else: sharp.save(buf, "PNG", optimize=True)
    blocks[k] = buf.getvalue(); changed.append((nm, img.size, sharp.size, len(b), len(blocks[k])))

out = bytearray(struct.pack('<i', n))
for (name, t) in infos: out += bytes([len(name)]) + name + bytes([t])
for b in blocks: out += struct.pack('<i', len(b)) + b
co = zlib.compressobj(9, zlib.DEFLATED, -15); comp = co.compress(bytes(out)) + co.flush()
open(dst, 'wb').write(comp)
for c in changed: print(c)
print("1.dat: %d -> %d bytes" % (os.path.getsize(src), len(comp)))
