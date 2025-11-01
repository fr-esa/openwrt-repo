import os
import sys
import hashlib

dirpath = 'packages'
files = sorted(f for f in os.listdir(dirpath) if f.endswith('.ipk'))

if not files:
    print('No .ipk files found', file=sys.stderr)
    sys.exit(1)

with open(os.path.join(dirpath, 'Packages'), 'w') as out:
    for f in files:
        path = os.path.join(dirpath, f)
        size = os.path.getsize(path)
        with open(path, 'rb') as fileobj:
            h = hashlib.sha256()
            while chunk := fileobj.read(8192):
                h.update(chunk)
        out.write(f'Package: {f}\n')
        out.write(f'Size: {size}\n')
        out.write(f'SHA256: {h.hexdigest()}\n\n')
