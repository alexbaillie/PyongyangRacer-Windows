"""Checks a driving line against the game's invisible collision walls (collision.map)."""
import sys, struct, zlib, math, json
G, linejson = sys.argv[1], sys.argv[2]
MARGIN = float(sys.argv[3]) if len(sys.argv) > 3 else 160.0

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
cm = [b for (nm, t), b in level if nm == 'collision.map'][0]
f = struct.unpack_from('<iiiiiiiffffffiiiiiiiffffffiiii', cm, 0)
GeomOfs, NumVtxs, NumUvs, NumTris, NumMtls, MtlOfs = f[2], f[4], f[5], f[6], f[13], f[14]
V = [struct.unpack_from('<fff', cm, GeomOfs + k * 12) for k in range(NumVtxs)]
o = GeomOfs + NumVtxs * 12
TRI = [struct.unpack_from('<HHH', cm, o + k * 6) for k in range(NumTris)]
print("collision.map: %d vertices, %d triangles, %d materials" % (NumVtxs, NumTris, NumMtls))
# wall footprints: for each triangle take the two xz-farthest vertices as a ground segment
walls = []
for a, b, c in TRI:
    P = [(V[a][0], V[a][2]), (V[b][0], V[b][2]), (V[c][0], V[c][2])]
    best = None
    for i in range(3):
        for j in range(i + 1, 3):
            d = math.hypot(P[i][0] - P[j][0], P[i][1] - P[j][1])
            if best is None or d > best[0]:
                best = (d, P[i], P[j])
    if best[0] > 1:
        walls.append((best[1], best[2]))
print("wall segments:", len(walls))
ys = [v[1] for v in V]
print("wall heights y range: %.0f .. %.0f" % (min(ys), max(ys)))

def seg_dist(p, a, b):
    vx, vz = b[0] - a[0], b[1] - a[1]; L2 = vx * vx + vz * vz
    if L2 == 0: return math.hypot(p[0] - a[0], p[1] - a[1])
    t = max(0.0, min(1.0, ((p[0] - a[0]) * vx + (p[1] - a[1]) * vz) / L2))
    return math.hypot(p[0] - (a[0] + vx * t), p[1] - (a[1] + vz * t))
def segs_intersect(p1, p2, p3, p4):
    def ccw(A, B, C): return (C[1] - A[1]) * (B[0] - A[0]) > (B[1] - A[1]) * (C[0] - A[0])
    return ccw(p1, p3, p4) != ccw(p2, p3, p4) and ccw(p1, p2, p3) != ccw(p1, p2, p4)
def chord_wall_clearance(a, b, step=40):
    L = math.hypot(b[0] - a[0], b[1] - a[1]); n = max(1, int(L / step))
    worst = 1e9
    for w in walls:
        # quick reject by bbox
        if max(a[0], b[0]) + MARGIN < min(w[0][0], w[1][0]) or min(a[0], b[0]) - MARGIN > max(w[0][0], w[1][0]): continue
        if max(a[1], b[1]) + MARGIN < min(w[0][1], w[1][1]) or min(a[1], b[1]) - MARGIN > max(w[0][1], w[1][1]): continue
        if segs_intersect(a, b, w[0], w[1]): return 0.0
        for k in range(n + 1):
            p = (a[0] + (b[0] - a[0]) * k / n, a[1] + (b[1] - a[1]) * k / n)
            worst = min(worst, seg_dist(p, w[0], w[1]))
    return worst

d = json.load(open(linejson))
for name, line in (("lane line", d["line"]), ("waypoint path", None)):
    if line is None:
        path_b = [b for (nm, t), b in level if t == 4][0]
        cnt = struct.unpack_from('<i', path_b, 0)[0]
        line = [(q[1], q[3]) for q in (struct.unpack_from('<ifff', path_b, 4 + k * 16) for k in range(cnt))]
    N = len(line); bad = []
    for j in range(N):
        c = chord_wall_clearance(line[j], line[(j + 1) % N])
        if c < MARGIN: bad.append((j, c))
    print("%s: %d / %d chords closer than %.0f to a wall" % (name, len(bad), N, MARGIN))
    for j, c in bad[:25]:
        a, b = line[j], line[(j + 1) % N]
        print("   chord %3d (%.0f,%.0f)->(%.0f,%.0f) clearance %.0f" % (j, a[0], a[1], b[0], b[1], c))
