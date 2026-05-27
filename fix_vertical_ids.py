import os
p = 'assets/data/second_floor.json'
with open(p, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('"F2_V_', '"V_')

with open(p, 'w', encoding='utf-8') as f:
    f.write(content)
