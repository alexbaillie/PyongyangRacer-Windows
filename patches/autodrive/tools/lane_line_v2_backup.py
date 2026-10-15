"""Builds the right-lane driving line for autodrive from the game's terrain mesh and textures,
then simulates the follower with the game's car dynamics.
Outputs plan/lane_line.json, plan/lane_line_as3.txt, plan/lane_map*.png, plan/stations.csv"""
import sys, os, struct, math, heapq, json, zlib, io, collections
from PIL import Image, ImageDraw

G, OUTDIR = sys.argv[1], sys.argv[2]
os.makedirs(OUTDIR, exist_ok=True)

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

# ------------------------------------------------------------------ 1. base route (centre-ish, road-safe)
base = []; base_rerouted = []
for i in range(len(WP)):
    a = WP[i]; b = WP[(i + 1) % len(WP)]
    base.append(a); base_rerouted.append(False)
    if chord_ok(a, b, 300): continue
    route = astar(cell_of(*a), cell_of(*b))
    full = [a] + [center(*c) for c in route[1:-1]] + [b]
    tol = 400
    while True:
        simp = simplify(full, tol)
        if all(chord_ok(simp[k], simp[k + 1], 300) for k in range(len(simp) - 1)) or tol <= 25: break
        tol /= 2
    base_rerouted[-1] = True
    for q in simp[1:-1]:
        base.append(q); base_rerouted.append(True)
nb = len(base)
print("base route points:", nb, "rerouted segments:", sum(base_rerouted))

# ------------------------------------------------------------------ 2. stations at uniform arc length along the base route
STATION = 500.0
seglen = [math.hypot(base[(i + 1) % nb][0] - base[i][0], base[(i + 1) % nb][1] - base[i][1]) for i in range(nb)]
total = sum(seglen)
stations = []; station_rerouted = []
s_target = 0.0; i = 0; acc = 0.0
while s_target < total:
    while acc + seglen[i] < s_target:
        acc += seglen[i]; i += 1
    a, b = base[i], base[(i + 1) % nb]
    f_ = (s_target - acc) / seglen[i]
    stations.append([a[0] + (b[0] - a[0]) * f_, a[1] + (b[1] - a[1]) * f_, 0.0, 0.0])
    station_rerouted.append(base_rerouted[i])
    s_target += STATION
n = len(stations)
# smoothed tangents from neighbouring stations
for k in range(n):
    p0, p1 = stations[(k - 1) % n], stations[(k + 1) % n]
    tx, tz = p1[0] - p0[0], p1[1] - p0[1]; L = math.hypot(tx, tz) or 1.0
    stations[k][2], stations[k][3] = tx / L, tz / L
stations = [tuple(s) for s in stations]
print("stations:", n, "on rerouted stretches:", sum(station_rerouted), "track length %.0f" % total)

# ------------------------------------------------------------------ 3. yellow line & first lane mark per station
YELLOW_HALF = 25.0
DEFAULT_LANE = 460.0
def measure(st, maxoff=450):
    x, z, ux, uz = st
    rx, rz = uz, -ux
    prof = {}
    for offv in range(-900, 2201, 10):
        prof[offv] = texel_class(x + rx * offv, z + rz * offv)
    runs = []; cur = None
    for offv in range(-900, 1301, 10):
        if prof[offv] == "Y":
            if cur and offv - cur[1] <= 60: cur[1] = offv
            else:
                cur = [offv, offv]; runs.append(cur)
    if not runs: return None
    yr = min(runs, key=lambda r: abs((r[0] + r[1]) / 2))
    y0 = (yr[0] + yr[1]) / 2
    if abs(y0) > maxoff or (yr[1] - yr[0]) > 120: return None
    first_w = None
    for offv in range(int(y0) + 120, int(y0) + 1000, 10):
        if offv in prof and prof[offv] == "W":
            first_w = offv; break
    edge = None
    for offv in range(int(y0) + 100, 2201, 10):
        if prof.get(offv) in (".", "o"):
            edge = offv; break
    wlist = []
    prev_w = -1000
    for offv in range(int(y0) + 120, int(y0) + 2001, 10):
        if prof.get(offv) == "W":
            if offv - prev_w > 60:
                wlist.append(offv - y0)
            prev_w = offv
    return y0, first_w, edge, wlist

