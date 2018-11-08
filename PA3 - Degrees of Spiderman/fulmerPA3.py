#PA3 Algorithms
#Six Degrees of Spiderman

import random
import numpy
import time


def readInFile():
    infile = open("porgat.txt")
    throwAway = infile.readline()
    file = infile.readlines()
    return file

def makeStringArray(textFile):
    stringArray = [''] * 19428
    edges = [''] * (len(textFile)-19429)
    index = 0
    for x in range(19428):
        num, name = textFile[x].split(" ",1)
        stringArray[index] = name.rstrip()
        index += 1
    index = 0
    for x in range(19429, len(textFile)):
        edges[index] = textFile[x].rstrip()
        index += 1
    return stringArray, edges

def makeComicArray(arr):
    comicMatrix = [[bool(0) for x in range(12942)] for y in range(6486)]
    for x in range(0,len(arr)-1):
        hero, rhs = arr[x].split(' ', 1)
        comics = rhs.split(' ')
        for comic in comics:
            comicMatrix[int(hero)-1][int(comic)-6487] = 1
    return comicMatrix

def makeCollabMatrix(comicArr, stringArr):
    collabMatrix = [[0 for x in range(6486)] for y in range(6486)]
    degrees = 1
    spiderNum = [0] * 6486
    #creating the identity matrix
    for x in range(6486):
        collabMatrix[x][x] = 1
    
    #moving all associations to the collaberation matrix
    print("Building the collaberation matrix.")
    start = time.perf_counter()
    for x in range(6486):
        for y in range(12942):
            if comicArr[x][y] == 1:
                for z in range(6486):
                    if comicArr[z][y] == 1:
                        collabMatrix[x][z], collabMatrix[z][x] = 1, 1
    elapsed = time.perf_counter() - start
    print("Took {} seconds to build.".format(elapsed))


    #Using NumPy for matrix multiplication to get the degrees of separation
    start = time.perf_counter()
    while degrees <= 3:
        print("Working on degree {}.".format(degrees))
        for x in range(6486):
            if collabMatrix[5305][x] != 0:
                if spiderNum[x] == 0:
                    spiderNum[x] = degrees
        collabMatrix = numpy.matmul(collabMatrix, collabMatrix)
        
                
        degrees += 1
        
    spiderNum[5305] = 0
    elapsed = time.perf_counter() - start
    print("Took {} seconds to get all Spiderman Numbers.".format(elapsed))
    return spiderNum
            

def displayIt(stringArr, spiderNums, hero):
    for x in range(hero):
        index = random.randint(0,6486)
        print('{} has a Spiderman number of {}.'.format(stringArr[index], spiderNums[index]))



def main():
    file = readInFile()
    stringArray, edges = makeStringArray(file)
    comicArray = makeComicArray(edges)
    spiderNum = makeCollabMatrix(comicArray, stringArray)
    heroes = int(input("How many heroes do you want displayed? "))
    displayIt(stringArray, spiderNum, heroes)



if __name__ == '__main__':
    main()





    
