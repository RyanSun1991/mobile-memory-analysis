import json, glob, os, collections
files = sorted(glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'data', 'iphone', 'jetsam', '*.ips')))
def load(f):
    txt = open(f).read()
    head, _, body = txt.partition('\n')
    return json.loads(head), json.loads(body)
rows = []
for f in files:
    h, b = load(f)
    ms = b.get('memoryStatus', {})
    rows.append((os.path.basename(f), h, b, ms))
# show structure of latest
name, h, b, ms = rows[-1]
print('TOP KEYS:', list(b.keys()))
print('memoryStatus keys:', json.dumps({k: (v if not isinstance(v, (list, dict)) or len(json.dumps(v)) < 400 else '<big>') for k, v in ms.items()}, indent=1))
print('largestProcess', b.get('largestProcess'), 'genCounter', b.get('genCounter'))
print('build', b.get('build'), 'product', b.get('product'), 'date', b.get('date'))
PAGE = ms.get('pageSize', 16384)
print()
print('file | pageSize | free act inact spec throt wired purg fileB anon | compressor_pages(phys) uncompressed | ratio | compressions decompressions | busyBufferCount | reason-ish')
for name, h, b, ms in rows:
    mp = ms.get('memoryPages', {})
    def g(k):
        return mp.get(k, ms.get(k))
    PAGE = ms.get('pageSize', 16384)
    MB = lambda p: f"{(p or 0) * PAGE / 1048576:.0f}"
    cp = ms.get('compressorSize'); un = ms.get('uncompressed')
    ratio = (un / cp) if cp and un else None
    reasons = collections.Counter(p.get('reason') for p in b.get('processes', []) if p.get('reason'))
    print(name[12:29], PAGE, '|', ' '.join(MB(g(k)) for k in ('free', 'active', 'inactive', 'speculative', 'throttled', 'wired', 'purgeable', 'fileBacked', 'anonymous')),
          '|', MB(cp), MB(un), '|', f"{ratio:.2f}" if ratio else '-', '|', ms.get('compressions'), ms.get('decompressions'), '|', ms.get('busyBufferCount'), '|', dict(reasons))
