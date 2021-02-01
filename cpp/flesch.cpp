#include <iostream>
// iomanip to create 1 decimal fixed precision
#include <iomanip>
// fstream for file io
#include <fstream>
#include <string>
// use vector for easy content access for Bible contents
#include <vector>
// import math for ceiling function
#include <math.h>
// import algorithm for binary search on dale-chall list
#include <algorithm>
using namespace std;

// parseFile will split the file into a vector of strings (words)
// as well as get the word count using fileContents.size()
void parseFile( string fileName, int& numSentences, vector<string>& fileContents );
void syllableCount( int& numSyllables, vector<string> fileContents );
double flesch( int numSyllables, int numWords, int numSentences );
double fleschKincaid( int numSyllables, int numWords, int numSentences );
void buildWordList( string wordsFile, vector<string>& wordList );
void difficultWords( int& diffWords, vector<string> fileContents, vector<string> wordList );
double daleChall( int diffWords, int numWords, int numSentences );

int main( int argc, char* argv[ ] )
{
	// Fix any .0 number
	cout << fixed;
	cout << setprecision(1);

	// Prep fileName and fileContents for parseFile 
	string fileName = argv[ 1 ];
	vector<string> fileContents;

	// Call parseFile with the fileName and blank vector
	int numSentences;
	parseFile( fileName, numSentences, fileContents );
	
	// Word count would be the size of the string vector
	int numWords = fileContents.size();
	
	// Call syllableCount to get number of syllables
	int numSyllables;
	syllableCount( numSyllables, fileContents );	

	// Create the Dale-Chall word list
	vector<string> wordList;
	string wordsFile = "/pub/pounds/CSC330/dalechall/wordlist1995.txt";
	buildWordList( wordsFile, wordList );


	// Compare the words to get the Dale-Chall Score
	int diffWords;
	difficultWords( diffWords, fileContents, wordList );
	
	// Print out all statistics for the program
	cout << "Flesch Score:\t\t" << flesch( numSyllables, numWords, numSentences ) << endl;
	cout << "Flesch-Kincaid Score:\t" << fleschKincaid( numSyllables, numWords, numSentences ) << endl;
	cout << "Dale-Chall Score:\t" << daleChall( diffWords, numWords, numSentences ) << endl;
	
	return 0;
}

void parseFile( string fileName, int& numSentences, vector<string>& fileContents )
{
	// Opens the file passed in the parameters
	ifstream infile;
	infile.open( fileName );
	
	// Creates blank line to add each file-line to parse through
	string line = "";
	
	while( getline( infile, line ) ) {
		// Create blank string for chars to be added to, then push to vector
		string word = "";
		for( int i = 0; i < line.length(); i++ ) {
			// Checks if the char is not a number, character, or space. If it is a number
			// check if the char next to it or in front of it is a letter. Also, if it is
			// a number, check if the string has letters in it already.
			if( ( isalpha( line[ i ] ) || isalpha( line[ i - 1 ] ) || isalpha( line[ i + 1 ] ) || line[ i ] == '\'' || word.length() > 0 ) && line[ i ] != ' ' && ( isalpha( line[ i ] ) || isdigit( line[ i ] ) || line[ i ] == '\'' ) ) {
				word += tolower( line[ i ] );
			}
			if( line[ i ] == '.' || line[ i ] == '?' || line[ i ] == '!' || line[ i ] == ':' || line[ i ] == ';' ) {
				numSentences++;
			}
			// Checks if the char is the end of a word
			if( line[ i ] == ' ' ) {
				// If the word is not empty, push it to the vector and reset the word
				if( word != "" && word != " " ) {
					fileContents.push_back( word );
					word = "";
				}
			}
		}
		// After the loop, if the word still has content, push it to the vector
		if( word != "" ) {
			fileContents.push_back( word );
			word = "";
		}
	}
	infile.close();
}

void syllableCount( int& numSyllables, vector<string> fileContents ) 
{
	string currWord;

	for( int i = 0; i < fileContents.size(); i++ ) { 
		// check each word in the fileContents for vowels
		// if it is a vowel, ++. if the next is a vowel, --.
		currWord = fileContents[ i ];
		int currSylls = 0;
		for( int j = 0; j < currWord.length(); j++ ) {
			if( currWord[ j ] == 'a' || currWord[ j ] == 'e' || currWord[ j ] == 'i' ||
			    currWord[ j ] == 'o' || currWord[ j ] == 'u' || currWord[ j ] == 'y' ) {
				// if currWord[ j + 1 ] == vowel, numSyllables--;	
				currSylls++;
				if( currWord[ j + 1 ] == 'a' || currWord[ j + 1 ] == 'e' ||
				    currWord[ j + 1 ] == 'i' || currWord[ j + 1 ] == 'o' ||
				    currWord[ j + 1 ] == 'u' || currWord[ j + 1 ] == 'y' ) {
					currSylls--;
				}
			}			
		}
		// if the last letter is an e, --.
		if( currWord[ currWord.length() - 1 ] == 'e' ) {
			currSylls--;
		}
		// if there are "no syllables" in the word, add one
		if( currSylls < 1 ) {
			currSylls++;
		}
		numSyllables += currSylls;
	}
}

double flesch( int numSyllables, int numWords, int numSentences ) 
{
	double alpha = ( double )( ( double )numSyllables / ( double )numWords );
	double beta = ( double )( ( double )numWords / ( double )numSentences );
	double fleschIndexRaw = 206.835 - ( alpha * 84.6 ) - ( beta * 1.015 );		
	double fleschIndex = ceilf( fleschIndexRaw * 10 ) / 10;

	return fleschIndex;
}

double fleschKincaid( int numSyllables, int numWords, int numSentences ) 
{
	double alpha = ( double )( ( double )numSyllables / ( double )numWords );
	double beta = ( double )( ( double )numWords / ( double )numSentences );
	double fleschKincaidRaw = ( alpha * 11.8 ) + ( beta * 0.39 ) - 15.59;
	double fleschKincaidScore = ceilf( fleschKincaidRaw * 10 ) / 10;

	return fleschKincaidScore;
}

void buildWordList( string wordsFile, vector<string>& wordList )
{
	ifstream infile;
	infile.open( wordsFile );
	
	string line = "";

	// pull all words from wordlist1995.txt and push them to vector for comparison
	while( getline( infile, line ) ) {
		string pushLine = "";
		for( int i = 0; i < line.length(); i++ ) {
			pushLine += tolower( line[ i ] );
		}
		wordList.push_back( pushLine );
	}	
	infile.close();
}

void difficultWords( int& diffWords, vector<string> fileContents, vector<string> wordList )
{
	// sorts the bible and dale-chall lists to prep for binary search
	sort( fileContents.begin(), fileContents.end() );
	sort( wordList.begin(), wordList.end() );
	// if the bible word is not in the dale-chall list, increment difficult words counter
	for( int i = 0; i < fileContents.size(); i++ ) {
		if( !binary_search( wordList.begin(), wordList.end(), fileContents[ i ] ) ) {
			diffWords++;
		}
	}
}

double daleChall( int diffWords, int numWords, int numSentences ) 
{
	double alpha = ( double )( ( double )diffWords / ( double )numWords );
	double beta = ( double )( ( double )numWords / ( double )numSentences );
	double daleChallRaw =  ( 0.1579 * ( alpha * 100.0 ) ) + ( beta * 0.0496 );
	if( alpha * 100.0 > 5 ) {
		daleChallRaw += 3.6365;
	}
	double daleChallScore = ceilf( daleChallRaw * 10 ) / 10;
	
	return daleChallScore;	
}
