program flesch

! Create a giant string of the bible contents and dale-chall word list
character(LEN=6000000) :: fileContents
character(LEN=1000000) :: dclist 

! parse each file 
call parseDC( dclist )
call parseFile( fileContents, dclist )

end program flesch



! Parser for the Bible
subroutine parseFile( string, wordlist )

! Declaration of used variables
character(len=*) :: wordlist
character(LEN=*) :: string
integer :: counter
character (LEN=1) :: input

integer :: numWords, numSentences, numSyllables, diffWords
character(LEN=1) :: curr, last
character(LEN=:), allocatable :: word
integer :: currSylls
character(LEN=26) :: low
character(LEN=26) :: upp

double precision :: fleschScore, fleschKincaidScore, daleChallScore
real*4 :: a, b

! gets command line arguments to call file 
character(len=100) :: cla
call get_command_argument(1, cla)
open (unit=5,status="old",access="direct",form="unformatted",recl=1,&
      file=cla)

numWords = 0
numSentences = 0
numSyllables = 0
currSylls = 0
diffWords = 0

counter=1
last = '|'
word = ""

low = "abcdefghijklmnopqrstuvwxyz"
upp = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

! for each character in the file...
100 read (5,rec=counter,err=200) input
    curr = input
    ! if it is a letter or a nested-number...
    if( ( isalpha( curr ) > 0 .or. &
          isalpha( last ) > 0 .or. &
          curr == "'" .or. &
          LEN( word ) > 0 ) .and. &
          curr /= ' ' .and. &
        ( isalpha( curr ) > 0 .or. &
          isdigit( curr ) > 0 .or. &
          curr == "'" ) ) then
        if( index( upp, curr ) > 0 ) then
            ! convert to lowercase
            curr = low( index( upp, curr ):index( upp, curr ) )
        endif
        ! then add the letter to the big string
        string( counter:counter ) = curr
        word = word // curr
    endif

    ! if the current is a vowel
    if( isvowel( curr ) > 0 ) then
        currSylls = currSylls + 1
        ! add one, but check if the last was a vowel
        if( isvowel( last ) > 0 ) then  
            ! if so, sub 1
            currSylls = currSylls - 1
        endif
    endif

    ! if the current character is an end-of-sentence marker
    if( eos( curr ) > 0 ) then
        ! increment the sentence count
        numSentences = numSentences + 1
        ! check if the char before that was an e, if so, decrement syllables 
        if( index( "e", last ) > 0 ) then
            currSylls = currSylls - 1
        endif
    endif

    ! if the character is a space, blank, or newline character
    word = trim( word )
    if( ( ( curr == ' ' ) .or. ( curr == '' ) .or. ( curr == char(10) ) ) &
            .and. LEN( word ) /= 0 ) then
        ! add a space to the giant string
        string( counter:counter ) = " "      

        ! if e was the last character, -1 on syllables
        if( index( "e", last ) > 0 ) then
            currSylls = currSylls - 1
        endif
        ! every word needs at least 1 syllable
        if( currSylls < 1 ) then
            currSylls = 1
        endif
        numSyllables = numSyllables + currSylls
        currSylls = 0

        ! if the word isn't in the dale-chall list, increment difficult words
        if( index( wordlist, word ) == 0 ) then
            diffWords = diffWords + 1
        endif

        ! reset word variable and increment word counter
        word = ""
        numWords = numWords + 1
    endif

    counter=counter+1
    last = curr
    goto 100
200 continue
counter = counter -1
close(5)

fleschScore = 0
fleschKincaid = 0.0
daleChall = 0.0

! calculates the alpha and beta values for flesch, flesch-kincaid and dale-chall
a = real( numSyllables ) / real( numWords )
b = real( numWords ) / real( numSentences )

fleschScore = fleschScoreCalc( a, b )
print "(a8,f4.1)", "Flesch: ", fleschScore

fleschKincaid = fleschKincaidCalc( a, b )
print "(a16,f4.1)", "Flesch-Kincaid: ", fleschKincaid

