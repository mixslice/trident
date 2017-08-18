#!/usr/bin/env bash

set -e

mkdir -p /opt/python
cd /opt/python

if [[ -e /opt/python/.bootstrapped ]]; then
  exit 0
fi

if [[ -e /tmp/pypy.tar.bz2 ]]; then
  tar -xjf /tmp/pypy.tar.bz2 -C /opt/python
fi

mv -n pypy$PYTHON_VERSION-v$PYPY_VERSION-linux64 pypy

## library fixup
mkdir -p pypy/lib
ln -snf /lib64/libncurses.so.5.9 /opt/python/pypy/lib/libtinfo.so.5

mkdir -p /opt/python/bin

cat > /opt/python/bin/python <<EOF
#!/bin/bash
LD_LIBRARY_PATH=/opt/python/pypy/lib:$LD_LIBRARY_PATH exec /opt/python/pypy/bin/pypy "\$@"
EOF

export PATH="/opt/python/bin/:$PATH"

rm -f /tmp/pypy.tar.bz2
chmod +x /opt/python/bin/python
/opt/python/bin/python --version
