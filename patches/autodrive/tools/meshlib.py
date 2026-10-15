import sys, os
G = os.environ['PYR_G']
"""Builds the right-lane driving line for autodrive from the game's terrain mesh and textures,
then simulates the follower with the game's car dynamics.
Outputs plan/lane_line.json, plan/lane_line_as3.txt, plan/lane_map*.png, plan/stations.csv"""
import sys, os, struct, math, heapq, json, zlib, io, collections
from PIL import Image, ImageDraw


# ------------------------------------------------------------------ data
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
tex = {nm: b for (nm, t), b in level if t == 10}
tm = [b for (nm, t), b in level if nm == 'terrain.map'][0]
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
KNOWN = {1, 2, 3, 4, 5, 6, 100, 101, 200}
def ttype(x, z):
    cx = int(abs(x - minx) / dx); cz = int(abs(z - minz) / dz)
    if cx >= split or cz >= split: return -1
    h = hinfo[split * cz + cx]
    return ftype[h] if h < faces else -1
def bad(x, z): return ttype(x, z) not in KNOWN
def is_road_cell(cx, cz): return 0 <= cx < split and 0 <= cz < split and cell_type[split * cz + cx] == 2
def cell_of(x, z): return int(abs(x - minx) / dx), int(abs(z - minz) / dz)
def center(cx, cz): return minx + (cx + 0.5) * dx, minz + (cz + 0.5) * dz

f = struct.unpack_from('<iiiiiiiffffffiiiiiiiffffffiiii', tm, 0)
GeomOfs, NumVtxs, NumUvs, NumTris, NumMtls, MtlOfs = f[2], f[4], f[5], f[6], f[13], f[14]
V = [struct.unpack_from('<fff', tm, GeomOfs + k * 12) for k in range(NumVtxs)]
o = GeomOfs + NumVtxs * 12
TRI = [struct.unpack_from('<HHH', tm, o + k * 6) for k in range(NumTris)]
o += NumTris * 6
UV = [struct.unpack_from('<ff', tm, o + k * 8) for k in range(NumUvs)]
mats = []; tri_mat = {}
p = MtlOfs
for m in range(NumMtls):
    polyofs, numpolys, c = struct.unpack_from('<iii', tm, p)
    name = tm[p + 12:p + 112].split(b'\0')[0].decode('latin-1')
    p = p + 112 + 4
    idx = struct.unpack_from('<%dH' % numpolys, tm, polyofs)
    mats.append(name)
    for t in idx: tri_mat[t] = m
images = {}
def get_img(name):
    if name not in images:
        try: images[name] = Image.open(io.BytesIO(tex[name])).convert("RGB")
        except Exception: images[name] = None
    return images[name]
