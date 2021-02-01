program reader

! data type :: variable name
character (LEN=5000000) :: long_string
character (LEN=1) :: input
integer :: counter

! & lets us continue a statement on another line
open (unit=5,status="old",access="direct",form="unformatted",recl=1,&
      file="/pub/pounds/CSC330/translations/KJV.txt")

counter=1
100 read (5,rec=counter,err=200) input
    ! counter:counter --> from index counter to index counter...
    long_string(counter:counter) = input
    counter=counter+1
    goto 100
200 continue
counter=counter-1

close (5)

print *, long_string
print *, "Read ", counter, " characters."

end program reader
