import re

find = '[ ]500[ ]'
with open('access.log', 'r') as y:
    sources = y.read()

count = 0
for match in re.finditer(find, sources):
   count += 1
print(count)
