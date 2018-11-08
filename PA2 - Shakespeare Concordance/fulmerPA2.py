#PA2 - Algorithms
#Lucas Fulmer

import time

#creating a class for the words we read in
class WordEntry:

    word = ' '
    numEntries = 0

    def __init__(self):
        self.word = ''
        self.numEntries = 1

    def __init__(self, addWord, num):
        self.word = addWord
        self.numEntries = num
        
    def incrEntry(self):
        self.numEntries += 1

    def __lt__(self, other):
        return self.word < other.word

    def __eq__(self, other):
        return self.word == other.word

#creating a hash table data structure
#taken from http://interactivepython.org/runestone/static/pythonds/SortSearch/Hashing.html
class HashTable:

    def __init__(self):
        self.size = 27886
        self.slots = [None] * self.size
        self.data = [None] * self.size

    def put(self,key,data):
        hashvalue = self.hashfunction(key,len(self.slots))

        if self.slots[hashvalue] == None:
            self.slots[hashvalue] = key
            self.data[hashvalue] = data
        else:
            if self.slots[hashvalue] == key:
                self.data[hashvalue] = data  #replace
            else:
                nextslot = self.rehash(hashvalue,len(self.slots))
                while self.slots[nextslot] != None and self.slots[nextslot] != key:
                    nextslot = self.rehash(nextslot,len(self.slots))

            if self.slots[nextslot] == None:
                self.slots[nextslot]=key
                self.data[nextslot]=data
            else:
                self.data[nextslot] = data #replace

    def hashfunction(self,key,size):
        return key % size

    def rehash(self,oldhash,size):
        return (oldhash+1)%size   

    def get(self,key):
        startslot = self.hashfunction(key,len(self.slots))

        data = None
        stop = False
        found = False
        position = startslot
        while self.slots[position] != None and not found and not stop:
            if self.slots[position] == key:
                found = True
                data = self.data[position]
            else:
                position=self.rehash(position,len(self.slots))
                if position == startslot:
                    stop = True
        return data

    def __getitem__(self,key):
        return self.get(key)

    def __setitem__(self,key,data):
        self.put(key,data)

        

#iterative binary search for our sortedArray function
def binSearch(arr, start, end, value):
    global bincompare
    
    if end == 0:
        if arr[0].word == value:
            return 0
        else:
            return -1
    while start <= end:
        mid = int((start + end) / 2)
        bincompare += 1
        if arr[mid].word == value:
                return mid

        elif arr[mid].word < value:
            start = mid + 1

        else:
            end = mid - 1

    return -1






    
#Function to read in shakespear.txt into unsorted array
def unsortedArray(textfile):
    infile = open(textfile, 'r')
    entryArray = []
    compare = 0
    assign = 1
    first = infile.readline()
    first = first.replace('\n', '')
    entryArray.append(WordEntry(first.lower(), 1))
    for line in infile:
        tempWord = line
        if tempWord[0].isalpha():
            tempWord = tempWord.replace('\n', '')
            entry = WordEntry(tempWord.lower(), 1)
            for x in range(len(entryArray)):
                compare += 1
                if entry.word == entryArray[x].word:
                    entryArray[x].numEntries += 1
                    break
                elif x == len(entryArray)-1:
                    assign += 1
                    entryArray.append(entry)
    infile.close()
    print('There are {} comparisons and {} assignments in the unsorted array'.format(compare, assign))
    return entryArray

#reads in the text file, uses binary search and sorts each entry
def sortedArray(textfile):
    global bincompare
    bincompare = 0
    assign = 1
    infile = open(textfile, 'r')
    entryArray = []
    first = infile.readline()
    first = first.replace('\n', '')
    entryArray.append(WordEntry(first.lower(), 1))#adding the first word
    
    for line in infile:#going through the file line-by-line/word-by-word

        tempWord = line

        if tempWord[0].isalpha():#making sure that first character is alphabetic

            tempWord = tempWord.replace('\n', '')
            entry = WordEntry(tempWord.lower(), 1)
            index = binSearch(entryArray, 0, len(entryArray)-1, entry.word)

            if index != -1:
                entryArray[index].numEntries += 1

            else:
                entryArray.append(entry)
                entryArray.sort()
                assign += 1

    infile.close()
    print('There were {} comparisons and {} assignments in the sorted search'.format(bincompare, assign))
    return entryArray
        
#using our hashing function
def readIntoHash(textfile):
    infile = open(textfile, 'r')
    hashWords = HashTable()
    first = infile.readline()
    first = first.replace('\n', '')
    hashWords.put(hash(first.lower()), WordEntry(first.lower(), 1))
    compare = 0
    for line in infile:
        tempWord = line
        if tempWord[0].isalpha():
            tempWord = tempWord.replace('\n','')
            entry = WordEntry(tempWord.lower(), 1)
            if hashWords.get(hash(entry.word)):
                compare += 1
                hashWords[hash(entry.word)].numEntries += 1
            else:
                hashWords.put(hash(entry.word), entry)
            
    infile.close()
    return compare

def builtInHash(textfile):
    infile = open(textfile, 'r')
    hashWords = dict()
    first = infile.readline()
    first = first.replace('\n', '')
    hashWords[first.lower()] = WordEntry(first.lower(), 1)
    for line in infile:
        tempWord = line
        if tempWord[0].isalpha():
            tempWord = tempWord.replace('\n','')
            entry = WordEntry(tempWord.lower(), 1)
            if entry.word in hashWords:
                hashWords[entry.word].numEntries += 1
            else:
                hashWords[entry.word] = entry
            
    infile.close()
    return hashWords

start = time.perf_counter()
unsorted = unsortedArray('wordlist.txt')
elapsed = (time.perf_counter() - start)
print("Unsorted took {} seconds.".format(elapsed))
unsorted.sort()
print("Here are the first 10 and last 10 entries of the unsorted array")
##for x in range(10):
##    print("{} : {}".format(unsorted[x].word, unsorted[x].numEntries))
##
##print('------------------------------')
##
##for x in range(len(unsorted)-10, len(unsorted)):
##    print("{} : {}".format(unsorted[x].word, unsorted[x].numEntries))

start = time.perf_counter()
sortArray = sortedArray('wordlist.txt')
elapsed = (time.perf_counter() - start)
print('Sorted took {} seconds.'.format(elapsed))

start = time.perf_counter()
myhash = readIntoHash('wordlist.txt')
elapsed = (time.perf_counter() - start)
print('My hash took {} seconds.'.format(elapsed))
hashing = builtInHash('wordlist.txt')

numWords = len(hashing)

print("Now printing the results of the sorted array.")
for x in range(10):
    print("{} : {}".format(sortArray[x].word, sortArray[x].numEntries))

print('------------------------------')

for x in range(len(sortArray)-10, len(sortArray)):
    print("{} : {}".format(sortArray[x].word, sortArray[x].numEntries))




print('There were {} comparisons in the hashing function.'.format(myhash))

print("There are {} unique words.".format(numWords))
flag = 0
for i, x in enumerate (sorted(hashing)):
    if i < 10:
        print('{} : {}'.format(x, hashing[x].numEntries))

    elif i == 11:
        print('---------------------------')
        
    elif i < len(hashing) and i > len(hashing)-11:
        print('{} : {}'.format(x, hashing[x].numEntries))

