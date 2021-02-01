
! Main program START

program reader
! : = 1 dimension, :, :, :, etc. is adding dimension
character, dimension(:), allocatable  :: long_string, outline, word
integer :: filesize

! Similar to C++ prototypes
interface
subroutine read_file( string, filesize )
character, dimension(:), allocatable :: string
integer :: filesize
end subroutine read_file
end interface

interface
 subroutine get_next_token( inline, outline, word)
   character (*) :: inline
   character(:), allocatable :: outline, word
 end subroutine get_next_token 
end interface


call read_file( long_string, filesize )
outline = long_string
call get_next_token( long_string, outline, word )

print *, long_string
print *, "Read ", filesize, " characters."
end program reader

! Main program END

! Subroutine read_file START

subroutine read_file( string, filesize )
character, dimension(:), allocatable :: string
integer :: counter
integer :: filesize
character (LEN=1) :: input

! Returns filesize via inquire
inquire (file="KJV.txt", size=filesize)
open (unit=5,status="old",access="direct",form="unformatted",recl=1,&
      file="/pub/pounds/CSC330/translations/KJV.txt")
! allocate is like new in C++
allocate( string(filesize) )

counter=1
! While there is still input in the file, take string input
! if it fails, jump to line 200
100 read (5,rec=counter,err=200) input
    string(counter:counter) = input
    counter=counter+1
    ! if successful, go to line 100
    goto 100
200 continue
counter=counter-1
close (5)
end subroutine read_file

! Subroutine read_file END

! Subroutine get_next_token START

subroutine get_next_token( inline, outline, token)
character (*) :: inline
character(:), allocatable :: outline, token 
integer :: i, j
logical :: foundFirst, foundLast

! Initialize variables used to control loop
foundFirst = .false.
foundLast  = .false.
i = 0

! find first non blank character
do while ( .not. foundFirst .and. (i < len(inline)))  
    if (inline(i:i) .eq. " ") then
       i = i + 1
    else
       foundFirst = .true.
    endif
enddo


j = i
do while ( foundFirst .and. .not. foundLast .and. ( j < len(inline)))
    if (inline(j:j) .ne. " ") then
       j = j + 1
    else
       foundLast = .true.
    endif
enddo
 
token = trim(inline(i:j))
outline = trim(inline(j+1:len(inline)))

end subroutine get_next_token  

! Subroutine get_next_token END
