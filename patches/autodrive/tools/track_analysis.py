import sys, zlib, struct, math, collections

G = sys.argv[1]

def load_dat(path):
    data = zlib.decompress(open(path, 'rb').read(), -15)
    i = 0
    n = struct.unpack_from('<i', data, i)[0]; i += 4
    infos = []
    for _ in range(n):
        l = data[i]; i += 1
        name = data[i:i + l].decode('latin-1'); i += l
        t = data[i]; i += 1
        infos.append((name, t))
    blocks = []
    for _ in range(n):
        l = struct.unpack_from('<i', data, i)[0]; i += 4
        blocks.append(data[i:i + l]); i += l
    return list(zip(infos, blocks))

level = load_dat(G + '/1.dat')
common = load_dat(G + '/common.dat')

hm = [b for (nm, t), b in level if t == 3][0]
path_b = [b for (nm, t), b in level if t == 4][0]
car_b = [b for (nm, t), b in common if t == 6]
print("carproperty resources:", len(car_b))
if car_b:
    b = car_b[0]
    ncar = struct.unpack_from('<i', b, 0)[0]
    for k in range(ncar):
        vals = struct.unpack_from('<11f', b, 4 + k * 44)
        names = "accel mass rollfric dragfric steer rfact maxvel minvel maxhandle centfact turnfact".split()
        print("  car style %d: %s" % (k, ", ".join("%s=%.3g" % (n, v) for n, v in zip(names, vals))))

# heightmap
ident, version, split, faces = struct.unpack_from('<iiii', hm, 0)
maxx, maxy, maxz, minx, miny, minz = struct.unpack_from('<6f', hm, 16)
off = 40
face_info = []
for k in range(faces):
    A, B, C, D, fr = struct.unpack_from('<5f', hm, off); typ = struct.unpack_from('<i', hm, off + 20)[0]
    face_info.append((A, B, C, D, fr, typ)); off += 24
height_info = list(struct.unpack_from('<%dH' % (split * split), hm, off))
dx = (maxx - minx) / split; dz = (maxz - minz) / split
print("heightmap: split=%d faces=%d cell=%.1fx%.1f min=(%.0f,%.0f) max=(%.0f,%.0f)" % (split, faces, dx, dz, minx, minz, maxx, maxz))
type_counts = collections.Counter(f[5] for f in face_info)
print("face types:", dict(type_counts))
cell_types = collections.Counter(face_info[h][5] if h < faces else -1 for h in height_info)
print("cell types:", dict(cell_types))

def terrain_type(x, z):
    cx = int(abs(x - minx) / dx); cz = int(abs(z - minz) / dz)
    if cx >= split or cz >= split:
        return -1
    h = height_info[split * cz + cx]
    if h < 0 or h >= faces:
        return -1
    return face_info[h][5]

ROAD = {1, 2, 3, 5, 6, 100}          # start line, asphalt, oil, accel board, sand, mud
SOFT = {4, 101, 200}                 # grass, mount, water (drivable, slow)
def is_bad(t):
    return t not in ROAD and t not in SOFT   # OUT(14), -1, anything unknown -> game resets the car

cnt = struct.unpack_from('<i', path_b, 0)[0]
pts = [struct.unpack_from('<ifff', path_b, 4 + k * 16) for k in range(cnt)]
curve = [p[0] for p in pts]
P = [(p[1], p[3]) for p in pts]
P.append(P[0])
print("path points:", cnt, "curve flags:", collections.Counter(curve))

# 1. chord sampling and corridor width
worst = []
total_bad = 0
for i in range(len(P) - 1):
    (x0, z0), (x1, z1) = P[i], P[i + 1]
    L = math.hypot(x1 - x0, z1 - z0)
    ux, uz = (x1 - x0) / L, (z1 - z0) / L
    nx, nz = -uz, ux
    types = collections.Counter()
    min_clear_l = min_clear_r = 1e9
    bad_on_chord = 0
    s = 0.0
    while s <= L:
        x, z = x0 + ux * s, z0 + uz * s
        t = terrain_type(x, z); types[t] += 1
        if is_bad(t): bad_on_chord += 1
        for sign, store in ((1, 'l'), (-1, 'r')):
            d = 0.0
            while d < 3000:
                tt = terrain_type(x + nx * d * sign, z + nz * d * sign)
                if is_bad(tt): break
                d += 25
            if store == 'l': min_clear_l = min(min_clear_l, d)
            else: min_clear_r = min(min_clear_r, d)
        s += 100
    total_bad += bad_on_chord
    worst.append((min(min_clear_l, min_clear_r), i, L, bad_on_chord, dict(types), min_clear_l, min_clear_r))
print("chord samples on bad terrain (total):", total_bad)
worst.sort()
print("narrowest corridors around chords (clearance to bad terrain, units):")
for w in worst[:15]:
    print("  seg %3d (->wp %3d) len=%6.0f clear L=%5.0f R=%5.0f badOnChord=%d types=%s" % (w[1], w[1] + 1, w[2], w[5], w[6], w[3], w[4]))

# turn angles at waypoints
print("sharpest turns (angle between consecutive segments):")
turns = []
for i in range(1, len(P) - 1):
    ax, az = P[i][0] - P[i - 1][0], P[i][1] - P[i - 1][1]
    bx, bz = P[i + 1][0] - P[i][0], P[i + 1][1] - P[i][1]
    a = math.degrees(math.atan2(ax * bz - az * bx, ax * bx + az * bz))
    turns.append((abs(a), i, math.hypot(ax, az), math.hypot(bx, bz)))
turns.sort(reverse=True)
for t in turns[:12]:
    print("  wp %3d turn %5.1f deg  (in %.0f, out %.0f)" % (t[1], t[0], t[2], t[3]))
