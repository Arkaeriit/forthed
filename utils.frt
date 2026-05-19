( ------------------- Miscellaneous words ------------------- )

( Like allocate but abort in case of error. )
: xallocate ( u -- addr ) allocate
    abort" Can't allocate memory." ;

( Like free but abort in case of error. )
: xfree ( addr -- ) free abort" Can't free." ;

( Skip a char if any is available. )
: skip-char ( addr1 u1 -- addr2 u2 ) dup 0= if exit then
    1- swap 1+ swap ;

( Skip all leading spaces from the input string. )
: skip-spaces ( addr1 u1 -- addr2 u2 ) dup 0= if exit then
    over c@ bl = if skip-char recurse then ;

( Skip a char and all spaces after it. )
: skip-char-and-spaces ( addr1 u1 -- add2 u2 )
    skip-char skip-spaces ;

