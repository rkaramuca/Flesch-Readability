# bisect is binary search for dale-chall
from bisect import bisect_left
# math for ceiling
import math
# sys for command line arguments 
import sys

def parseFile( fileName, numSentences, fileContents ):
	# opens file "fileName" in read mode
	infile = open( fileName, "r", encoding="cp1250" )

	for line in infile:
		word = ""
		for i in range( len( line ) ):
			# if the current char, one in front of it, or one behind it
			# is a letter, add it to word
			if( i > 0 and i < len( line ) - 2 ):
				if( ( line[ i ].isalpha() or
				      line[ i - 1 ].isalpha() or
				      line[ i + 1 ].isalpha() or
					  line[ i ] == '\'' or
				      len( word ) > 0 ) and 
				    ( line[ i ].isalpha() or
		              line[ i ].isdigit() or
					  line[ i ] == '\'' ) ):
					word += line[ i ]
			else:
				if( line[ i ].isalpha() or line[ i ] == '\'' ):
					word += line[ i ]
			
			# if it's an end-of-sentence marker, add one to sentence counter
			if( line[ i ] == '.' or line[ i ] == '?' or 
			    line[ i ] == '!' or line[ i ] == ':' or
			    line[ i ] == ';' ):
				numSentences += 1
			
			# if the character is a space, and the word is not empty, push it to the array
			if( line[ i ] == ' ' ):
				if( word != "" and word != " " ):
					fileContents.append( word.lower() )
					word = ""
		# if there's somehow still something leftover in word (typically end of sentences), push
		# it to the arry
		if( word != "" ):
			fileContents.append( word.lower() )
			word = ""

	# close file and return number of sentences
	infile.close()
	return numSentences

def syllableCount( numSyllables, fileContents ):
	for words in fileContents:
		currWord = words
		currSylls = 0
		for i in range( len( currWord ) ):
			# if the current letter is a vowel, increase temporary count by one
			if( currWord[ i ] == 'a' or currWord[ i ] == 'e' or
			    currWord[ i ] == 'i' or currWord[ i ] == 'o' or
			    currWord[ i ] == 'u' or currWord[ i ] == 'y' ):
				currSylls += 1
				# if the one next to it is a vowel, decrease the temp count by one
				if( i < len( currWord ) - 1 ): 
					if( currWord[ i + 1 ] == 'a' or currWord[ i + 1 ] == 'e' or
				    	    currWord[ i + 1 ] == 'i' or currWord[ i + 1 ] == 'o' or
				    	    currWord[ i + 1 ] == 'u' or currWord[ i + 1 ] == 'y' ):
						currSylls -= 1
		
		# last-letter 'e' is not counted as a syllable
		if( currWord[ len( currWord ) - 1 ] == 'e' ):
			currSylls -= 1
		
		# every word must have 1 syllable, so this checks if the word is missing one
		if( currSylls < 1 ):
			currSylls = 1

		numSyllables += currSylls

	return numSyllables

def buildWordList( wordsFile, wordList ):
	infile = open( wordsFile, "r" )
	for line in infile:
		wordList.append( line.rstrip().lower() )
	
	infile.close()

def difficultWords( diffWords, fileContents, wordList ):
	# sort bible contents and dale-chall lists to prep for binary search
	fileContents.sort()
	wordList.sort()

	# check the dale-chall wordlist, looking for an abscence of the current word
	# in the fileContents array
	for word in fileContents:
		# this returns the index of the found word OR the index where it should be placed
		found = bisect_left( wordList, word )
		# check if the word is truly found (or NOT), then add one to difficult words counter
		if not( found != len( wordList ) and wordList[ found ] == word ):
			diffWords += 1
		
	return diffWords

def flesch( numSyllables, numWords, numSentences, fleschIndex ):
	sylls = float( numSyllables )
	words = float( numWords )
	sentences = float( numSentences )

	alpha = sylls / words
	beta = words / sentences
	fleschRaw = 206.832 - ( alpha * 84.6 ) - ( beta * 1.015 )
	fleschIndex = math.ceil( fleschRaw * 10 ) / 10
	
	return fleschIndex

def fleschKincaid( numSyllables, numWords, numSentences, fleschKincaid ):
	sylls = float( numSyllables )
	words = float( numWords )
	sentences = float( numSentences )
	
	alpha = sylls / words
	beta = words / sentences
	fleschKincaidRaw = ( alpha * 11.8 ) + ( beta * 0.39 ) - 15.59 
	fleschKincaid = math.ceil( fleschKincaidRaw * 10 ) / 10

	return fleschKincaid

def daleChall( diffWords, numWords, numSentences, daleChall ):
	diff = float( diffWords )
	words = float( numWords )
	sentences = float( numSentences )
	
	alpha = diff / words
	beta = words / sentences
	daleChallRaw = ( 0.1579 * ( alpha * 100.0 ) ) + ( beta * 0.0496 )
	if( alpha * 100.0 > 5 ):
		daleChallRaw += 3.6365
	daleChall = math.ceil( daleChallRaw * 10 ) / 10

	return daleChall
