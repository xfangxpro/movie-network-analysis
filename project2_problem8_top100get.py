#!/usr/bin/python
# Refer to edge generation algorithm in GitHub

import re
f = open("top_100_movies.txt", "r")
p = open("director_movies.txt", "r")
q = "director_100.txt"

Dict_Movie = {}


movies = {}

for line in f.readlines():
	tokens = line.strip()
	movies[tokens] = tokens

print("Movie length" + str(len(movies)))

i=0
match =0 
for line in p.readlines():
	i+=1
	tokens = line.split("\t\t")
	dirName = tokens[0]
	#print("Director name" + str(dirName).encode("ascii", "ignore"))
	movielist = tokens[1:]
	copy = False
	for movie in movielist:
		movie=movie.strip()
		if movie in movies:
			print(movie + "\n")
			copy = True
			match +=1
			break
	if copy == True:
		for movie in movielist:
			if movie in Dict_Movie:
				continue
			else:
				Dict_Movie[movie] = movie
print("No of directors:" + str(i) + "matched: " + str(match))

with open(q,"w") as fil:	
	for k, v in Dict_Movie.items():
		fil.write(str(v))
		fil.write("\n")		

f.close()
p.close()
