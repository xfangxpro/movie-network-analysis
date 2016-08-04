library(igraph)
library(hash)
library(sets)

Sys.setlocale(locale = "C")


############################################################################################## 
#                                         QUESTION 1                                         #                                 
##############################################################################################
# Set up all the prerequisites before proceeding to create graphs.  
setwd("~/Documents/grad_school/spring_2016/EE_232E/project2/project_2_data/")
actorFile = "actor_movies.txt"
actressFile = "actress_movies.txt"
allActorsFile = "actors_and_actresses.txt"

actors = readLines(actorFile)
actresses = readLines(actressFile)

# Combine all actors/actresses into 1 text file
write(actors, file = allActorsFile)
write(actresses, file = allActorsFile, append = TRUE)

allActors = readLines(allActorsFile)
allLen = length(allActors)

# Disregard actors who have been in less than 5 movies.  
movieCutoff = 5
actID = 1
movieID = 0
actNumber = list()
actHash = hash()

entrySplit = "[\t]+"
extraParens = "^\\("
nonYear = "\\([^[:digit:]]+\\)"
extraSpace = "^\\s+|\\s+$"
tempEntry = character()

# Using hashing, associate each movie with the actors who star in that particular movie.  
for (i in 1:allLen)
{
  entry = strsplit(allActors[i], entrySplit)[[1]]
  entryLength = length(entry)
  
  if (entryLength > movieCutoff)
  {
    actName = entry[1]
    actNumber[[actID]] = c(actName, entryLength - 1)
    for (j in 2:entryLength)
    {
      tempEntry = gsub(extraParens, "", entry[j])
      tempEntry = gsub(nonYear, "", tempEntry)
      tempEntry = gsub(extraSpace, "", tempEntry)
      actKey = actHash[[tempEntry]]
      if(is.null(actKey))
      {
        actHash[tempEntry] = c(movieID, actID)
        movieID = movieID + 1
      }
      else
      {
        actHash[tempEntry] = c(actKey, actID)
      }
    }
    actID = actID + 1
  }
}


############################################################################################## 
#                                         QUESTION 2                                         #                                 
############################################################################################## 
# Hash the edgelist values for when we actually generate the edge list
hashKeys = values(actHash)

hashedEdgeWeights = hash()
hashKeyLen = length(hashKeys)

for(i in 1:hashKeyLen)
{
  thisHashKey = hashKeys[[i]]
  thisKeyLength = length(thisHashKey)
  if(thisKeyLength > 2)
  {
    allCombos = combn(thisHashKey[2:thisKeyLength], 2)
    firstComparee = allCombos[1,]
    secondComparee = allCombos[2,]
    totalTraversals = length(allCombos) / 2
    
    for(j in 1:totalTraversals) 
    {
      thisEdge = paste(firstComparee[j], 
                       secondComparee[j], 
                       sep = " ")
      thisWeight = hashedEdgeWeights[[thisEdge]]
      hashedEdgeWeights[thisEdge] = ifelse(is.null(thisWeight), 1, thisWeight + 1)
    }
  }
}

# Generate the edgelist (HUGE FILE)
edgeList = matrix(nrow = 2 * length(hashedEdgeWeights),
                  ncol = 3)
i = 1
for(key in keys(hashedEdgeWeights))
{
  edgeWeight = hashedEdgeWeights[[key]]
  edge = strsplit(key," ")
  firstNodeEdge = edge[[1]][1]
  secondnodeEdge = edge[[1]][2]
  node1 = as.numeric(firstNodeEdge)
  node2 = as.numeric(secondnodeEdge)
  edgeList[i,1] = node1
  edgeList[i,2] = node2
  edgeList[i,3] = round(edgeWeight/strtoi(actNumber[[node1]][2]), 3)
  edgeList[i,3] = round(edgeWeight/strtoi(actNumber[[node1]][2]), 3)
  edgeList[i+1,1] = node2
  edgeList[i+1,2] = node1
  edgeList[i+1,3] = round(edgeWeight/strtoi(actNumber[[node2]][2]), 3)
  i = i + 2
}


