#!/bin/bash
SRC='http://qd6z64dom.bkt.clouddn.com'; 
DST='http://qkp0gatay.hb-bkt.clouddn.com';
find . -type f -name "*.md" -exec sed -i 's,'"$SRC"','"$DST"',' {} \;