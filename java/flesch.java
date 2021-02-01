// math for ceiling function
import java.lang.Math;
// file io and basic utils
import java.io.*;
import java.util.*;

public class flesch
{
	public static void main( String[] args ) throws IOException
	{
		// Gets file name from command line argument 
		String fileName = args[ 0 ];
		ArrayList<String> fileContents = new ArrayList<String>();

		int numSentences = 0;
		numSentences = parseFile( fileName, numSentences, fileContents );
		int numWords = fileContents.size();

		int numSyllables = 0;
		numSyllables = syllableCount( numSyllables, fileContents );
		
		ArrayList<String> wordList = new ArrayList<String>();
		String wordsFile = "/pub/pounds/CSC330/dalechall/wordlist1995.txt";
		buildWordList( wordsFile, wordList );		
	
		int diffWords = 0;
		diffWords = difficultWords( diffWords, fileContents, wordList );
		
		double fleschIndex = 0;
		fleschIndex = flesch( numSyllables, numWords, numSentences, fleschIndex );

		double fleschKincaid = 0;
		fleschKincaid = fleschKincaid( numSyllables, numWords, numSentences, fleschKincaid );
		
		double daleChall = 0;
		daleChall = daleChall( diffWords, numWords, numSentences, daleChall );

		System.out.println( "Flesch Score:\t\t" + Double.toString( fleschIndex ) );
		System.out.println( "Flesch-Kincaid Score:\t" + Double.toString( fleschKincaid ) );
		System.out.println( "Dale-Chall Score:\t" + Double.toString( daleChall ) );	
	}

	public static int parseFile( String fileName, int numSentences, ArrayList<String> fileContents ) throws IOException
	{
		File infile = new File( fileName );
		Scanner fileScan = new Scanner( infile );
		
		// Tokenize the input file
		String line = "";
		while( fileScan.hasNextLine() ) {
			String word = "";
			line = fileScan.nextLine();
			for( int i = 0; i < line.length(); i++ ) {
				// avoids array OOB by only checking +-1 when the index isn't the beginning or end
				if( i > 0 && i < line.length() - 2 ) {
					// if the character, the one in front of, or the one after it is a letter
					// or there is already letters in the word AND it's not a space AND
					// it's either a letter or a digit, add it to the word.
					if( ( Character.isLetter( line.charAt( i ) ) || 
					      Character.isLetter( line.charAt( i - 1 ) ) ||
					      Character.isLetter( line.charAt( i + 1 ) ) ||
						  line.charAt( i ) == '\'' || word.length() > 0 ) &&
					      line.charAt( i ) != ' ' &&
					    ( Character.isLetter( line.charAt( i ) ) ||	
					      Character.isDigit( line.charAt( i ) ) || 
						  line.charAt( i ) == '\'' ) ) {
						word += Character.toLowerCase( line.charAt( i ) );
					}
				}
				else {
					if( Character.isLetter( line.charAt( i ) ) || line.charAt( i ) == '\'' ) {
						word += Character.toLowerCase( line.charAt( i ) );
					}
				}
				
				// look for end of sentence symbols
				if( line.charAt( i ) == '.' || line.charAt( i ) == '?' || line.charAt( i ) == '!' || 
			    	    line.charAt( i ) == ':' || line.charAt( i ) == ';' ) {
					numSentences++;
				}

				// if it's a space, push the word to the arraylist
				if( line.charAt( i ) == ' ' ) {
					if( !word.equals( "" ) && !word.equals( " " ) ) {
						fileContents.add( word );
						word = "";
					}
				} 
			}
			if( !word.equals( "" ) ) {
				fileContents.add( word );
				word = "";
			}
		}
		fileScan.close();
		return numSentences;
	}
	