############################################################################################## 
#                                         QUESTION 3                                         #                                 
############################################################################################## 
# Create the main graph, where vertices represent actors/actresses
mainGraph = graph.edgelist(edgeList[,1:2], 
                           directed = TRUE)
E(mainGraph)$weight = edgeList[,3]

dlist = read.table(damn, sep = " ", header = FALSE)
dlist[,1] = as.character(dlist[,1])
dlist[,2] = as.character(dlist[,2])
movieGraph = graph.edgelist(as.matrix(dlist[,1:2, drop = FALSE]),
                            directed=FALSE) 
E(movieGraph)$weight = round(dlist[,3]) 
E(g2)$weight = damn[,3]

scores = page.rank(mainGraph)$vector
sortedScores = sort(scores,
                    index.return = TRUE,
                    decreasing = TRUE)

# Gather scores for top 10 actors/actresses
top10ID = sortedScores$ix[1:10]
top10Names = actNumber[top10ID]
for (i in 1:length(top10Names)) 
{
  this = grep(top10Names[[i]][1], actNumber)
  cat(scores[this], top10Names[[i]][1], '\n')
}

# Our top 10 list...
myTop10 = c("Cruise, Tom", 
            "Brando, Marlon", 
            "Brahmanandam",
            "Jolie, Angelina",
            "Nicholson, Jack",
            "DiCaprio, Leonardo",
            "Seagal, Steven",
            "Law, Jude",
            "Ferrell, Will",
            "Freeman, Morgan")
for (i in 1:length(myTop10)) 
{
  this = grep(myTop10[i], actNumber)
  cat(scores[this], myTop10[i],'\n')
}


############################################################################################## 
#                                         QUESTION 4                                         #                                 
############################################################################################## 
# hashKeys = readRDS("hashKeys.rds")
# actNumber = readRDS("actNumber.rds")
movieEdgeFile = "movieedgelist.txt"
actCountCutoff = 25
numActEachMovie = sapply(hashKeys, length)
qualifiedMovies = hashKeys[numActEachMovie >= actCountCutoff]
qualifiedMovies = append(qualifiedMovies, hashKeys["Minions (2015)"])

qualMovieLen = length(qualifiedMovies)
movieEdgelist = matrix(nrow = 250 * qualMovieLen, ncol = 3)
matCount = 1

# Process the matrix for Python input (to create the edgelist)
n.obs = sapply(qualifiedMovies, length)
seq.max = seq_len(max(n.obs))
matsmall = t(sapply(qualifiedMovies, "[", i = seq.max))
write.table(matsmall, 
            file = "movies_jaccardplease_small.txt", 
            sep = " ", 
            na = "", 
            row.names = F, 
            col.names = F)

saveRDS(movieGraph, "movieGraphsmall.rds")
# NOTE: The following loop works, but takes forever to run.
# Therefore, please refer to our awesome Python code project_problem4.py
# for a Python implementation of this question.
for (i in 1:(qualMovieLen - 1))
{
  for (j in (i+1):qualMovieLen)
  {
    firstMovie = qualifiedMovies[[i]]
    secondMovie = qualifiedMovies[[j]]
    sharedAct = intersect(qualifiedMovies[[i]], qualifiedMovies[[j]])

    if (length(sharedAct) > 0)
    {
      firstID = firstMovie[1]
      secondID = secondMovie[1]
      firstAct = gset(firstMovie[2:length(firstMovie)])
      secondAct = gset(secondMovie[2:length(secondMovie)])
      jaccardIndex = round(gset_similarity(firstAct, secondAct, "Jaccard"), 5)

      movieEdgelist[matCount, 1] = firstID
      movieEdgelist[matCount, 2] = secondID
      movieEdgelist[matCount, 3] = jaccardIndex
      matCount = matCount + 1
    }
  }
  print(i)
}

movieEdgeFile = "movieedgelist_small.txt"

