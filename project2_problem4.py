#!/usr/bin/python

import csv
import os

# NOTE: Tested on python 3.5

os.chdir("/Users/georgef/Documents/grad_school/spring_2016/EE_232E/project2/project_2_data")

# Read in the movie hash table...
with open('movies_jaccardplease_small.txt', 'r', newline = '') as f:
    reader = csv.reader(f, delimiter = ' ', quoting = csv.QUOTE_NONE)
    your_list = list(reader)

filteredList = [[x for x in group if x] for group in your_list]

# We define our own function since scikit-learn's version has a difficult time with non-uniform length lists.
def jaccard(a, b):
    c = a.intersection(b)
    return float(len(c)) / (len(a) + len(b) - len(c))

qualMovieLen = len(filteredList)

# Write out edges and weights to a text file.
with open("movieedgelist_light.txt", 'a') as thefile:
    for i in range(0, (qualMovieLen - 1)):
        for j in range((i + 1), qualMovieLen):
            first = filteredList[i]
            second = filteredList[j]
            firstMovie = first[0]
            secondMovie = second[0]
            firstMovieActors = first[1:]
            secondMovieActors = second[1:]
            setFirst = set(firstMovieActors)
            setSecond = set(secondMovieActors)
            if len(setFirst.intersection(setSecond)) > 0:
                this_jaccard = jaccard(set(setFirst), set(setSecond))
                thefile.write("{0} {1} {2}\n".format(firstMovie, secondMovie, this_jaccard))
        if i%1000 == 0:
            # Keep track of where we're at
            print(i)