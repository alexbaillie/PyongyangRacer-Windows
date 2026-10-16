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
def catmull(p0, p1, p2, p3, t):
    t2, t3 = t * t, t * t * t
    return tuple(0.5 * ((2 * p1[i]) + (-p0[i] + p2[i]) * t + (2 * p0[i] - 5 * p1[i] + 4 * p2[i] - p3[i]) * t2 + (-p0[i] + 3 * p1[i] - 3 * p2[i] + p3[i]) * t3) for i in (0, 1))
dense = []; dense_rr = []
for i in range(nb):
    p0, p1, p2, p3 = base[(i - 1) % nb], base[i], base[(i + 1) % nb], base[(i + 2) % nb]
    L = math.hypot(p2[0] - p1[0], p2[1] - p1[1]); steps = max(1, int(L / 100))
    use_spline = (not base_rerouted[i]) and (not base_rerouted[(i + 1) % nb]) and abs(turn_angle(p0, p1, p2)) < 35 and abs(turn_angle(p1, p2, p3)) < 35
    for q in range(steps):
        f_ = q / float(steps)
        dense.append(catmull(p0, p1, p2, p3, f_) if use_spline else (p1[0] + (p2[0] - p1[0]) * f_, p1[1] + (p2[1] - p1[1]) * f_))
        dense_rr.append(base_rerouted[i])
nd = len(dense)
dlen = [math.hypot(dense[(i + 1) % nd][0] - dense[i][0], dense[(i + 1) % nd][1] - dense[i][1]) for i in range(nd)]
total = sum(dlen)
stations = []; station_rerouted = []
s_target = 0.0; i = 0; acc = 0.0
while s_target < total:
    while acc + dlen[i] < s_target:
        acc += dlen[i]; i += 1
    p, q_ = dense[i], dense[(i + 1) % nd]
    f_ = (s_target - acc) / dlen[i] if dlen[i] > 0 else 0.0
    stations.append((p[0] + (q_[0] - p[0]) * f_, p[1] + (q_[1] - p[1]) * f_))
    station_rerouted.append(dense_rr[i])
    s_target += STATION
n = len(stations)
def tangents_for(sts):
    nn = len(sts); out = []
    for k in range(nn):
        p0, p1 = sts[(k - 1) % nn], sts[(k + 1) % nn]
        tx, tz = p1[0] - p0[0], p1[1] - p0[1]; L = math.hypot(tx, tz) or 1.0
        out.append((sts[k][0], sts[k][1], tx / L, tz / L))
    return out
stations = tangents_for(stations)
print("stations:", n, "on rerouted stretches:", sum(station_rerouted), "track length %.0f" % total)

# ------------------------------------------------------------------ 3. yellow line & first lane mark per station
YELLOW_HALF = 25.0
DEFAULT_LANE = 460.0
ANCHOR = float(os.environ.get('ANCHOR', '135'))   # car centre sits this far right of the yellow line's edge
SHIFT = 600.0                                      # lane-1 to lane-2 distance when overtaking
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

