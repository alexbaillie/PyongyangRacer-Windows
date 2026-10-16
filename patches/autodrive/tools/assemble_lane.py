import io, os, sys
T = os.path.dirname(os.path.abspath(__file__))
src = io.open(os.path.join(T, "lane_line_v2_backup.py"), encoding="utf-8").read().split("\n")
cut = next(i for i, l in enumerate(src) if l.startswith("lane = pts_of(keep)"))
head_lines = src[:cut]

def find(prefix, start=0):
    return next(i for i in range(start, len(head_lines)) if head_lines[i].startswith(prefix))

# ---- (1) stations: spline through the waypoints instead of straight chords
a = find("STATION = 500.0")
b = find('print("stations:"', a)
stations_block = r'''STATION = 500.0
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
print("stations:", n, "on rerouted stretches:", sum(station_rerouted), "track length %.0f" % total)'''.split("\n")
head_lines[a:b + 1] = stations_block

# ---- (2) offsets: measure, reject outliers, interpolate, then re-centre on the yellow line twice
a = find("meas = [measure(st, 900 if rr else 450)")
b = find('print("lane offset stats:', a)
offsets_block = r'''def solve_offsets(sts, maxoffs):
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
print("lane offset stats: min %.0f max %.0f mean %.0f" % (min(sm), max(sm), sum(sm) / n))'''.split("\n")
head_lines[a:b + 1] = offsets_block

head = "\n".join(head_lines) + "\n"
head = head.replace("DEFAULT_LANE = 460.0\n",
    "DEFAULT_LANE = 460.0\nANCHOR = float(os.environ.get('ANCHOR', '135'))   # car centre sits this far right of the yellow line's edge\nSHIFT = 600.0                                      # lane-1 to lane-2 distance when overtaking\n", 1)
head = head.replace("off < y0_by_station[k] + YELLOW_HALF + 100: continue", "off < y0_by_station[k] + YELLOW_HALF + 80: continue")
head = head.replace("off < y0_by_station[k] + YELLOW_HALF + 100: return False", "off < y0_by_station[k] + YELLOW_HALF + 80: return False")
assert head.count("YELLOW_HALF + 80") == 2 and "min(ANCHOR" in head, "head edits failed"
tail = io.open(os.path.join(T, "lane_tail.txt"), encoding="utf-8").read()
io.open(os.path.join(T, "lane_line.py"), "w", encoding="utf-8", newline="\n").write(head + tail)
print("lane_line.py assembled:", len((head + tail).split("\n")), "lines")
