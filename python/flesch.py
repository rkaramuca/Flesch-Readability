#!/usr/bin/python3

from fleschFunctions import *

# sys is imported in fleschFunctions which allows us
# to get command line arguments via sys.argv, index
# 0 being the script running and 1 being the file name
fileName = sys.argv[ 1 ]
fileContents = []

numSentences = 0
numSentences = parseFile( fileName, numSentences, fileContents )
numWords = len( fileContents )

numSyllables = 0
numSyllables = syllableCount( numSyllables, fileContents )

wordsFile = "/pub/pounds/CSC330/dalechall/wordlist1995.txt"
wordList = []
buildWordList( wordsFile, wordList )

diffWords = 0
diffWords = difficultWords( diffWords, fileContents, wordList )

fleschIndex = 0.0
fleschIndex = flesch( numSyllables, numWords, numSentences, fleschIndex )

fleschKincaidScore = 0.0
fleschKincaidScore = fleschKincaid( numSyllables, numWords, numSentences, fleschKincaidScore )

daleChallScore = 0.0
daleChallScore = daleChall( diffWords, numWords, numSentences, daleChallScore )

print( f"Flesch Score:\t\t{ fleschIndex }" )
print( f"Flesch-Kincaid Score:\t{ fleschKincaidScore }" )
print( f"Dale-Chall Score:\t{ daleChallScore }" )
