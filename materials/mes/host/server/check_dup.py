import os

with open('tdata_vars.csv', encoding='utf-8') as f, \
     open('uniq.txt', 'w', encoding='utf-8') as w:
    seen = set()
    for line in f:
        if line not in seen:
            seen.add(line)
            w.write(line)