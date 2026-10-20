import plistlib, sys, json
p = plistlib.load(open(__import__('os').path.join(__import__('os').path.dirname(__import__('os').path.abspath(__file__)),'..','data','iphone','ioreg_service.plist'),'rb'))
root = p.get('IORegistry', p)
hits = []
def walk(n, path):
    if isinstance(n, dict):
        name = n.get('IORegistryEntryName') or n.get('name') or ''
        cls = n.get('IOObjectClass') or n.get('class') or ''
        np = path + [f"{name}<{cls}>"]
        keys = set(n.keys())
        interesting = any(k in keys for k in ('PerformanceStatistics','AGXParameterBufferMaxSize','ANEDevicePropertyNumANECores')) \
            or any(s in (name+cls).lower() for s in ('agx','ane','h11ane','h13ane','memory','dart','pmgr','iosurface','compressor','dram','mcc','amcc','vm'))
        if interesting:
            d = {k: v for k, v in n.items() if k not in ('IORegistryEntryChildren','children') and not isinstance(v, (bytes,)) }
            for k,v in n.items():
                if isinstance(v, bytes) and len(v) <= 16: d[k] = v.hex()
            hits.append((' / '.join(np[-3:]), d))
        for k in ('IORegistryEntryChildren','children'):
            for c in n.get(k, []) or []:
                walk(c, np)
    elif isinstance(n, list):
        for c in n: walk(c, path)
walk(root, [])
mode = sys.argv[1] if len(sys.argv) > 1 else 'list'
for path, d in hits:
    if mode == 'list':
        print(path, '| keys:', ','.join(list(d.keys())[:12]))
    elif mode in path.lower():
        print('=====', path)
        print(json.dumps(d, indent=1, default=str)[:6000])
