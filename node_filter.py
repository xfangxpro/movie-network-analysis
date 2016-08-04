#!/usr/bin/python
# Batman v Superman: Dawn of Justice (2016)  nodeID:894353
# Mission: Impossible - Rogue Nation (2015)  nodeID:779750
# Minions (2015)   nodeID:763762

import string
# This is the edgelist being used to generate ranks.
# We use the edgelist, and filter out all edges that contain mention of our nodeid
#Since we have codes with index as the number assigned, we can directly get the index of whichever movie we want to select
f = open("graph_movie.txt", 'r')
q = open("node2_sel.txt", 'w')
#Add nodeID here
nodeId = '779750'
for line in f.readlines():
    tokens = line.split('\t')
    if tokens[0] == nodeId or tokens[1] == nodeId:
        q.write(line)
q.close()
f.close()