	public static int syllableCount( int numSyllables, ArrayList<String> fileContents )
	{
		String currWord;
		
		for( int i = 0; i < fileContents.size(); i++ ) {
			currWord = fileContents.get( i );
			int currSylls = 0;	
			// if the letter is a vowel, current word syllables increase. If the one
			// before it is also a vowel, current word syllables decrease.  
			for( int j = 0; j < currWord.length(); j++ ) {
				if( currWord.charAt( j ) == 'a' || currWord.charAt( j ) == 'e' ||
				    currWord.charAt( j ) == 'i' || currWord.charAt( j ) == 'o' ||
				    currWord.charAt( j ) == 'u' || currWord.charAt( j ) == 'y' ) {
					currSylls++;
					if( j < currWord.length() - 1 && 
					  ( currWord.charAt( j + 1 ) == 'a' || currWord.charAt( j + 1) == 'e' ||
					    currWord.charAt( j + 1 ) == 'i' || currWord.charAt( j + 1) == 'o' ||
					    currWord.charAt( j + 1 ) == 'u' || currWord.charAt( j + 1) == 'y' ) ) {
						currSylls--;
					}
				}
			}
		
			// if the last character is an 'e', currSylls-- because eos 'e' isn't a syllable
			if( currWord.charAt( currWord.length() - 1 ) == 'e' ) {
				currSylls--;
			}

			// if there are no syllables in the word, make them 1 because words have to have one	
			if( currSylls < 1 ) {
				currSylls = 1;
			}
			numSyllables += currSylls;
		}
		return numSyllables;
	}
	
	public static void buildWordList( String wordsFile, ArrayList<String> wordList ) throws IOException 
	{
		File infile = new File( wordsFile );
		Scanner fileScan = new Scanner( infile );	

		// file comes in as a \n separated list, so adding to arraylist is easy
		while( fileScan.hasNextLine() ) {
			wordList.add( fileScan.nextLine().toLowerCase() );		
		}
		fileScan.close();
	}

	public static int difficultWords( int diffWords, ArrayList<String> fileContents, ArrayList<String> wordList ) {
		// sorts the bible and dale-chall to prep for binary search
		Collections.sort( fileContents );
		Collections.sort( wordList );

		// if the word is not in the dale-chall list, it is a difficult word
		for( int i = 0; i < fileContents.size(); i++ ) {
			if( Collections.binarySearch( wordList, fileContents.get( i ) ) < 0 ) {
				diffWords++;
			}
		}
		return diffWords;		
	}

	public static double flesch( int numSyllables, int numWords, int numSentences, double fleschIndex ) {
		double sylls = numSyllables;
		double words = numWords;
		double sentences = numSentences;
	
		double alpha = sylls / words;
		double beta = words / sentences;
		double fleschRaw = 206.832 - ( alpha * 84.6 ) - ( beta * 1.015 );
		fleschIndex = Math.ceil( fleschRaw * 10 ) /10;
		
		return fleschIndex;
	}
		
	public static double fleschKincaid( int numSyllables, int numWords, int numSentences, double fleschKincaid ) {
		double sylls = numSyllables;
		double words = numWords;
		double sentences = numSentences;
		
		double alpha = sylls / words;
		double beta = words / sentences;
		double fleschKincaidRaw = ( alpha * 11.8 ) + ( beta * 0.39 ) - 15.59;
		fleschKincaid = Math.ceil( fleschKincaidRaw * 10 ) / 10;

		return fleschKincaid;
	}

	public static double daleChall( int diffWords, int numWords, int numSentences, double daleChall ) 
	{
		double diff = diffWords;
		double words = numWords;
		double sentences = numSentences;

		double alpha = diff / words;
		double beta = words / sentences;
		double daleChallRaw = ( 0.1579 * ( alpha * 100.0 ) ) + ( beta * 0.0496 );
		if( alpha * 100.0 > 5 ) {
			daleChallRaw += 3.6365;
		}
		daleChall = Math.ceil( daleChallRaw * 10 ) / 10;		

		return daleChall;
	}
}
