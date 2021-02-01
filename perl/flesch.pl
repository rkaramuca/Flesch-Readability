#!/usr/bin/perl
# ceiling function for totals
use POSIX qw/ceil/;
use strict;
use warnings;

my $fileName = $ARGV[ 0 ] or die "Need to get file name on the command line\n";
my @fileContents;
my @fileContentsRaw;
my $wordsFile = "/pub/pounds/CSC330/dalechall/wordlist1995.txt";
my @wordList;
my $numWords = 0.00;
my $numSentences = 0.00;
my $numSyllables = 0.00;
my $diffWords = 0.00;
my $fleschIndex;
my $fleschKincaid;
my $daleChall;

open( DATA, "<$fileName" ) or die "Couldn't open file $fileName,$!";
my @all_lines = <DATA>;

sub parseFile {
	# push each line into an array of raw file input
	foreach my $line( @all_lines ) {
		push( @fileContentsRaw, split( ' ', $line ) );
	}

	# for each word in the unformatted list...
	foreach my $currWord( @fileContentsRaw ) {
		my $word = "";
		# break each word into characters, then parse each character
		foreach my $char( split( '', $currWord ) ) {
			# use regex to see if it's a character or nested-digit, 
			# or if its an apsotrophe
			if( ( $char =~ /^[a-zA-Z]+$/) || 
			    ( $char =~ /^[0-9]+$/ && length$word > 0 ) ||
		      	  $char eq "'" ) {
				# if it fits criteria, add it to the temp $word variable
				$word = $word.$char;
			}
			# if it is an end-of-sentence character, increment sentence counter value
			if( $char eq '.' || $char eq '?' || $char eq '!' ||
			  	$char eq ':' || $char eq ';' ) {
				$numSentences++;
			}
		}
		# after the characters are parsed, 
		# push it (lowercased) to the array @fileContents if
		# it's not an empty string an increment the word counter value
		if( length$word > 0 ) {
			$numWords++;
			push( @fileContents, lc( $word ) );
		}
	}
	close( DATA );
}

sub syllableCount {
	# check all words int fileContents for vowels
	foreach my $currWord( @fileContents ) {
		my $length = length$currWord;
		my $currSylls = 0.00;
		# perl's "for i in range()" in python
		for my $i ( 0..$length ) {
			# current char is the substring of currWord[ i ] 
			my $char = substr( $currWord, $i, 1 );
			if( $char eq 'a' || $char eq 'e' || $char eq 'i' ||
				$char eq 'o' || $char eq 'u' || $char eq 'y' ) {
				$currSylls++;
				# makes sure it doesn't call oob
				if( $i < $length - 1 ) {
					# nextChar is currWord[ i + 1 ]
					my $nextChar = substr( $currWord, $i + 1, 1 );
					if( $nextChar eq 'a' || $nextChar eq 'e' || $nextChar eq 'i' ||
					    $nextChar eq 'o' || $nextChar eq 'u' || $nextChar eq 'y' ) {
						$currSylls--;
					}		
				}
			}
		}
		# if it ends with an 'e', it doesn't count as a syllable
		if( substr( $currWord, -1 ) eq 'e' ) {
			$currSylls--;
		}
		# every word needs a syllable
		if( $currSylls < 1 ) {
			$currSylls = 1.0;
		}
		$numSyllables += $currSylls;
	}
}

sub buildWordList {
	open( DATA, "<$wordsFile" ) or die "Couldn't open file $wordsFile,$!";
	my @all_lines = <DATA>;
	
	# goes line by line in the dale-chall file to create a word list array
	foreach	my $words( @all_lines ) {
		push( @wordList, split( '\n', lc( $words ) ) );
	}
	close( DATA );
}

sub difficultWords {
	@fileContents = sort @fileContents;
	@wordList = sort @wordList;
	
	# convert array to map for faster parsing 
	my %found = map { $_ => 1 } @wordList;
	# check if the words are in the list, if not, it's a difficult word
	foreach my $word( @fileContents ) {
		if( not exists( $found{ $word } ) ) {
			$diffWords++;
		}
	}
}

sub flesch {
	my $sylls = $numSyllables;
	my $words = $numWords;
	my $sentences = $numSentences;
	
	my $alpha = $sylls / $words;
	my $beta = $words / $sentences;
	my $fleschRaw = 206.832 - ( $alpha * 84.6 ) - ( $beta * 1.015 );
	# sprintf allows formatting, in this case, 1 decimal place
	$fleschIndex = sprintf( "%.1f", ceil( $fleschRaw * 10 ) / 10 ); 
}

sub fleschKincaid {
	my $sylls = $numSyllables;
	my $words = $numWords;
	my $sentences = $numSentences;
	
	my $alpha = $sylls / $words;
	my $beta = $words / $sentences;
	my $fleschKincaidRaw = ( $alpha * 11.8 ) + ( $beta * 0.39 ) - 15.59;
	$fleschKincaid = sprintf( "%.1f", ceil( $fleschKincaidRaw * 10 ) / 10 );
}

sub daleChall {
	my $diff = $diffWords;
	my $words = $numWords;
	my $sentences = $numSentences;
	
	my $alpha = $diff / $words;
	my $beta = $words / $sentences;
	my $daleChallRaw = ( 0.1579 * ( $alpha * 100.0 ) ) + ( $beta * 0.0496 );
	if( $alpha * 100.0 > 5 ) {
		$daleChallRaw += 3.6365;
	}
	$daleChall = sprintf( "%.1f", ceil( $daleChallRaw * 10 ) / 10 );
}

parseFile();
syllableCount();
buildWordList();
difficultWords();
flesch();
fleschKincaid();
daleChall();

print("Flesch Score:\t\t$fleschIndex\n");
print("Flesch-Kincaid Score:\t$fleschKincaid\n");
print("Dale-Chall Score:\t$daleChall\n");