CELL = 2000.0
grid = collections.defaultdict(list); tri_bbox = []
for t, (a, b, c) in enumerate(TRI):
    xs = (V[a][0], V[b][0], V[c][0]); zs = (V[a][2], V[b][2], V[c][2])
    bb = (min(xs), min(zs), max(xs), max(zs)); tri_bbox.append(bb)
    for gx in range(int(bb[0] // CELL), int(bb[2] // CELL) + 1):
        for gz in range(int(bb[1] // CELL), int(bb[3] // CELL) + 1):
            grid[(gx, gz)].append(t)
def locate(x, z):
    for t in grid.get((int(x // CELL), int(z // CELL)), ()):
        bb = tri_bbox[t]
        if x < bb[0] or x > bb[2] or z < bb[1] or z > bb[3]: continue
        a, b, c = TRI[t]
        ax, az = V[a][0], V[a][2]; bx, bz = V[b][0], V[b][2]; cx, cz = V[c][0], V[c][2]
        det = (bx - ax) * (cz - az) - (cx - ax) * (bz - az)
        if abs(det) < 1e-6: continue
        l1 = ((bx - x) * (cz - z) - (cx - x) * (bz - z)) / det
        l2 = ((cx - x) * (az - z) - (ax - x) * (cz - z)) / det
        l3 = 1 - l1 - l2
        if l1 >= -1e-6 and l2 >= -1e-6 and l3 >= -1e-6: return t, (l1, l2, l3)
    return None, None
def texel_class(x, z):
    t, bary = locate(x, z)
    if t is None: return "."
    m = tri_mat.get(t)
    if m is None: return "."
    img = get_img(mats[m])
    if img is None: return "."
    a, b, c = TRI[t]
    u = UV[a][0] * bary[0] + UV[b][0] * bary[1] + UV[c][0] * bary[2]
    v = UV[a][1] * bary[0] + UV[b][1] * bary[1] + UV[c][1] * bary[2]
    w, h = img.size
    r, g, bl = img.getpixel((int((u % 1.0) * w) % w, int((v % 1.0) * h) % h))
    if r > 170 and g > 130 and bl < 110 and r - bl > 90: return "Y"
    if r > 190 and g > 190 and bl > 190: return "W"
    if abs(r - g) < 25 and abs(g - bl) < 25 and 60 < r < 190: return "g"
    return "o"

cnt = struct.unpack_from('<i', path_b, 0)[0]
pts = [struct.unpack_from('<ifff', path_b, 4 + k * 16) for k in range(cnt)]
WP = [(q[1], q[3]) for q in pts]

# ------------------------------------------------------------------ geometry helpers
def clearance(x, z, maxd=1500, step=25):
    best = maxd
    for ux, uz in ((1, 0), (0, 1), (0.7071, 0.7071), (0.7071, -0.7071)):
        for sgn in (1, -1):
            d = 0.0
            while d < maxd:
                if bad(x + ux * d * sgn, z + uz * d * sgn): break
                d += step
            best = min(best, d)
    return best
def chord_ok(a, b, minc, step=50):
    L = math.hypot(b[0] - a[0], b[1] - a[1])
    if L == 0: return True
    ux, uz = (b[0] - a[0]) / L, (b[1] - a[1]) / L
    s = 0.0
    while s <= L:
        x, z = a[0] + ux * s, a[1] + uz * s
        if bad(x, z) or clearance(x, z, minc) < minc: return False
        s += step
    return True
def astar(c0, c1):
    def h(c): return math.hypot((c[0] - c1[0]) * dx, (c[1] - c1[1]) * dz)
    openq = [(h(c0), 0.0, c0, None)]; came = {}; gbest = {c0: 0.0}
    while openq:
        f_, g, c, parent = heapq.heappop(openq)
        if c in came: continue
        came[c] = parent
        if c == c1: break
        for ddx in (-1, 0, 1):
            for ddz in (-1, 0, 1):
                if ddx == 0 and ddz == 0: continue
                n = (c[0] + ddx, c[1] + ddz)
                if not is_road_cell(*n): continue
                if ddx != 0 and ddz != 0 and not (is_road_cell(c[0] + ddx, c[1]) and is_road_cell(c[0], c[1] + ddz)): continue
                stepcost = math.hypot(ddx * dx, ddz * dz); pen = 0.0
                for ex, ez in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    if not is_road_cell(n[0] + ex, n[1] + ez): pen += 0.35 * stepcost
                ng = g + stepcost + pen
                if ng < gbest.get(n, 1e18):
                    gbest[n] = ng; heapq.heappush(openq, (ng + h(n), ng, n, c))
    if c1 not in came: return None
    out = []; c = c1
    while c is not None: out.append(c); c = came[c]
    return out[::-1]
def simplify(points, tol):
    if len(points) <= 2: return points[:]
    a, b = points[0], points[-1]
    L = math.hypot(b[0] - a[0], b[1] - a[1]); far_i, far_d = 0, -1
    for i in range(1, len(points) - 1):
        q = points[i]
        d = math.hypot(q[0] - a[0], q[1] - a[1]) if L == 0 else abs((b[0] - a[0]) * (a[1] - q[1]) - (a[0] - q[0]) * (b[1] - a[1])) / L
        if d > far_d: far_i, far_d = i, d
    if far_d > tol:
        return simplify(points[:far_i + 1], tol)[:-1] + simplify(points[far_i:], tol)
    return [a, b]
def turn_angle(a, b, c):
    ax, az = b[0] - a[0], b[1] - a[1]; bx, bz = c[0] - b[0], c[1] - b[1]
    return math.degrees(math.atan2(ax * bz - az * bx, ax * bx + az * bz))

