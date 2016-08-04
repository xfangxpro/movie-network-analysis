#!/usr/bin/python


# Read the average rating for each movie connected to the movie and output it
import string
f = open("ratings-filtered.txt", 'r')
g = open("node2_sort.txt", 'r')
dic = {}
for line in f.readlines():
    pos = 0
    for i in line:
        if i == ' ':
            break
        pos += 1
    a = line[0:pos]
    b = line[pos + 1:len(line) - 1]
    b = float(b)
    dic[a] = b
count = 0
total = 0
for line in g.readlines():
    pos = 0
    for i in line:
        if i == ' ':
            break
        pos += 1
    a = line[0:pos]
    if a in dic:
        total += dic[a]
        count += 1
ans = total / count
line = "The approximate rating of node3 is %.3f by using its %d neighbors.\n" % (ans, count)
print(line)
g.close()
f.close()