def solve_offsets(sts, maxoffs):
    meas_ = [measure(st, maxoffs[k]) for k, st in enumerate(sts)]
    nn = len(sts)
    y0s_ = [m[0] if m else None for m in meas_]
    rej = 0
    for k in range(nn):
        if y0s_[k] is None: continue
        neigh = [y0s_[(k + j) % nn] for j in (-3, -2, -1, 1, 2, 3) if y0s_[(k + j) % nn] is not None]
        if len(neigh) >= 3:
            med = sorted(neigh)[len(neigh) // 2]
            if abs(y0s_[k] - med) > 120:
                meas_[k] = None; rej += 1
    lo = []
    for m in meas_:
        if m is None:
            lo.append(None); continue
        y0, fw, edge, wl = m
        lane_w = DEFAULT_LANE
        if fw is not None and 250 <= fw - y0 <= 700:
            lane_w = fw - (y0 + YELLOW_HALF)
        elif edge is not None and (edge - y0) < 900:
            lane_w = max(250.0, min(DEFAULT_LANE, edge - (y0 + YELLOW_HALF)))
        lo.append(y0 + YELLOW_HALF + min(ANCHOR, lane_w / 2.0))
    kn = [k for k, v in enumerate(lo) if v is not None]
    for k in range(nn):
        if lo[k] is None:
            prev = max([q for q in kn if q < k], default=None)
            nxt = min([q for q in kn if q > k], default=None)
            if prev is None: prev = kn[-1] - nn
            if nxt is None: nxt = kn[0] + nn
            a_, b_ = lo[prev % nn], lo[nxt % nn]
            lo[k] = a_ + (b_ - a_) * ((k - prev) / float(nxt - prev))
    sm_ = [(lo[(k - 1) % nn] + lo[k] + lo[(k + 1) % nn]) / 3.0 for k in range(nn)]
    print("  measured %d / %d stations, rejected %d outliers" % (sum(1 for m in meas_ if m), nn, rej))
    return meas_, sm_

meas, sm = solve_offsets(stations, [900 if rr else 450 for rr in station_rerouted])
for refine_it in range(2):
    centred = []
    for k in range(n):
        x, z, ux, uz = stations[k]
        y0e = meas[k][0] if meas[k] is not None else (sm[k] - YELLOW_HALF - ANCHOR)
        centred.append((x + uz * y0e, z - ux * y0e))
    stations = tangents_for(centred)
    print("re-centred stations on the yellow line (pass %d)" % (refine_it + 1))
    meas, sm = solve_offsets(stations, [300] * n)
with open(os.path.join(OUTDIR, "stations.csv"), "w") as fcsv:
    fcsv.write("i,x,z,rerouted,y0,first_w,edge\n")
    for k, (st, m, rr) in enumerate(zip(stations, meas, station_rerouted)):
        fcsv.write("%d,%.0f,%.0f,%d,%s,%s,%s\n" % (k, st[0], st[1], int(rr), m[0] if m else "", m[1] if m else "", m[2] if m else ""))
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
        if y0_by_station[k] is not None and off < y0_by_station[k] + YELLOW_HALF + 80: continue   # never left of the yellow line
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
    if y0_by_station[k] is not None and off < y0_by_station[k] + YELLOW_HALF + 80: return False
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
nstat = len(lane)

# ------------------------------------------------------------------ 4b. raster repair of corners (curbs, grass, junction corners)
import numpy as np
from scipy.ndimage import distance_transform_edt
Rz = np.load(os.path.join(OUTDIR, "raster.npz"))
rcls, roob, RX0, RZ0, RRES = Rz["cls"], Rz["oob"], float(Rz["X0"]), float(Rz["Z0"]), float(Rz["RES"])
drv = ((rcls == 1) | (rcls == 2) | (rcls == 3)) & (roob == 0)
clrm = (distance_transform_edt(drv) * RRES).astype(np.float32)
ydm = (distance_transform_edt(rcls != 2) * RRES).astype(np.float32)
RNZ, RNX = rcls.shape
def rix(x, z): return int((z - RZ0) / RRES), int((x - RX0) / RRES)
def rclr(x, z):
    iz, ix = rix(x, z)
    return float(clrm[iz, ix]) if 0 <= iz < RNZ and 0 <= ix < RNX else 0.0
def rydist(x, z):
    iz, ix = rix(x, z)
    return float(ydm[iz, ix]) if 0 <= iz < RNZ and 0 <= ix < RNX else 99999.0
def rpos(iz, ix): return RX0 + (ix + 0.5) * RRES, RZ0 + (iz + 0.5) * RRES
from scipy import ndimage as ndi
def detect_circles():
    lab, nl_ = ndi.label(rcls == 3, structure=np.ones((3, 3)))
    out = []
    for i_, sl in enumerate(ndi.find_objects(lab), 1):
        h = sl[0].stop - sl[0].start; w = sl[1].stop - sl[1].start
        if not (6 <= h <= 24 and 6 <= w <= 24) or abs(h - w) > 3: continue
        comp = (lab[sl] == i_)
        cy, cx = h // 2, w // 2
        if comp[cy - 1:cy + 2, cx - 1:cx + 2].sum() != 0 or comp.sum() > 0.75 * h * w: continue
        out.append((RX0 + (sl[1].start + w / 2.0) * RRES, RZ0 + (sl[0].start + h / 2.0) * RRES, (h + w) / 4.0 * RRES))
    return out
circles = detect_circles()
print("roundabout rings detected:", len(circles))
CIRCLE_KEEP = 0.0     # the car's centre stays at least this far from a ring's centre (ring radius ~462 plus margin)
CIRCLE_ZONE = 4200.0    # stations this close to a ring belong to its junction window
def circ_dist(x, z): return min([math.hypot(x - c[0], z - c[1]) for c in circles] or [1e9])
CLR_BAD = float(os.environ.get("CLR_BAD", "450"))      # a lane point closer than this to a curb / out-of-bounds is repaired
CLR_PREF = 700.0
CLR_MIN = 450.0
YELLOW_MIN = 45.0
print("raster loaded; drivable cells: %d" % int(drv.sum()))
def wrong_side(j, rad=5):
    p0, p1 = lane[(j - 1) % nstat], lane[(j + 1) % nstat]
    ux_, uz_ = p1[0] - p0[0], p1[1] - p0[1]; L_ = math.hypot(ux_, uz_) or 1.0
    ux_, uz_ = ux_ / L_, uz_ / L_
    x, z = lane[j]; iz, ix = rix(x, z)
    iz_lo, ix_lo = max(0, iz - rad), max(0, ix - rad)
    sub = rcls[iz_lo:iz + rad + 1, ix_lo:ix + rad + 1]
    zs, xs = np.nonzero(sub == 2)
    for zz, xx in zip(zs, xs):
        cx_, cz_ = rpos(iz_lo + int(zz), ix_lo + int(xx))
        d_ = math.hypot(cx_ - x, cz_ - z)
        if d_ > rad * RRES: continue
        lat_ = (cx_ - x) * uz_ - (cz_ - z) * ux_          # > 0: yellow is on our right
        if lat_ > -30: return True
    return False
flags = [rclr(*lane[j]) < CLR_BAD or rydist(*lane[j]) < YELLOW_MIN or wrong_side(j) or circ_dist(*lane[j]) < CIRCLE_ZONE for j in range(nstat)]
print("lane stations flagged for repair:", sum(flags))
for j in [q for q in range(nstat) if flags[q]][:60:3]:
    print("   flagged station %d at (%.0f,%.0f) clr=%.0f ydist=%.0f off=%.0f" % (j, lane[j][0], lane[j][1], rclr(*lane[j]), rydist(*lane[j]), sm[j]))
exp = [False] * nstat
for j in range(nstat):
    if flags[j]:
        for q in range(-3, 4): exp[(j + q) % nstat] = True
runs = []
start = next((j for j in range(nstat) if not exp[j]), None)
if start is None: raise SystemExit("whole lap flagged")
cur = None
for q in range(nstat):
    j = (start + q) % nstat
    if exp[j]:
        if cur is None:
            cur = [j, j]; runs.append(cur)
        else: cur[1] = j
    else: cur = None
print("repair windows (station index ranges):", runs)

def resample(poly, step):
    out = [poly[0]]; acc = 0.0
    for i in range(1, len(poly)):
        a, b = poly[i - 1], poly[i]; L = math.hypot(b[0] - a[0], b[1] - a[1])
        pos = step - acc
        while pos <= L:
            f_ = pos / L; out.append((a[0] + (b[0] - a[0]) * f_, a[1] + (b[1] - a[1]) * f_)); pos += step
        acc = (acc + L) % step if L > 0 else acc
    if math.hypot(out[-1][0] - poly[-1][0], out[-1][1] - poly[-1][1]) > step * 0.3: out.append(poly[-1])
    else: out[-1] = poly[-1]
    return out

def raster_astar(p0, p1, clr_min, margin=7000.0, yel_forbid=60.0):
    x_lo, x_hi = min(p0[0], p1[0]) - margin, max(p0[0], p1[0]) + margin
    z_lo, z_hi = min(p0[1], p1[1]) - margin, max(p0[1], p1[1]) + margin
    iz0, ix0 = rix(x_lo, z_lo); iz1, ix1 = rix(x_hi, z_hi)
    iz0, ix0 = max(0, iz0), max(0, ix0); iz1, ix1 = min(RNZ - 1, iz1), min(RNX - 1, ix1)
    sub_clr = clrm[iz0:iz1 + 1, ix0:ix1 + 1]; sub_y = ydm[iz0:iz1 + 1, ix0:ix1 + 1]
    allowed = (sub_clr >= clr_min) & (sub_y >= yel_forbid)
    gx_ = RX0 + (np.arange(ix0, ix1 + 1) + 0.5) * RRES; gz_ = RZ0 + (np.arange(iz0, iz1 + 1) + 0.5) * RRES
    for c_ in circles:
        if c_[0] < x_lo - 2000 or c_[0] > x_hi + 2000 or c_[1] < z_lo - 2000 or c_[1] > z_hi + 2000: continue
        allowed &= ((gx_[None, :] - c_[0]) ** 2 + (gz_[:, None] - c_[1]) ** 2) >= CIRCLE_KEEP ** 2
    mult = 1.0 + 6.0 * np.clip((CLR_PREF - sub_clr) / CLR_PREF, 0, 1) ** 2 + np.where(sub_y < 60, 25.0, 0.0)
    H, W = allowed.shape
    def cell(p):
        iz, ix = rix(*p); return (iz - iz0, ix - ix0)
    s, g = cell(p0), cell(p1)
    def nearest_allowed(c):
        if 0 <= c[0] < H and 0 <= c[1] < W and allowed[c]: return c
        for rad in range(1, 12):
            for dz_ in range(-rad, rad + 1):
                for dx_ in range(-rad, rad + 1):
                    cc = (c[0] + dz_, c[1] + dx_)
                    if 0 <= cc[0] < H and 0 <= cc[1] < W and allowed[cc]: return cc
        return None
    s, g = nearest_allowed(s), nearest_allowed(g)
    if s is None or g is None: return None
    openq = [(0.0, 0.0, s, None)]; came = {}; gbest = {s: 0.0}
    nbrs = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
    while openq:
        f_, gcost, c, par = heapq.heappop(openq)
        if c in came: continue
        came[c] = par
        if c == g: break
        for dz_, dx_ in nbrs:
            n_ = (c[0] + dz_, c[1] + dx_)
            if not (0 <= n_[0] < H and 0 <= n_[1] < W) or not allowed[n_]: continue
            st = math.hypot(dz_, dx_) * RRES
            ng = gcost + st * float(mult[n_])
            if ng < gbest.get(n_, 1e18):
                gbest[n_] = ng
                hh = math.hypot(n_[0] - g[0], n_[1] - g[1]) * RRES
                heapq.heappush(openq, (ng + hh, ng, n_, c))
    if g not in came: return None
    path = []; c = g
    while c is not None:
        path.append(rpos(c[0] + iz0, c[1] + ix0)); c = came[c]
    return path[::-1]

def smooth_path(poly, nfix_a, nfix_b, iters=200):
    P = [list(p) for p in poly]; m_ = len(P)
    for it in range(iters):
        newP = [p[:] for p in P]
        for i in range(nfix_a, m_ - nfix_b):
            cx_ = 0.5 * P[i][0] + 0.25 * (P[i - 1][0] + P[i + 1][0]); cz_ = 0.5 * P[i][1] + 0.25 * (P[i - 1][1] + P[i + 1][1])
            if rclr(cx_, cz_) >= CLR_MIN and rydist(cx_, cz_) >= YELLOW_MIN and circ_dist(cx_, cz_) >= CIRCLE_KEEP: newP[i] = [cx_, cz_]
        P = newP
    return [tuple(p) for p in P]

def side_bad(p, u):
    """True when point p (travelling along u) is on or beyond the yellow line, too close to a curb, or off the road."""
    if rclr(*p) < CLR_MIN or rydist(*p) < YELLOW_MIN or circ_dist(*p) < CIRCLE_KEEP: return True
    x, z = p; iz, ix = rix(x, z); rad = 5
    iz_lo, ix_lo = max(0, iz - rad), max(0, ix - rad)
    sub = rcls[iz_lo:iz + rad + 1, ix_lo:ix + rad + 1]
    zs, xs = np.nonzero(sub == 2)
    for zz, xx in zip(zs, xs):
        cx_, cz_ = rpos(iz_lo + int(zz), ix_lo + int(xx))
        if math.hypot(cx_ - x, cz_ - z) > rad * RRES: continue
        if (cx_ - x) * u[1] - (cz_ - z) * u[0] > -30: return True
    return False

def fillet_path(ia, ib, t_cap=None):
    a1 = lane[ia]; b0 = lane[ib]
    d1 = (stations[keep[ia]][2], stations[keep[ia]][3]); d2 = (stations[keep[ib]][2], stations[keep[ib]][3])
    cr = d1[0] * d2[1] - d1[1] * d2[0]
    if abs(cr) < 1e-3:
        print('     fillet: parallel arms'); return None
    # intersection of  a1 + s*d1  with  b0 + u*d2
    s_ = ((b0[0] - a1[0]) * d2[1] - (b0[1] - a1[1]) * d2[0]) / cr
    u_ = ((b0[0] - a1[0]) * d1[1] - (b0[1] - a1[1]) * d1[0]) / cr
    if s_ <= 50 or u_ >= -50:
        print('     fillet: corner not ahead (s=%.0f u=%.0f)' % (s_, u_)); return None
    P = (a1[0] + d1[0] * s_, a1[1] + d1[1] * s_)
    th = math.acos(max(-1.0, min(1.0, d1[0] * d2[0] + d1[1] * d2[1])))
    if th < math.radians(12) or th > math.radians(160):
        print('     fillet: turn angle %.0f deg out of range' % math.degrees(th)); return None
    t_avail = min(s_, -u_)
    if t_cap is not None: t_avail = min(t_avail, t_cap)
    r_max = t_avail / math.tan(th / 2)
    sign = 1.0 if cr > 0 else -1.0       # cr>0: counter-clockwise in (x,z)
    for frac in (1.0, 0.85, 0.7, 0.55, 0.42, 0.32, 0.25, 0.18, 0.12):
        r = min(r_max * frac, 6000.0)
        if r < 250: break
        t = r * math.tan(th / 2)
        T1 = (P[0] - d1[0] * t, P[1] - d1[1] * t); T2 = (P[0] + d2[0] * t, P[1] + d2[1] * t)
        # centre of the arc: from T1 move perpendicular to d1 towards the turn side
        nrm = (-d1[1] * sign, d1[0] * sign)
        C = (T1[0] + nrm[0] * r, T1[1] + nrm[1] * r)
        ang1 = math.atan2(T1[1] - C[1], T1[0] - C[0]); ang2 = math.atan2(T2[1] - C[1], T2[0] - C[0])
        dang = ang2 - ang1
        while dang * sign < 0: dang += sign * 2 * math.pi
        while abs(dang) > math.pi: dang -= sign * 2 * math.pi
        nseg = max(3, int(abs(dang) * r / 120))
        arc = [(C[0] + r * math.cos(ang1 + dang * q / nseg), C[1] + r * math.sin(ang1 + dang * q / nseg)) for q in range(nseg + 1)]
        pts = [a1, T1] + arc[1:-1] + [T2, b0]
        # validate along the whole path
        okp = True; why_ = []
        for i_ in range(len(pts) - 1):
            pa, pb = pts[i_], pts[i_ + 1]; Lq = math.hypot(pb[0] - pa[0], pb[1] - pa[1])
            if Lq < 1: continue
            u = ((pb[0] - pa[0]) / Lq, (pb[1] - pa[1]) / Lq); kq = max(1, int(Lq / 60))
            for q in range(kq + 1):
                pp = (pa[0] + (pb[0] - pa[0]) * q / kq, pa[1] + (pb[1] - pa[1]) * q / kq)
                if side_bad(pp, u) or wall_clear(pp, 400) < 230:
                    okp = False; why_.append('curb %.0f yel %.0f at (%.0f,%.0f)' % (rclr(*pp), rydist(*pp), pp[0], pp[1])); break
            if not okp: break
        if okp:
            return [T1] + arc[1:-1] + [T2], r
        print('     fillet: r=%.0f rejected (%s)' % (r, why_[0] if why_ else '?'))
    return None

def bezier_pts(p0, t0, p3, t3, k=0.38):
    Ld = math.hypot(p3[0] - p0[0], p3[1] - p0[1]); kk = Ld * k
    p1 = (p0[0] + t0[0] * kk, p0[1] + t0[1] * kk); p2 = (p3[0] - t3[0] * kk, p3[1] - t3[1] * kk)
    nq = max(6, int(Ld / 150)); out = []
    for q in range(nq + 1):
        u = q / float(nq); w = 1 - u
        out.append((w ** 3 * p0[0] + 3 * w * w * u * p1[0] + 3 * w * u * u * p2[0] + u ** 3 * p3[0],
                    w ** 3 * p0[1] + 3 * w * w * u * p1[1] + 3 * w * u * u * p2[1] + u ** 3 * p3[1]))
    return out

def roundabout_path(ia, ib, c, extra_r=330.0):
    """Entry curve -> counter-clockwise circulation around the ring -> exit curve (right-hand traffic)."""
    Cx, Cz, Rc = c; Rt = Rc + extra_r
    a1 = lane[ia]; a0 = lane[(ia - 2) % nstat]; b0 = lane[ib]; b1 = lane[(ib + 2) % nstat]
    d1 = (stations[keep[ia]][2], stations[keep[ia]][3]); d2 = (stations[keep[ib]][2], stations[keep[ib]][3])   # yellow-line headings
    e1 = (a1[0] - Cx) * d1[1] - (a1[1] - Cz) * d1[0]          # lateral offset of the entry lane, right of the ring's axis
    e2 = (b0[0] - Cx) * d2[1] - (b0[1] - Cz) * d2[0]
    e1 = max(120.0, min(0.8 * Rt, e1)); e2 = max(120.0, min(0.8 * Rt, e2))
    psi1 = math.atan2(d1[1], d1[0]); psi2 = math.atan2(d2[1], d2[0])
    phiE = psi1 - math.pi / 2 - math.acos(e1 / Rt)
    phiX = psi2 - math.pi / 2 + math.acos(e2 / Rt)
    dphi = (phiX - phiE) % (2 * math.pi)
    E = (Cx + Rt * math.cos(phiE), Cz + Rt * math.sin(phiE)); X = (Cx + Rt * math.cos(phiX), Cz + Rt * math.sin(phiX))
    tE = (-math.sin(phiE), math.cos(phiE)); tX = (-math.sin(phiX), math.cos(phiX))
    nseg = max(2, int(dphi * Rt / 120))
    arc = [(Cx + Rt * math.cos(phiE + dphi * q / nseg), Cz + Rt * math.sin(phiE + dphi * q / nseg)) for q in range(nseg + 1)]
    entry = bezier_pts(a1, d1, E, tE); exit_ = bezier_pts(X, tX, b0, d2)
    pts = entry[:-1] + arc + exit_[1:]
    return pts, math.degrees(dphi)

def path_invalid(pts, why=None, ignore=()):
    bad_n = 0
    for q in range(len(pts) - 1):
        u = (pts[q + 1][0] - pts[q][0], pts[q + 1][1] - pts[q][1]); Lq = math.hypot(*u) or 1.0
        Ls = max(1, int(Lq / 60))
        for r_ in range(Ls):
            pp = (pts[q][0] + u[0] * r_ / Ls, pts[q][1] + u[1] * r_ / Ls)
            un = (u[0] / Lq, u[1] / Lq)
            reasons = []
            if rclr(*pp) < CLR_MIN: reasons.append("curb")
            if rydist(*pp) < YELLOW_MIN: reasons.append("yellow")
            if circ_dist(*pp) < CIRCLE_KEEP: reasons.append("ring")
            if wall_clear(pp, 400) < 230: reasons.append("wall")
            if not reasons and 'wrongside' not in ignore and side_bad(pp, un): reasons.append("wrongside")
            reasons = [r_ for r_ in reasons if r_ not in ignore]
            if reasons:
                bad_n += 1
                if why is not None: why.append((reasons, pp))
    return bad_n

# reset the approach/exit points of every window onto the ideal lane (yellow line + offset), so the repaired
# path starts and ends on a clean straight lane instead of on a noisy interpolated offset
def ideal_lane_pt(q):
    sx, sz, ux_, uz_ = stations[keep[q % nstat]]
    return (sx + uz_ * (YELLOW_HALF + ANCHOR), sz - ux_ * (YELLOW_HALF + ANCHOR))
for (ws, we) in runs:
    for q in range(ws - 3, ws):
        lane[q % nstat] = ideal_lane_pt(q)
    for q in range(we + 1, we + 4):
        lane[q % nstat] = ideal_lane_pt(q)

def arm_axis(C, hint_pt, travel_toward_C):
    """Fit the yellow centre line of the road arm that leaves circle C towards hint_pt. Returns (point on lane line, heading) or None."""
    hx, hz = hint_pt[0] - C[0], hint_pt[1] - C[1]; hl = math.hypot(hx, hz) or 1.0; hx, hz = hx / hl, hz / hl
    r_lo, r_hi = 2400.0, 6500.0
    iz0, ix0 = rix(C[0] - r_hi, C[1] - r_hi); iz1, ix1 = rix(C[0] + r_hi, C[1] + r_hi)
    iz0, ix0 = max(0, iz0), max(0, ix0); iz1, ix1 = min(RNZ - 1, iz1), min(RNX - 1, ix1)
    zs, xs = np.nonzero(rcls[iz0:iz1 + 1, ix0:ix1 + 1] == 2)
    px_ = RX0 + (xs + ix0 + 0.5) * RRES - C[0]; pz_ = RZ0 + (zs + iz0 + 0.5) * RRES - C[1]
    dist_ = np.hypot(px_, pz_)
    sel = (dist_ >= r_lo) & (dist_ <= r_hi) & ((px_ * hx + pz_ * hz) >= 0.93 * dist_)
    if sel.sum() < 12: return None
    X = np.stack([px_[sel], pz_[sel]], axis=1); cen = X.mean(axis=0)
    u_, s_, vt_ = np.linalg.svd(X - cen, full_matrices=False)
    dirv = vt_[0]
    if dirv[0] * hx + dirv[1] * hz < 0: dirv = -dirv        # pointing away from the circle
    if travel_toward_C: dirv = -dirv
    return (C[0] + cen[0], C[1] + cen[1]), (float(dirv[0]), float(dirv[1]))

def junction_path(ia, ib, c, t_cap=1800.0):
    """Run along the right-hand lane to the circle, then one smooth arc into the exit road (no circulation)."""
    C = (c[0], c[1])
    A = arm_axis(C, lane[ia], True); B = arm_axis(C, lane[ib], False)
    if A is None or B is None: print("     junction: yellow axis not found"); return None
    (ay, d1), (by, d2) = A, B
    off = YELLOW_HALF + ANCHOR
    L1 = (ay[0] + d1[1] * off, ay[1] - d1[0] * off); L2 = (by[0] + d2[1] * off, by[1] - d2[0] * off)
    cr = d1[0] * d2[1] - d1[1] * d2[0]
    th = math.acos(max(-1.0, min(1.0, d1[0] * d2[0] + d1[1] * d2[1])))
    if th < math.radians(12) or th > math.radians(165) or abs(cr) < 1e-3:
        print("     junction: turn angle %.0f deg, not a turn" % math.degrees(th)); return None
    s_ = ((L2[0] - L1[0]) * d2[1] - (L2[1] - L1[1]) * d2[0]) / cr
    P = (L1[0] + d1[0] * s_, L1[1] + d1[1] * s_)
    sign = 1.0 if cr > 0 else -1.0
    for tcap in (t_cap, 1400.0, 1000.0, 700.0, 500.0):
        t = tcap; r = t / math.tan(th / 2)
        T1 = (P[0] - d1[0] * t, P[1] - d1[1] * t); T2 = (P[0] + d2[0] * t, P[1] + d2[1] * t)
        nrm = (-d1[1] * sign, d1[0] * sign); Cc = (T1[0] + nrm[0] * r, T1[1] + nrm[1] * r)
        ang1 = math.atan2(T1[1] - Cc[1], T1[0] - Cc[0]); ang2 = math.atan2(T2[1] - Cc[1], T2[0] - Cc[0])
        dang = ang2 - ang1
        while dang * sign < 0: dang += sign * 2 * math.pi
        while abs(dang) > math.pi: dang -= sign * 2 * math.pi
        nseg = max(3, int(abs(dang) * r / 120))
        arc = [(Cc[0] + r * math.cos(ang1 + dang * q / nseg), Cc[1] + r * math.sin(ang1 + dang * q / nseg)) for q in range(nseg + 1)]
        s0 = (P[0] - d1[0] * (t + 3500), P[1] - d1[1] * (t + 3500)); s3 = (P[0] + d2[0] * (t + 3500), P[1] + d2[1] * (t + 3500))
        lead = bezier_pts(lane[ia], (d1[0], d1[1]), s0, d1)
        tail = bezier_pts(s3, d2, lane[ib], d2)
        pts = lead + [T1] + arc[1:-1] + [T2] + tail
        bad_n = 0; why_ = []
        for q in range(len(pts) - 1):
            u = (pts[q + 1][0] - pts[q][0], pts[q + 1][1] - pts[q][1]); Lq = math.hypot(*u) or 1.0
            ks = max(1, int(Lq / 60))
            for r_ in range(ks):
                pp = (pts[q][0] + u[0] * r_ / ks, pts[q][1] + u[1] * r_ / ks)
                if rclr(*pp) < 300 or wall_clear(pp, 400) < 230: bad_n += 1; why_.append(pp)
        if bad_n == 0:
            return pts, r, tcap
        print("     junction: tangent length %.0f rejected (%d bad samples, first near (%.0f,%.0f), clearance %.0f)" % (tcap, bad_n, why_[0][0], why_[0][1], rclr(*why_[0])))
    return None

repl_by_start = {}
for (ws, we) in runs:
    ia, ib = (ws - 1) % nstat, (we + 1) % nstat
    win_circles = []
    for q in range(ws, ws + ((we - ws) % nstat) + 1):
        for c_ in circles:
            if math.hypot(lane[q % nstat][0] - c_[0], lane[q % nstat][1] - c_[1]) < CIRCLE_ZONE and c_ not in win_circles: win_circles.append(c_)
    has_circle = len(win_circles) > 0
    print('  [window %d..%d around circle %s: anchors a1=(%.0f,%.0f) b0=(%.0f,%.0f)]' % (ws, we, ('(%.0f,%.0f)' % win_circles[0][:2]) if win_circles else 'none', lane[ia][0], lane[ia][1], lane[ib][0], lane[ib][1]))
    if has_circle:
        da_ = (lane[ia][0] - lane[(ia - 1) % nstat][0], lane[ia][1] - lane[(ia - 1) % nstat][1])
        db_ = (lane[(ib + 1) % nstat][0] - lane[ib][0], lane[(ib + 1) % nstat][1] - lane[ib][1])
        turn_c = abs(math.degrees(math.atan2(da_[0] * db_[1] - da_[1] * db_[0], da_[0] * db_[0] + da_[1] * db_[1])))
        if turn_c < 35.0:
            chord = resample([lane[ia], lane[ib]], 140.0)
            cu = (lane[ib][0] - lane[ia][0], lane[ib][1] - lane[ia][1]); cl = math.hypot(*cu) or 1.0; cu = (cu[0] / cl, cu[1] / cl)
            bad_c = [q for q in chord if rclr(*q) < 300 or wall_clear(q, 400) < 230 or side_bad(q, cu)]
            for q in bad_c: print("     bad chord point (%.0f,%.0f) rclr %.0f wall %.0f side_bad %s" % (q[0], q[1], rclr(*q), wall_clear(q, 400), side_bad(q, cu)))
            print("  window %d..%d: straight through the circle (turn %.0f deg), chord check: %d of %d points unusable" % (ws, we, turn_c, len(bad_c), len(chord)))
            if not bad_c:
                repl_by_start[ws] = (we, chord[1:-1])
                continue
    if len(win_circles) == 1:
        jp = junction_path(ia, ib, win_circles[0])
        if jp is not None:
            pts_j, r_j, t_j = jp
            repl_by_start[ws] = (we, resample(pts_j, 140.0)[1:-1])
            print("  window %d..%d: junction turn at the circle, arc radius %.0f (starts %.0f before the corner), %d points" % (ws, we, r_j, t_j, len(repl_by_start[ws][1])))
            continue
    if not has_circle:
        da_ = (lane[ia][0] - lane[(ia - 1) % nstat][0], lane[ia][1] - lane[(ia - 1) % nstat][1])
        db_ = (lane[(ib + 1) % nstat][0] - lane[ib][0], lane[(ib + 1) % nstat][1] - lane[ib][1])
        turn_ = abs(math.degrees(math.atan2(da_[0] * db_[1] - da_[1] * db_[0], da_[0] * db_[0] + da_[1] * db_[1])))
        if turn_ < 25.0:
            print("  window %d..%d: gentle bend (%.0f deg), keeping the lane line as it is" % (ws, we, turn_)); continue
    fl = fillet_path(ia, ib, t_cap=1500.0 if has_circle else None)
    if fl is not None:
        pts_f, rr_ = fl
        repl_by_start[ws] = (we, resample([lane[ia]] + pts_f + [lane[ib]], 140.0)[1:-1])
        print("  window %d..%d: fillet arc radius %.0f, %d points%s" % (ws, we, rr_, len(repl_by_start[ws][1]), "  (turn made at the circle)" if has_circle else ""))
        continue
    pre = lane[(ia - 1) % nstat]; post = lane[(ib + 1) % nstat]
    chosen = None
    for yel_f in (60.0, 120.0, 220.0):
        for cm_ in (200.0, 140.0):
            path = raster_astar(lane[ia], lane[ib], cm_, yel_forbid=yel_f)
            if not path: continue
            core = resample([lane[ia]] + path[1:-1] + [lane[ib]], 100.0)
            smooth = smooth_path([pre] + core + [post], 2, 2)
            final = resample(smooth[1:-1], 140.0)
            inner = final[1:-1]
            bad_n = 0
            for q in range(len(final) - 1):
                u = (final[q + 1][0] - final[q][0], final[q + 1][1] - final[q][1]); Lq = math.hypot(*u) or 1.0
                if side_bad(final[q], (u[0] / Lq, u[1] / Lq)): bad_n += 1
            chosen = (inner, cm_, yel_f, bad_n)
            if bad_n == 0: break
        if chosen and chosen[3] == 0: break
    if chosen is None:
        print("  window %d..%d: NO PATH" % (ws, we)); continue
    inner, okc, yel_f, bad_n = chosen
    repl_by_start[ws] = (we, inner)
    minc = min([rclr(*p) for p in inner] or [0])
    print("  window %d..%d: A* clearance %.0f, yellow forbid %.0f, %d points, min clearance %.0f, invalid samples %d%s" % (
        ws, we, okc, yel_f, len(inner), minc, bad_n, "  (circle junction)" if has_circle else ""))

# assemble: stations outside windows are kept, windows replaced by the repaired points
lane2 = []; lane2_fixed = []
i = start; count = 0
while count < nstat:
    if i in repl_by_start:
        we, inner = repl_by_start[i]
        length = (we - i) % nstat + 1
        for p in inner:
            lane2.append(p); lane2_fixed.append(True)
        i = (i + length) % nstat; count += length
    else:
        lane2.append(lane[i]); lane2_fixed.append(False)
        i = (i + 1) % nstat; count += 1
print("lane points before simplify:", len(lane2), "repaired points:", sum(lane2_fixed))

line_pts, line_fixed = [], []
i = 0; n2 = len(lane2)
while i < n2:
    if lane2_fixed[i]:
        line_pts.append(lane2[i]); line_fixed.append(True); i += 1; continue
    j = i
    while j < n2 and not lane2_fixed[j]: j += 1
    run = lane2[i:j]
    simp = simplify(run, 30.0) if len(run) > 2 else run
    for p in simp:
        line_pts.append(p); line_fixed.append(False)
    i = j
lane_s = line_pts
print("lane line points before global smoothing:", len(lane_s))
repaired_pts = [lane2[q] for q in range(len(lane2)) if lane2_fixed[q]]

# ---- global constrained smoothing: uniform spacing, Laplacian passes that never violate the safety rules
dense_s = resample(lane_s + [lane_s[0]], 300.0)[:-1]
ns_ = len(dense_s)
orig_dense = list(dense_s)
SMOOTH_MAX_MOVE = 120.0   # smoothing may only remove wobble; it must not re-cut the repaired corners
def pt_ok(p, u):
    return not side_bad(p, u) and wall_clear(p, 400) >= 230
moved_total = 0
for it in range(60):
    nd = list(dense_s); moved = 0
    for i in range(ns_):
        a_, b_, c_ = dense_s[(i - 1) % ns_], dense_s[i], dense_s[(i + 1) % ns_]
        cand = (0.25 * a_[0] + 0.5 * b_[0] + 0.25 * c_[0], 0.25 * a_[1] + 0.5 * b_[1] + 0.25 * c_[1])
        if math.hypot(cand[0] - b_[0], cand[1] - b_[1]) < 1.0: continue
        u_ = (c_[0] - a_[0], c_[1] - a_[1]); Lu = math.hypot(*u_) or 1.0; u_ = (u_[0] / Lu, u_[1] / Lu)
        if math.hypot(cand[0] - orig_dense[i][0], cand[1] - orig_dense[i][1]) > SMOOTH_MAX_MOVE: continue
        if pt_ok(cand, u_):
            nd[i] = cand; moved += 1
    dense_s = nd; moved_total += moved
    if moved == 0: break
print("smoothing: %d points, %d passes, %d point moves" % (ns_, it + 1, moved_total))
lane_s = simplify(dense_s + [dense_s[0]], 8.0)[:-1]
# which line segments belong to repaired junctions (no overtaking there)
line_fixed = []
for j in range(len(lane_s)):
    mx_ = 0.5 * (lane_s[j][0] + lane_s[(j + 1) % len(lane_s)][0]); mz_ = 0.5 * (lane_s[j][1] + lane_s[(j + 1) % len(lane_s)][1])
    line_fixed.append(any(math.hypot(mx_ - r_[0], mz_ - r_[1]) < 2500 for r_ in repaired_pts))
print("final lane line points:", len(lane_s))

def verify(line, label):
    nl = len(line); worst_c = (1e9, (0, 0, 0)); worst_y = (1e9, (0, 0, 0)); worst_w = (1e9, (0, 0, 0)); offroad = 0; samples = 0
    for j in range(nl):
        a, b = line[j], line[(j + 1) % nl]; L = math.hypot(b[0] - a[0], b[1] - a[1]); k = max(1, int(L / 40))
        for q in range(k):
            x, z = a[0] + (b[0] - a[0]) * q / k, a[1] + (b[1] - a[1]) * q / k
            c = rclr(x, z); y = rydist(x, z); w = wall_clear((x, z), 600)
            samples += 1
            if c <= 0: offroad += 1
            if c < worst_c[0]: worst_c = (c, (x, z, j))
            if y < worst_y[0]: worst_y = (y, (x, z, j))
            if w < worst_w[0]: worst_w = (w, (x, z, j))
    print("%s: %d samples, off-asphalt %d, min curb/out clearance %.0f at %s, min yellow dist %.0f at %s, min wall dist %.0f at %s" % (
        label, samples, offroad, worst_c[0], tuple(round(v) for v in worst_c[1]), worst_y[0], tuple(round(v) for v in worst_y[1]), worst_w[0], tuple(round(v) for v in worst_w[1])))
verify(lane_s, "final lane line")
print("closest approach to any ring centre: %.0f (keep-out %.0f)" % (min(circ_dist(*pt) for pt in lane_s), CIRCLE_KEEP))
yellow = [(st[0] + st[3] * m[0], st[1] - st[2] * m[0]) for st, m in zip(stations, meas) if m]

# ------------------------------------------------------------------ 5. speed caps from curvature (with a backward braking pass)
line = lane_s; N = len(line)
def seg(i): return line[i % N], line[(i + 1) % N]
segl = [math.hypot(line[(i + 1) % N][0] - line[i][0], line[(i + 1) % N][1] - line[i][1]) for i in range(N)]
def curvature_caps(omega, vmax=300.0, vmin=60.0, dec=9.0):
    cap = []
    for i in range(N):
        a, b, c = line[(i - 1) % N], line[i], line[(i + 1) % N]
        th = abs(math.radians(turn_angle(a, b, c)))
        ds = 0.5 * (segl[(i - 1) % N] + segl[i])
        kappa = th / ds if ds > 0 else 0.0
        R = 1.0 / kappa if kappa > 1e-9 else 1e9
        cap.append(max(vmin, min(vmax, R * omega)))
    cap = [min(cap[(i - 1) % N], cap[i], cap[(i + 1) % N]) for i in range(N)]
    for _ in range(3):
        for i in range(2 * N - 1, -1, -1):
            j = i % N; nxt = (j + 1) % N
            lim = math.sqrt(cap[nxt] ** 2 + 2 * dec * segl[j])
            if lim < cap[j]: cap[j] = lim
    return cap

# ------------------------------------------------------------------ 6. simulation (mirrors the in-game follower)
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

DEBUG_SIM = False
def simulate(params, caps):
    global DEBUG_SIM
    LA_MIN, LA_MAX, LA_K, GAIN, TCAP = params
    pos = [line[0][0], line[0][1]]
    a, b = seg(0); pose = math.degrees(math.atan2(b[0] - a[0], b[1] - a[1]))
    vel = [0.0, 0.0]; idx = 0; ticks = 0; guard = 0; laps = 0; lastgood = pos[:]; prev_turn = 0.0
    speeds = []; lat = []; minclr = 1e9; minyel = 1e9; offroad = 0; curbtouch = 0; worst_lat_at = (0, None)
    while ticks < 12 * 60 * 12:
        for _ in range(6):
            t, d = project(pos, idx)
            if t >= 1.0:
                idx += 1
                if idx % N == 0: laps += 1
            else: break
        t, d = project(pos, idx); lat.append(d)
        if d > worst_lat_at[0]: worst_lat_at = (d, (round(pos[0]), round(pos[1]), idx % N))
        speed = math.hypot(*vel)
        la = max(LA_MIN, min(LA_MAX, speed * LA_K))
        dirx, dirz = math.sin(math.radians(pose)), math.cos(math.radians(pose))
        tgt = point_ahead(idx, t, la)
        ang = sang(dirx, dirz, tgt[0] - pos[0], tgt[1] - pos[1])
        tgt_turn = max(-TCAP, min(TCAP, ang * GAIN))
        turn_ = prev_turn + max(-4.0, min(4.0, tgt_turn - prev_turn)); prev_turn = turn_
        pose += turn_
        cap = caps[idx % N] + (caps[(idx + 1) % N] - caps[idx % N]) * max(0.0, min(1.0, t))
        if speed > cap + 8 or (abs(ang) > 50 and speed > 80): acc = -1
        elif speed > cap - 4: acc = 0
        else: acc = 1
        pos[0] += vel[0]; pos[1] += vel[1]
        if bad(pos[0], pos[1]) or rclr(pos[0], pos[1]) <= 0:
            guard += 1
            sa, sb = seg(idx); sl = math.hypot(sb[0] - sa[0], sb[1] - sa[1]) or 1.0
            tx, tz = (sb[0] - sa[0]) / sl, (sb[1] - sa[1]) / sl
            along = vel[0] * tx + vel[1] * tz
            cand = [lastgood[0] + tx * along, lastgood[1] + tz * along]
            if along > 0 and not bad(cand[0], cand[1]) and rclr(*cand) > 0:
                pos = cand; vel = [tx * along * 0.8, tz * along * 0.8]
            else:
                pos = lastgood[:]; vel = [vel[0] * 0.3, vel[1] * 0.3]
        lastgood = pos[:]
        c_ = rclr(pos[0], pos[1]); y_ = rydist(pos[0], pos[1])
        minclr = min(minclr, c_); minyel = min(minyel, y_)
        if c_ <= 0: offroad += 1
        if c_ < 80: curbtouch += 1
        dirx, dirz = math.sin(math.radians(pose)), math.cos(math.radians(pose))
        a_mag = 20.0 if acc == 1 else (-10.0 if acc == -1 else 0.0)
        v2x, v2z = vel[0] + dirx * a_mag, vel[1] + dirz * a_mag
        fdot = v2x * dirx + v2z * dirz; fx, fz = dirx * fdot, dirz * fdot; lx, lz = v2x - fx, v2z - fz
        fx *= 0.95; fz *= 0.95; lx *= 0.2; lz *= 0.2
        vel = [fx + lx, fz + lz]; sp = math.hypot(*vel)
        if sp > 300: vel = [vel[0] * 300 / sp, vel[1] * 300 / sp]; sp = 300
        if sp < 2: vel = [0.0, 0.0]; sp = 0
        speeds.append(sp)
        if DEBUG_SIM and (ticks % 400 == 0 or (sp < 40 and ticks % 40 == 0)):
            print('   sim tick %5d idx %3d t %.2f d %5.0f pos (%.0f,%.0f) sp %.0f cap %.0f ang %.1f acc %d' % (ticks, idx % N, t, d, pos[0], pos[1], sp, cap, ang, acc))
        ticks += 1
        if laps >= 1: break
    lat.sort()
    return dict(lap_s=ticks / 12.0, guard=guard, offroad=offroad, curbtouch=curbtouch, minclr=minclr, minyel=minyel,
                avg=sum(speeds) / len(speeds), lat_p99=lat[int(len(lat) * 0.99)], lat_max=lat[-1], worst=worst_lat_at,
                finished=laps >= 1, params=params)

best = None; table = []
for omega in (0.12, 0.16, 0.2, 0.25):
    caps = curvature_caps(omega)
    for LA_MIN in (450,):
        for LA_MAX in (1400,):
            for LA_K in (4.0,):
                for GAIN in (0.3,):
                    r = simulate((LA_MIN, LA_MAX, LA_K, GAIN, 40), caps); r['omega'] = omega
                    table.append(r)
                    ok = r['finished'] and r['guard'] == 0 and r['offroad'] == 0 and r['minclr'] >= 110 and r["minyel"] >= 45
                    key = (0 if ok else 1, r['lap_s'] if ok else (r['guard'] + r['curbtouch'] * 0.1 + 1000 / max(r['minclr'], 1)))
                    if best is None or key < best[0]: best = (key, r, omega)
print("simulated %d parameter sets" % len(table))
for r in sorted(table, key=lambda r: (r['guard'], r['curbtouch'], r['lap_s']))[:6]:
    print("  omega=%.2f params=%s lap=%.0fs avg=%.0f guard=%d curb=%d minclr=%.0f minyel=%.0f p99lat=%.0f maxlat=%.0f at %s" % (
        r['omega'], r['params'], r['lap_s'], r['avg'], r['guard'], r['curbtouch'], r['minclr'], r['minyel'], r['lat_p99'], r['lat_max'], r['worst']))
r = best[1]; omega = best[2]
print("CHOSEN omega=%.2f params=%s lap=%.0fs guard=%d offroad=%d curb=%d minclr=%.0f minyel=%.0f p99lat=%.0f maxlat=%.0f at %s" % (
    omega, r['params'], r['lap_s'], r['guard'], r['offroad'], r['curbtouch'], r['minclr'], r['minyel'], r['lat_p99'], r['lat_max'], r['worst']))
caps = curvature_caps(omega)
if os.environ.get('SIMDEBUG'):
    DEBUG_SIM = True; simulate(r['params'], caps); DEBUG_SIM = False
    print('caps below 100:', [(i, round(c)) for i, c in enumerate(caps) if c < 100][:40])

# ------------------------------------------------------------------ 7. lane-2 availability for overtaking
wcount = [len(m[3]) if m else 0 for m in meas]
extra = []
for k in range(n):
    if meas[k] is None:
        extra.append(0); continue
    best_w = max(wcount[(k + j) % n] for j in range(-3, 4))
    extra.append(1 if best_w >= 2 else 0)
for k in range(n):
    if extra[k] > 0:
        x, z, ux, uz = stations[k]; okk = True
        for extra_off in (-120.0, 0.0, 120.0):
            px_, pz_ = x + uz * (sm[k] + SHIFT + extra_off), z - ux * (sm[k] + SHIFT + extra_off)
            if bad(px_, pz_) or rclr(px_, pz_) < 150: okk = False
        if not okk: extra[k] = 0
extra2 = [1 if all(extra[(k + j) % n] > 0 for j in range(0, 4)) else 0 for k in range(n)]
seg_tot = [0] * N; seg_ok = [0] * N
for k in range(n):
    x, z = stations[k][0], stations[k][1]; bestj, bestd = 0, 1e18
    for j in range(N):
        a, b = line[j], line[(j + 1) % N]
        vx, vz = b[0] - a[0], b[1] - a[1]; L2 = vx * vx + vz * vz or 1.0
        tt = max(0.0, min(1.0, ((x - a[0]) * vx + (z - a[1]) * vz) / L2))
        dd = (a[0] + vx * tt - x) ** 2 + (a[1] + vz * tt - z) ** 2
        if dd < bestd: bestd, bestj = dd, j
    seg_tot[bestj] += 1; seg_ok[bestj] += extra2[k]
line_extra = [1 if (seg_tot[j] >= 2 and seg_ok[j] >= 0.9 * seg_tot[j] and caps[j] >= 180 and caps[(j + 1) % N] >= 180 and not line_fixed[j] and not line_fixed[(j + 1) % N]) else 0 for j in range(N)]
print("line segments allowing a lane-2 overtake: %d / %d" % (sum(line_extra), N))

# ------------------------------------------------------------------ outputs
flat = []
for (x, z) in line:
    flat.append(round(x, 1)); flat.append(round(z, 1))
P = r['params']
params_out = dict(la_min=P[0], la_max=P[1], la_k=P[2], gain=P[3], tcap=P[4], shift=SHIFT, omega=omega, lap_s=r['lap_s'])
json.dump({"line": line, "yellow": yellow, "params": params_out, "extra": line_extra, "caps": caps, "fixed": line_fixed}, open(os.path.join(OUTDIR, "lane_line.json"), "w"))
open(os.path.join(OUTDIR, "lane_line_as3.txt"), "w").write("[" + ",".join(("%g" % v) for v in flat) + "]")
open(os.path.join(OUTDIR, "lane_extra_as3.txt"), "w").write("[" + ",".join(str(v) for v in line_extra) + "]")
open(os.path.join(OUTDIR, "lane_speed_as3.txt"), "w").write("[" + ",".join(str(int(round(c))) for c in caps) + "]")
json.dump(params_out, open(os.path.join(OUTDIR, "lane_params.json"), "w"))
print("wrote lane line: %d points; params %s" % (len(line), params_out))
