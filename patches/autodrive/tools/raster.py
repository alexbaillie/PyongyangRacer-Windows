"""Rasterises the road corridor: per 50-unit cell, texture class (asphalt / yellow / white / other) and out-of-bounds flag."""
import sys, os, time, math
sys.path.insert(0, os.path.dirname(__file__))
from meshlib import *
import numpy as np
RES = 50.0
ASPHALT = ('newaspald.jpg', 'newaspald_speed.jpg', 'cross_road.jpg', 'center_crossroad.jpg', 'normal_road.jpg',
           'right_pre_cross_road.jpg', 'left_pre_cross_road.jpg', 'un_right_pre_cross_road.jpg',
           'un_left_pre_cross_road.jpg', 'un_pre_cross_road.jpg')
asph_mat = set(i for i, n in enumerate(mats) if os.path.basename(n) in ASPHALT or os.path.basename(n).startswith('arc_'))
xs = [p[0] for p in WP]; zs = [p[1] for p in WP]
X0, Z0 = min(xs) - 5000, min(zs) - 5000
NX = int((max(xs) + 5000 - X0) / RES) + 1; NZ = int((max(zs) + 5000 - Z0) / RES) + 1
print("raster", NX, "x", NZ)
# coarse needed-blocks: within 3500 of the waypoint polyline (sampled every 400)
BLK = 20   # cells per block side = 1000 units
need = set()
n = len(WP)
for i in range(n):
    a, b = WP[i], WP[(i + 1) % n]
    L = math.hypot(b[0] - a[0], b[1] - a[1]); k = max(1, int(L / 400))
    for s in range(k + 1):
        x, z = a[0] + (b[0] - a[0]) * s / k, a[1] + (b[1] - a[1]) * s / k
        bx0, bx1 = int((x - 3500 - X0) / RES) // BLK, int((x + 3500 - X0) / RES) // BLK
        bz0, bz1 = int((z - 3500 - Z0) / RES) // BLK, int((z + 3500 - Z0) / RES) // BLK
        for bx in range(bx0, bx1 + 1):
            for bz in range(bz0, bz1 + 1): need.add((bx, bz))
print("blocks:", len(need), "cells:", len(need) * BLK * BLK)
cls = np.zeros((NZ, NX), np.uint8)      # 0 none, 1 asphalt, 2 yellow, 3 white, 4 other
oob = np.zeros((NZ, NX), np.uint8)
t0 = time.time()
done = 0
for (bx, bz) in sorted(need):
    for cz in range(bz * BLK, min(NZ, (bz + 1) * BLK)):
        for cx in range(bx * BLK, min(NX, (bx + 1) * BLK)):
            x = X0 + (cx + 0.5) * RES; z = Z0 + (cz + 0.5) * RES
            oob[cz, cx] = 1 if bad(x, z) else 0
            t, bary = locate(x, z)
            if t is None: continue
            m = tri_mat.get(t)
            if m is None: cls[cz, cx] = 4; continue
            if m not in asph_mat: cls[cz, cx] = 4; continue
            c = texel_class(x, z)
            cls[cz, cx] = 2 if c == "Y" else (3 if c == "W" else 1)
    done += 1
    if done % 200 == 0: print("blocks done", done, "of", len(need), "%.0fs" % (time.time() - t0), flush=True)
np.savez_compressed(os.path.join(os.path.dirname(__file__), "plan", "raster.npz"), cls=cls, oob=oob, X0=X0, Z0=Z0, RES=RES)
print("saved raster in %.0fs" % (time.time() - t0))