# Generate the graph to be used in question 5 (for community detection)
elist = read.table(movieEdgeFile, sep = " ", header = TRUE)
elist[,1] = as.character(elist[,1])
elist[,2] = as.character(elist[,2])
movieGraph = graph.edgelist(as.matrix(elist[,1:2, drop = FALSE]),
                            directed=FALSE) 
E(movieGraph)$weight = round(elist[,3], 5) 

# Uncomment below to save objects for convenience
# saveRDS(movieGraph, "movieGraph.rds")


############################################################################################## 
#                                         QUESTION 5                                         #                                 
##############################################################################################
# Import the movie genre file for tagging purposes
movieGenreFile = "movie_genre.txt"
genres = readLines(movieGenreFile)
genreList = list()

for (i in 1:length(genres)) {
  genreEntry = strsplit(genres[i], entrySplit)[[1]]
  genreList[[i]] = c(genreEntry[1], genreEntry[2])
  print(i)
}

genreList[[1]]
V(movieGraph)[[1]]$name
qualifiedMovies[[as.numeric(V(movieGraph)[[1]]$name)]][1]

for (i in 1:length(movieGraph)) {
  movieHashIndex = as.numeric(V(movieGraph)[[i]]$name)
  V(movieGraph)[[i]]$genre = genres[[names(which(movieHashIndex %in% qualifiedMovies))]][2]
}

# Use fast greedy to find communities
movieGraph = readRDS("movieGraph.rds")
fastGreedyMovie = fastgreedy.community(movieGraph)

hist(fastGreedyMovie$membership,
     col="red",
     main="Community Distribution (Fast Greedy)",
     xlab="Community Number",
     ylab="Community distributions for threshold greater than 25")

# Getting the membership
filePath = "D:/UCLA/Spring 2016/EE232E/Project2/smallgraph-results.rds"
#Read and load graph
g1 <- readRDS(filePath)

x <- which.max(sizes(g1))

x1 <- g1$membership
y1 <- g1$names

#Superman
i1 <- match("11445",y1)
i2 <- match("57998",y1)
i3 <- match("121858",y1)

xy<- x1[i3]

#Superman - 11445
#MI - 57998
#Minions

############################################################################################## 
#                                         QUESTION 6                                         #                                 
##############################################################################################
# NOTE: To speed things up (once again), we've implemented this section in Python. 
# Refer to our PythonFiles directory for more details.
# The code below is used for testing purposes (to compare R against Python)

newMovies = c("Batman v Superman: Dawn of Justice (2016)", 
              "Mission: Impossible - Rogue Nation (2015)",
              "Minions (2015)")

batmanMovieNeighbors = neighborhood(movieGraph, 
                                    order = 1,
                                    node = qualifiedMovies[[newMovies[1]]][1])

missionMoviesNeighbors = neighborhood(movieGraph, 
                                      order = 1,
                                      node = qualifiedMovies[[newMovies[2]]][1])

minionMovieNeighbors = neighborhood(movieGraph, 
                                    order = 1,
                                    node = qualifiedMovies[[newMovies[3]]][1])


############################################################################################## 
#                                         QUESTION 7                                         #                                 
##############################################################################################
# Refer to our Python code for details regarding this question. (project_problem7.py and more)  


############################################################################################## 
#                                         QUESTION 8                                         #                                 
##############################################################################################
# NOTE: Refer to our Python code for details regarding this question. (project_problem8.py) 
entrySplit = "[\t]+"
extraParens = "^\\("
nonYear = "\\([^[:digit:]]+\\)"
extraSpace = "^\\s+|\\s+$"

# Attempt at cleaning up director file (deprecated since we did manual annotation of top
# 100 directors)
dl = "director_movies.txt"
directors = readLines(dl)
dlist = list()

for (i in 1:length(directors)) {
  entry = strsplit(directors[i], entrySplit)[[1]]
  for (j in 2:length(entry))
  tempEntry = gsub(extraParens, "", entry[j])
  tempEntry = gsub(nonYear, "", tempEntry)
  tempEntry = gsub(extraSpace, "", tempEntry)
}