meas = [measure(st, 900 if rr else 450) for st, rr in zip(stations, station_rerouted)]
print("stations with yellow line: %d / %d" % (sum(1 for m in meas if m), n))
y0s = [m[0] if m else None for m in meas]
rejected = 0
for k in range(n):
    if y0s[k] is None: continue
    neigh = [y0s[(k + j) % n] for j in (-3, -2, -1, 1, 2, 3) if y0s[(k + j) % n] is not None]
    if len(neigh) >= 3:
        med = sorted(neigh)[len(neigh) // 2]
        if abs(y0s[k] - med) > 120:
            meas[k] = None; rejected += 1
print("outlier stations rejected:", rejected)
with open(os.path.join(OUTDIR, "stations.csv"), "w") as fcsv:
    fcsv.write("i,x,z,rerouted,y0,first_w,edge\n")
    for k, (st, m, rr) in enumerate(zip(stations, meas, station_rerouted)):
        fcsv.write("%d,%.0f,%.0f,%d,%s,%s,%s\n" % (k, st[0], st[1], int(rr), m[0] if m else "", m[1] if m else "", m[2] if m else ""))

lane_off = []
for m in meas:
    if m is None:
        lane_off.append(None); continue
    y0, fw, edge, wl = m
    lane_w = DEFAULT_LANE
    if fw is not None and 250 <= fw - y0 <= 700:
        lane_w = fw - (y0 + YELLOW_HALF)
    elif edge is not None and (edge - y0) < 900:
        lane_w = max(250.0, min(DEFAULT_LANE, edge - (y0 + YELLOW_HALF)))
    lane_off.append(y0 + YELLOW_HALF + lane_w / 2.0)
known = [k for k, v in enumerate(lane_off) if v is not None]
for k in range(n):
    if lane_off[k] is None:
        prev = max([q for q in known if q < k], default=None)
        nxt = min([q for q in known if q > k], default=None)
        if prev is None: prev = known[-1] - n
        if nxt is None: nxt = known[0] + n
        a_, b_ = lane_off[prev % n], lane_off[nxt % n]
        t_ = (k - prev) / float(nxt - prev)
        lane_off[k] = a_ + (b_ - a_) * t_
sm = [(lane_off[(k - 1) % n] + lane_off[k] + lane_off[(k + 1) % n]) / 3.0 for k in range(n)]
print("lane offset stats: min %.0f max %.0f mean %.0f" % (min(sm), max(sm), sum(sm) / n))

# ------------------------------------------------------------------ 3b. invisible collision walls (collision.map)
cmap = [b for (nm, t), b in level if nm == 'collision.map'][0]
fc = struct.unpack_from('<iiiiiiiffffffiiiiiiiffffffiiii', cmap, 0)
cGeomOfs, cNumVtxs, cNumTris = fc[2], fc[4], fc[6]
CV = [struct.unpack_from('<fff', cmap, cGeomOfs + k * 12) for k in range(cNumVtxs)]
co = cGeomOfs + cNumVtxs * 12
CTRI = [struct.unpack_from('<HHH', cmap, co + k * 6) for k in range(cNumTris)]
walls = []
for a, b, c in CTRI:
    P3 = [(CV[a][0], CV[a][2]), (CV[b][0], CV[b][2]), (CV[c][0], CV[c][2])]
    best = None
    for i in range(3):
        for j in range(i + 1, 3):
            dd = math.hypot(P3[i][0] - P3[j][0], P3[i][1] - P3[j][1])
            if best is None or dd > best[0]: best = (dd, P3[i], P3[j])
    if best[0] > 1: walls.append((best[1], best[2]))
def seg_dist(p, a, b):
    vx, vz = b[0] - a[0], b[1] - a[1]; L2 = vx * vx + vz * vz
    if L2 == 0: return math.hypot(p[0] - a[0], p[1] - a[1])
    t = max(0.0, min(1.0, ((p[0] - a[0]) * vx + (p[1] - a[1]) * vz) / L2))
    return math.hypot(p[0] - (a[0] + vx * t), p[1] - (a[1] + vz * t))
def wall_clear(p, maxd=1500):
    best = maxd
    for w in walls:
        if min(w[0][0], w[1][0]) - maxd > p[0] or max(w[0][0], w[1][0]) + maxd < p[0]: continue
        if min(w[0][1], w[1][1]) - maxd > p[1] or max(w[0][1], w[1][1]) + maxd < p[1]: continue
        best = min(best, seg_dist(p, w[0], w[1]))
    return best
WALL_MARGIN = 230.0
y0_by_station = [m[0] if m else None for m in meas]
moved = 0
for k in range(n):
    x, z, ux, uz = stations[k]
    pt = (x + uz * sm[k], z - ux * sm[k])
    if wall_clear(pt, 600) >= WALL_MARGIN: continue
    chosen = None
    for delta in (100, 200, 300, 400, 500, 600, 700, 800, -100, -150):
        off = sm[k] + delta
        if y0_by_station[k] is not None and off < y0_by_station[k] + YELLOW_HALF + 100: continue   # never left of the yellow line
        cand = (x + uz * off, z - ux * off)
        if bad(cand[0], cand[1]) or clearance(cand[0], cand[1], 250) < 250: continue
        if wall_clear(cand, 600) >= WALL_MARGIN:
            chosen = delta; break
    if chosen is None: continue
    moved += 1
    for j in range(-3, 4):          # taper the detour over neighbouring stations
        w = 1.0 - abs(j) / 4.0
        kk = (k + j) % n
        sm[kk] = sm[kk] + chosen * w if j != 0 else sm[kk] + chosen
print("stations detoured around collision walls:", moved)
# second pass: push whole chords clear of walls (handles long obstacles and chord ends)
def lane_pt_raw(k):
    x, z, ux, uz = stations[k]
    return (x + uz * sm[k], z - ux * sm[k])
def chord_wall_clear(a, b, step=40):
    L = math.hypot(b[0] - a[0], b[1] - a[1]); steps = max(1, int(L / step)); worst = 1e9
    for q in range(steps + 1):
        p = (a[0] + (b[0] - a[0]) * q / steps, a[1] + (b[1] - a[1]) * q / steps)
        worst = min(worst, wall_clear(p, 600))
        if worst < 1: break
    return worst
def can_offset(k, off):
    x, z, ux, uz = stations[k]
    if y0_by_station[k] is not None and off < y0_by_station[k] + YELLOW_HALF + 100: return False
    cand = (x + uz * off, z - ux * off)
    return not bad(cand[0], cand[1]) and clearance(cand[0], cand[1], 250) >= 250
pushed = 0
for it in range(25):
    changed = 0
    for k in range(n):
        a, b = lane_pt_raw(k), lane_pt_raw((k + 1) % n)
        if chord_wall_clear(a, b) >= WALL_MARGIN: continue
        for kk, step_ in ((k, 80.0), ((k + 1) % n, 80.0), ((k - 1) % n, 40.0), ((k + 2) % n, 40.0)):
            if can_offset(kk, sm[kk] + step_):
                sm[kk] += step_; changed += 1
    pushed += changed
    if not changed: break
print("wall push pass: %d offset adjustments in %d iterations" % (pushed, it + 1))
still = sum(1 for k in range(n) if chord_wall_clear(lane_pt_raw(k), lane_pt_raw((k + 1) % n)) < WALL_MARGIN)
print("station chords still within %.0f of a wall: %d" % (WALL_MARGIN, still))

# ------------------------------------------------------------------ 4. lane points, de-kink, chord safety
def lane_pt(k, scale=1.0):
    x, z, ux, uz = stations[k]
    return (x + uz * sm[k] * scale, z - ux * sm[k] * scale)
keep = list(range(n))
scale = {k: 1.0 for k in keep}
def pts_of(keep): return [lane_pt(k, scale[k]) for k in keep]
# remove reversals / too-close points
for it in range(20):
    P = pts_of(keep); m_ = len(keep); drop = set()
    for j in range(m_):
        a, b, c = P[(j - 1) % m_], P[j], P[(j + 1) % m_]
        if math.hypot(b[0] - a[0], b[1] - a[1]) < 120 or abs(turn_angle(a, b, c)) > 100:
            drop.add(j)
    if not drop: break
    keep = [k for j, k in enumerate(keep) if j not in drop]
print("lane points after de-kink: %d (removed %d)" % (len(keep), n - len(keep)))
CHORD_MIN = 300.0
for it in range(15):
    P = pts_of(keep); m_ = len(keep); changed = 0
    for j in range(m_):
        if not chord_ok(P[j], P[(j + 1) % m_], CHORD_MIN):
            for k in (keep[j], keep[(j + 1) % m_]):
                if scale[k] > 0.0:
                    scale[k] = max(0.0, scale[k] - 0.2); changed += 1
    if not changed: break
lane = pts_of(keep)
print("stations with reduced offset for safety: %d" % sum(1 for k in keep if scale[k] < 1.0))
bad_chords = sum(1 for j in range(len(lane)) if not chord_ok(lane[j], lane[(j + 1) % len(lane)], CHORD_MIN))
print("lane chords below %.0f clearance: %d" % (CHORD_MIN, bad_chords))
kinks = sum(1 for j in range(len(lane)) if abs(turn_angle(lane[(j - 1) % len(lane)], lane[j], lane[(j + 1) % len(lane)])) > 100)
print("remaining reversal kinks:", kinks)
lane_s = simplify(lane + [lane[0]], 30.0)[:-1]
bad_s = sum(1 for j in range(len(lane_s)) if not chord_ok(lane_s[j], lane_s[(j + 1) % len(lane_s)], CHORD_MIN))
if bad_s:
    print("simplified line had %d unsafe chords; using dense line" % bad_s); lane_s = lane
print("lane line points final:", len(lane_s))
yellow = [(st[0] + st[3] * m[0], st[1] - st[2] * m[0]) for st, m in zip(stations, meas) if m]

# overview maps
S = 2
img = Image.new("RGB", (split * S, split * S), (0, 0, 0)); px = img.load()
for cz in range(split):
    for cx in range(split):
        if cell_type[split * cz + cx] == 2:
            for aa in range(S):
                for bb in range(S):
                    px[cx * S + aa, (split - 1 - cz) * S + bb] = (90, 90, 90)
d = ImageDraw.Draw(img)
def xy(x, z): return ((x - minx) / dx * S, (split - (z - minz) / dz) * S)
for i in range(nb): d.line([xy(*base[i]), xy(*base[(i + 1) % nb])], fill=(255, 0, 0), width=1)
for (x, z) in yellow: d.point(xy(x, z), fill=(255, 220, 0))
for i in range(len(lane_s)): d.line([xy(*lane_s[i]), xy(*lane_s[(i + 1) % len(lane_s)])], fill=(0, 255, 0), width=1)
img.save(os.path.join(OUTDIR, "lane_map.png"))
def crop_map(cx_world, cz_world, name, half=20000):
    x0, y0_ = xy(cx_world - half, cz_world + half)
    box = (int(x0), int(y0_), int(x0 + 2 * half / dx * S), int(y0_ + 2 * half / dz * S))
    im = img.crop(box).resize(((box[2] - box[0]) * 8, (box[3] - box[1]) * 8), Image.NEAREST)
    im.save(os.path.join(OUTDIR, name))
for w in (0, 46, 86, 95):
    crop_map(WP[w][0], WP[w][1], "lane_map_wp%02d.png" % w)

# ------------------------------------------------------------------ 5. simulation of the follower
line = lane_s; N = len(line)
def seg(i): return line[i % N], line[(i + 1) % N]
def project(pnt, i):
    a, b = seg(i); vx, vz = b[0] - a[0], b[1] - a[1]; L2 = vx * vx + vz * vz
    if L2 == 0: return 0.0, 0.0
    t = ((pnt[0] - a[0]) * vx + (pnt[1] - a[1]) * vz) / L2
    px_, pz_ = a[0] + vx * t, a[1] + vz * t
    return t, math.hypot(pnt[0] - px_, pnt[1] - pz_)
def point_ahead(i, t, dist):
    a, b = seg(i); L = math.hypot(b[0] - a[0], b[1] - a[1]); rem = L * (1 - max(0.0, min(1.0, t)))
    if dist <= rem:
        f_ = (L - rem + dist) / L; return a[0] + (b[0] - a[0]) * f_, a[1] + (b[1] - a[1]) * f_
    dist -= rem; j = i + 1
    while True:
        a, b = seg(j); L = math.hypot(b[0] - a[0], b[1] - a[1])
        if dist <= L:
            f_ = dist / L; return a[0] + (b[0] - a[0]) * f_, a[1] + (b[1] - a[1]) * f_
        dist -= L; j += 1
def sang(dirx, dirz, tx, tz):
    dd = math.hypot(tx, tz)
    if dd == 0: return 0.0
    tx, tz = tx / dd, tz / dd
    dot = max(-1.0, min(1.0, dirx * tx + dirz * tz)); ang = math.degrees(math.acos(dot))
    cross_y = dirz * tx - dirx * tz
    return ang if cross_y > 0 else -ang
ygrid = collections.defaultdict(list)
for (x, z) in yellow: ygrid[(int(x // 2000), int(z // 2000))].append((x, z))
def dist_to_yellow(x, z):
    best = 1e9; gx, gz = int(x // 2000), int(z // 2000)
    for ax in (-1, 0, 1):
        for az in (-1, 0, 1):
            for (yx, yz) in ygrid.get((gx + ax, gz + az), ()):
                best = min(best, math.hypot(x - yx, z - yz))
    return best

def simulate(params):
    LA_MIN, LA_MAX, LA_K, FAR, COAST_ANG, BRAKE_ANG, HEAD_COAST, HEAD_BRAKE, TURN, TURN_CAP = params
    pos = [line[0][0], line[0][1]]
    a, b = seg(0); pose = math.degrees(math.atan2(b[0] - a[0], b[1] - a[1]))
    vel = [0.0, 0.0]; idx = 0; ticks = 0; out_ticks = 0; clamps = 0
    speeds = []; lat_err = []; min_yellow = 1e9; laps = 0; lastgood = pos[:]
    while ticks < 12 * 60 * 15:
        for _ in range(6):
            t, d = project(pos, idx)
            if t >= 1.0:
                idx += 1
                if idx % N == 0: laps += 1
            else: break
        t, d = project(pos, idx); lat_err.append(d)
        speed = math.hypot(*vel)
        la = max(LA_MIN, min(LA_MAX, speed * LA_K))
        dirx, dirz = math.sin(math.radians(pose)), math.cos(math.radians(pose))
        tgt = point_ahead(idx, t, la)
        ang = sang(dirx, dirz, tgt[0] - pos[0], tgt[1] - pos[1])
        far = point_ahead(idx, t, FAR)
        angf = abs(sang(dirx, dirz, far[0] - pos[0], far[1] - pos[1]))
        pose += max(-TURN_CAP, min(TURN_CAP, ang * TURN))
        if speed > 150 and (angf > BRAKE_ANG or abs(ang) > HEAD_BRAKE): acc = -1
        elif speed > 110 and (angf > COAST_ANG or abs(ang) > HEAD_COAST): acc = 0
        else: acc = 1
        pos[0] += vel[0]; pos[1] += vel[1]
        if bad(pos[0], pos[1]):
            out_ticks += 1; clamps += 1
            sa, sb = seg(idx); sl = math.hypot(sb[0] - sa[0], sb[1] - sa[1])
            tx, tz = (sb[0] - sa[0]) / sl, (sb[1] - sa[1]) / sl
            along = vel[0] * tx + vel[1] * tz
            cand = [lastgood[0] + tx * along, lastgood[1] + tz * along]
            if along > 0 and not bad(cand[0], cand[1]):
                pos = cand; vel = [tx * along * 0.8, tz * along * 0.8]
            else:
                pos = lastgood[:]; vel = [vel[0] * 0.3, vel[1] * 0.3]
        lastgood = pos[:]
        dirx, dirz = math.sin(math.radians(pose)), math.cos(math.radians(pose))
        a_mag = 20.0 if acc == 1 else (-10.0 if acc == -1 else 0.0)
        v2x, v2z = vel[0] + dirx * a_mag, vel[1] + dirz * a_mag
        fdot = v2x * dirx + v2z * dirz; fx, fz = dirx * fdot, dirz * fdot; lx, lz = v2x - fx, v2z - fz
        fx *= 0.95; fz *= 0.95; lx *= 0.2; lz *= 0.2
        vel = [fx + lx, fz + lz]; sp = math.hypot(*vel)
        if sp > 300: vel = [vel[0] * 300 / sp, vel[1] * 300 / sp]; sp = 300
        if sp < 2: vel = [0.0, 0.0]; sp = 0
        speeds.append(sp)
        if ticks % 2 == 0: min_yellow = min(min_yellow, dist_to_yellow(pos[0], pos[1]))
        if os.environ.get("SIMDEBUG") and (ticks % 150 == 0 or (sp < 80 and ticks % 10 == 0)):
            print("  tick %5d idx %3d t %.2f d %6.0f pos (%.0f,%.0f) pose %.1f ang %.1f angf %.1f acc %d sp %.0f" % (
                ticks, idx % N, t, d, pos[0], pos[1], pose % 360, ang, angf, acc, sp))
        ticks += 1
        if laps >= 1: break
    lat_err.sort()
    return dict(lap_s=ticks / 12.0, out_ticks=out_ticks, clamps=clamps, avg_speed=sum(speeds) / len(speeds),
                lat_p50=lat_err[len(lat_err) // 2], lat_p99=lat_err[int(len(lat_err) * 0.99)], lat_max=lat_err[-1],
                min_yellow=min_yellow, finished=laps >= 1, params=params)

candidates = [
    # LA_MIN, LA_MAX, LA_K, FAR, COAST_ANG, BRAKE_ANG, HEAD_COAST, HEAD_BRAKE, TURN, TURN_CAP
    (500, 1100, 3.0, 2200, 28, 50, 18, 35, 0.3, 30),
    (400, 900, 2.5, 2000, 25, 45, 15, 30, 0.35, 30),
    (600, 1300, 3.5, 2400, 30, 55, 20, 40, 0.3, 25),
    (450, 1000, 3.0, 2000, 22, 40, 12, 28, 0.4, 40),
    (350, 800, 2.2, 1800, 25, 45, 15, 30, 0.4, 40),
]
results = []
if os.environ.get("SIMONLY"):
    candidates = [candidates[int(os.environ["SIMONLY"])]]
for pr in candidates:
    r = simulate(pr); results.append(r)
    print("params=%s lap=%.0fs avg=%.0f out=%d lat p50=%.0f p99=%.0f max=%.0f minYellow=%.0f finished=%s" % (
        pr, r['lap_s'], r['avg_speed'], r['out_ticks'], r['lat_p50'], r['lat_p99'], r['lat_max'], r['min_yellow'], r['finished']))

# extra lanes available to the right of lane 1 at each station (for overtaking), 0 where unknown
# number of white marks (lane dashes + edge line) right of the yellow line; dashes are intermittent,
# so take the maximum over a window of neighbouring stations
wcount = [len(m[3]) if m else 0 for m in meas]
extra = []
for k in range(n):
    if meas[k] is None:
        extra.append(0); continue
    best = max(wcount[(k + j) % n] for j in range(-3, 4))
    extra.append(1 if best >= 2 else 0)
print("overtake stage 1 (two or more lane marks right of the yellow line): %d / %d" % (sum(1 for e in extra if e > 0), n))
# a lane-2 position must also be safe terrain; otherwise no overtaking there
stage1 = sum(1 for e in extra if e > 0)
for k in range(n):
    if extra[k] > 0:
        x, z, ux, uz = stations[k]
        # lane-2 centre and 120 units either side of it must be inside the game's road cells
        okk = True
        for extra_off in (-120.0, 0.0, 120.0):
            px_, pz_ = x + uz * (sm[k] + DEFAULT_LANE + extra_off), z - ux * (sm[k] + DEFAULT_LANE + extra_off)
            if bad(px_, pz_):
                okk = False
        if not okk:
            extra[k] = 0
print("overtake stage 2 (lane-2 inside road cells): %d / %d" % (sum(1 for e in extra if e > 0), n))
# only allow overtaking where the next ~1500 units also allow it (no lane-2 dead ends)
extra2 = []
for k in range(n):
    ok = all(extra[(k + j) % n] > 0 for j in range(0, 4))
    extra2.append(1 if ok else 0)
# per line segment: allowed only if at least 90% of the stations along it allow lane 2
NL = len(line)
seg_tot = [0] * NL; seg_ok = [0] * NL
for k in range(n):
    x, z = stations[k][0], stations[k][1]
    bestj, bestd = 0, 1e18
    for j in range(NL):
        a, b = line[j], line[(j + 1) % NL]
        vx, vz = b[0] - a[0], b[1] - a[1]; L2 = vx * vx + vz * vz or 1.0
        tt = max(0.0, min(1.0, ((x - a[0]) * vx + (z - a[1]) * vz) / L2))
        dd = (a[0] + vx * tt - x) ** 2 + (a[1] + vz * tt - z) ** 2
        if dd < bestd: bestd, bestj = dd, j
    seg_tot[bestj] += 1; seg_ok[bestj] += extra2[k]
line_extra = [1 if (seg_tot[j] >= 2 and seg_ok[j] >= 0.9 * seg_tot[j]) else 0 for j in range(NL)]
print("line segments allowing a lane-2 overtake: %d / %d" % (sum(line_extra), NL))

flat = []
for (x, z) in line: flat.append(round(x, 1)); flat.append(round(z, 1))
json.dump({"line": line, "yellow": yellow, "results": results, "lane_off": sm, "extra": line_extra}, open(os.path.join(OUTDIR, "lane_line.json"), "w"))
open(os.path.join(OUTDIR, "lane_line_as3.txt"), "w").write("[" + ",".join(("%g" % v) for v in flat) + "]")
open(os.path.join(OUTDIR, "lane_extra_as3.txt"), "w").write("[" + ",".join(str(v) for v in line_extra) + "]")
print("wrote lane line: %d points" % len(line))