! updates alpha to have correct dale-chall value
a = real( diffWords ) / real( numWords )
daleChall = daleChallCalc( a, b )
print "(a12,f4.1)", "Dale-Chall: ", daleChall
end subroutine parseFile



function isalpha( letter )
character( LEN=1 ) :: letter
character( LEN=52 ) :: alphabet
alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
! checks if the current character is in the alphabet
isalpha = ( index( alphabet, letter) ) 
return
end function isalpha



function isdigit( letter )
character( LEN=1 ) :: letter
character( LEN=10 ) :: numbers
numbers = "0123456789"
! checks if the current character is a digit
isdigit = ( index( numbers, letter ) )
return 
end function isdigit



function isvowel( letter )
character( LEN=1 ) :: letter
character( LEN=6 ) :: vowels
vowels = "aeiouy"
! checks if the current character is a vowel 
isvowel = ( index( vowels, letter ) )
return
end function isvowel



function eos( letter )
character( LEN=1 ) :: letter
character( LEN=5 ) :: eosChars
eosChars = ".:;?!"
! checks if the current character is an end of sentence character
eos = ( index( eosChars, letter ) )
return 
end function eos



! Same as parseFile, except no flesch calculations, numWords, numSentences, etc.
subroutine parseDC( string )

character(LEN=*) :: string
integer :: counter
character (LEN=1) :: input

character(LEN=1) :: curr, last
character(LEN=:), allocatable :: word

character(LEN=26) :: low
character(LEN=26) :: upp


open (unit=5,status="old",access="direct",form="unformatted",recl=1,&
        file="/pub/pounds/CSC330/dalechall/wordlist1995.txt")

counter=1
last = '|'
word = ""

low = "abcdefghijklmnopqrstuvwxyz"
upp = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

100 read (5,rec=counter,err=200) input
    curr = input
    ! checks if the current charcter is a letter
    if( ( isalpha( curr ) > 0 .or. &
            isalpha( last ) > 0 .or. &
            curr == "'" .or. &
            LEN( word ) > 0 ) .and. &
            curr /= ' ' .and. &
        ( isalpha( curr ) > 0 .or. &
            isdigit( curr ) > 0 .or. &
            curr == "'" ) ) then
        if( index( upp, curr ) > 0 ) then
            ! convert uppercase to lowercase
            curr = low( index( upp, curr ):index( upp, curr ) )
        endif
        ! if it is a letter or apostrophe, push the letter to the dale-chall
        ! list array
        string( counter:counter ) = curr
        word = word // curr
    endif

    word = trim( word )
    if( ( ( curr == ' ' ) .or. ( curr == '' ) .or. ( curr == char(10) ) ) &
            .and. LEN( word ) /= 0 ) then
        ! if the character is the end of a word/sentence, add a space to the
        ! array of words, then clear temp word
        string( counter:counter ) = " "      
        word = ""
    endif

    counter=counter+1
    last = curr
    goto 100
200 continue
counter = counter -1
close(5)

end subroutine parseDC



! calculate the flesch score based on alpha and beta values
function fleschScoreCalc( alpha, beta ) 
real*4 :: alpha, beta
fleschScoreCalc = 206.835 - ( alpha * 84.6 ) - ( beta * 1.015 )
return
end function fleschScoreCalc



! calculate flesch kincaid score based on alpha and beta values
function fleschKincaidCalc( alpha, beta )
real*4 :: alpha, beta
fleschKincaidCalc = ( alpha * 11.8 ) + ( beta * 0.39 ) - 15.59 
return
end function fleschKincaidCalc



! calculate dale chall score based on alpha and beta values
function daleChallCalc( alpha, beta )
real*4 :: alpha, beta
daleChallCalc = ( 0.1579 * ( alpha * 100.0 ) ) + ( beta * 0.0496  )
if( alpha * 100.0 > 5 ) then
    daleChallCalc = daleChallCalc + 3.6365
endif
return
end function daleChallCalc
