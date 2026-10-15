import sys, os, struct, math
sys.path.insert(0, os.path.dirname(__file__))
G, OUT = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)
try:
    from PIL import Image, ImageDraw
    HAVE_PIL = True
except ImportError:
    HAVE_PIL = False
print("PIL:", HAVE_PIL)

# reuse loader from track_analysis by exec of its top part is messy; re-implement compactly
import zlib, collections
def load_dat(path):
    data = zlib.decompress(open(path, 'rb').read(), -15)
    i = 0; n = struct.unpack_from('<i', data, i)[0]; i += 4
    infos = []
    for _ in range(n):
        l = data[i]; i += 1; name = data[i:i + l].decode('latin-1'); i += l; t = data[i]; i += 1; infos.append((name, t))
    blocks = []
    for _ in range(n):
        l = struct.unpack_from('<i', data, i)[0]; i += 4; blocks.append(data[i:i + l]); i += l
    return list(zip(infos, blocks))
level = load_dat(G + '/1.dat')
hm = [b for (nm, t), b in level if t == 3][0]
path_b = [b for (nm, t), b in level if t == 4][0]
ident, version, split, faces = struct.unpack_from('<iiii', hm, 0)
maxx, maxy, maxz, minx, miny, minz = struct.unpack_from('<6f', hm, 16)
off = 40; ftype = []
for k in range(faces):
    ftype.append(struct.unpack_from('<i', hm, off + 20)[0]); off += 24
hinfo = struct.unpack_from('<%dH' % (split * split), hm, off)
dx = (maxx - minx) / split; dz = (maxz - minz) / split
cell_type = [ftype[h] if h < faces else -1 for h in hinfo]
cnt = struct.unpack_from('<i', path_b, 0)[0]
pts = [struct.unpack_from('<ifff', path_b, 4 + k * 16) for k in range(cnt)]
P = [(p[1], p[3]) for p in pts] + [(pts[0][1], pts[0][3])]

def to_cell(x, z):
    return (x - minx) / dx, (z - minz) / dz

if not HAVE_PIL:
    raise SystemExit("PIL missing; install pillow or adapt")

# full map, 2 px per cell, z axis upward (flip)
S = 2
img = Image.new("RGB", (split * S, split * S), (0, 0, 0))
px = img.load()
for cz in range(split):
    for cx in range(split):
        if cell_type[split * cz + cx] == 2:
            for a in range(S):
                for b in range(S):
                    px[cx * S + a, (split - 1 - cz) * S + b] = (200, 200, 200)
d = ImageDraw.Draw(img)
def xy(x, z):
    cx, cz = to_cell(x, z)
    return (cx * S, (split - cz) * S)
for i in range(len(P) - 1):
    d.line([xy(*P[i]), xy(*P[i + 1])], fill=(255, 0, 0), width=1)
for i in range(len(P) - 1):
    x, y = xy(*P[i])
    d.ellipse([x - 2, y - 2, x + 2, y + 2], fill=(0, 120, 255))
    if i % 5 == 0:
        d.text((x + 3, y - 10), str(i), fill=(255, 255, 0))
img.save(os.path.join(OUT, "map_full.png"))
print("saved map_full.png", img.size)

# zoomed corners
corners = [int(c) for c in sys.argv[3].split(",")] if len(sys.argv) > 3 else [45, 79, 85, 94, 101, 108, 110]
Z = 10
for seg in corners:
    cx0, cz0 = to_cell(*P[seg]); cx1, cz1 = to_cell(*P[seg + 1])
    cxm, czm = (cx0 + cx1) / 2, (cz0 + cz1) / 2
    half = 30
    x0, z0 = int(cxm - half), int(czm - half)
    im = Image.new("RGB", (2 * half * Z, 2 * half * Z), (0, 0, 0))
    pz = im.load()
    for cz in range(z0, z0 + 2 * half):
        for cx in range(x0, x0 + 2 * half):
            if 0 <= cx < split and 0 <= cz < split and cell_type[split * cz + cx] == 2:
                for a in range(Z):
                    for b in range(Z):
                        pz[(cx - x0) * Z + a, (2 * half - 1 - (cz - z0)) * Z + b] = (200, 200, 200)
    dd = ImageDraw.Draw(im)
    def zxy(x, z):
        cx, cz = to_cell(x, z)
        return ((cx - x0) * Z, (2 * half - (cz - z0)) * Z)
    for i in range(max(0, seg - 3), min(len(P) - 1, seg + 4)):
        dd.line([zxy(*P[i]), zxy(*P[i + 1])], fill=(255, 0, 0), width=2)
    for i in range(max(0, seg - 3), min(len(P), seg + 5)):
        x, y = zxy(*P[i]); dd.ellipse([x - 4, y - 4, x + 4, y + 4], fill=(0, 120, 255)); dd.text((x + 6, y - 14), "wp%d" % i, fill=(255, 255, 0))
    im.save(os.path.join(OUT, "corner_%03d.png" % seg))
print("saved corner crops for", corners)
