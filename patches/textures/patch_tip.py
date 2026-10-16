"""Changes the loading-screen tip 'If you hit ten vehicles ...' to 'three' by editing the glyph list of
the static text (DefineText id 152) directly. Usage: patch_tip.py in.swf out.swf"""
import sys, struct, zlib

src, dst = sys.argv[1], sys.argv[2]
raw = open(src, "rb").read()
assert raw[:3] == b"CWS", "expected a zlib-compressed SWF"
body = zlib.decompress(raw[8:])

class Bits:
    def __init__(self, data, pos=0): self.d = data; self.p = pos * 8
    def read(self, n):
        v = 0
        for _ in range(n):
            v = (v << 1) | ((self.d[self.p >> 3] >> (7 - (self.p & 7))) & 1); self.p += 1
        return v
    def sread(self, n):
        v = self.read(n)
        return v - (1 << n) if n and v >> (n - 1) else v
    def align(self): self.p = (self.p + 7) & ~7

class BitW:
    def __init__(self): self.bits = []
    def write(self, v, n):
        for i in range(n - 1, -1, -1): self.bits.append((v >> i) & 1)
    def bytes(self):
        b = self.bits + [0] * (-len(self.bits) % 8)
        return bytes(int("".join(map(str, b[i:i + 8])), 2) for i in range(0, len(b), 8))

# skip the header RECT
r = Bits(body); nb = r.read(5); r.p += nb * 4; r.align(); pos = r.p // 8 + 4  # frame rate (2) + frame count (2)
tags = []
while pos < len(body):
    h = struct.unpack_from("<H", body, pos)[0]; code, ln = h >> 6, h & 63; hl = 2
    if ln == 63: ln = struct.unpack_from("<I", body, pos + 2)[0]; hl = 6
    tags.append((code, pos, hl, ln)); pos += hl + ln
    if code == 0: break

target = None
for code, p, hl, ln in tags:
    if code in (11, 33) and struct.unpack_from("<H", body, p + hl)[0] == 152:
        target = (code, p, hl, ln)
assert target, "DefineText 152 not found"
code, p, hl, ln = target
data = body[p + hl:p + hl + ln]
r = Bits(data, 2)
nb = r.read(5); r.p += nb * 4; r.align()           # text bounds
r.align(); hasscale = r.read(1)
if hasscale: n = r.read(5); r.p += 2 * n
hasrot = r.read(1)
if hasrot: n = r.read(5); r.p += 2 * n
n = r.read(5); r.p += 2 * n; r.align()                # translate
mat_end = r.p // 8
glyph_bits = data[mat_end]; adv_bits = data[mat_end + 1]
pos = mat_end + 2
recs = []                                            # (header_bytes_or_None, glyph_list)
while data[pos] != 0:
    first = data[pos]
    if first & 0x80:                                 # style change record
        flags = first; q = pos + 1
        if flags & 8: q += 2                          # font id
        if flags & 4: q += 3 if code == 11 else 4     # colour
        if flags & 1: q += 2                          # x offset
        if flags & 2: q += 2                          # y offset
        if flags & 8: q += 2                          # font height
        recs.append((data[pos:q], None)); pos = q
    else:
        cnt = first & 0x7F
        br = Bits(data, pos + 1)
        gl = [(br.read(glyph_bits), br.sread(adv_bits)) for _ in range(cnt)]
        br.align()
        recs.append((None, gl)); pos = br.p // 8
tail = data[pos:]                                    # the 0 end byte
glyph_runs = [g for h, g in recs if g]
# map characters to (glyph, advance) by position in the known strings
strings = ["Do not hit cars or vans", ".", "If you hit ten vehicles you will ", "be stopped for bad driving", "."]
cmap = {}
runs = [g for g in glyph_runs]
print("glyph runs:", [len(g) for g in runs])
for s_, g in zip(strings, runs):
    if len(s_) != len(g): continue
    for ch, ent in zip(s_, g): cmap.setdefault(ch, []).append(ent)
tip = next(i for i, g in enumerate(runs) if len(g) == len("If you hit ten vehicles you will "))
g = runs[tip]
s_ = "If you hit ten vehicles you will "
i0 = s_.index("ten")
def avg_adv(ch):
    a = [e[1] for e in cmap[ch]]; return round(sum(a) / len(a))
new = list(g[:i0])
for ch in "three": new.append((cmap[ch][0][0], avg_adv(ch)))
new += g[i0 + 3:]
# keep the line exactly as wide as the original: the tip sits in a fixed-size mask, so squeeze the spacing
orig_w = sum(a for _, a in g); new_w = sum(a for _, a in new)
f = orig_w / float(new_w)
squeezed = [(gi, int(round(a * f))) for gi, a in new]
squeezed[-1] = (squeezed[-1][0], squeezed[-1][1] + (orig_w - sum(a for _, a in squeezed)))
new = squeezed
print("glyph run %d -> %d glyphs, width %d -> %d (squeeze %.3f)" % (len(g), len(new), orig_w, new_w, f))
assert len(new) < 128
out = bytearray(data[:pos - sum(0 for _ in [])])
# rebuild the record stream
rebuilt = bytearray(data[:mat_end + 2])
for h, gl in recs:
    if h is not None: rebuilt += h
    else:
        if gl is g: gl = new
        bw = BitW(); bw.write(0, 1)
        rebuilt.append(len(gl) & 0x7F)
        bw = BitW()
        for gi, ad in gl: bw.write(gi, glyph_bits); bw.write(ad & ((1 << adv_bits) - 1), adv_bits)
        rebuilt += bw.bytes()
rebuilt += tail
newtag_len = len(rebuilt)
hdr = struct.pack("<HI", (code << 6) | 63, newtag_len)  # always a long header
newbody = body[:p] + hdr + bytes(rebuilt) + body[p + hl + ln:]
# fix the file length in the header and recompress
filelen = len(newbody) + 8
out = b"CWS" + raw[3:4] + struct.pack("<I", filelen) + zlib.compress(newbody, 9)
open(dst, "wb").write(out)
print("wrote", dst)
