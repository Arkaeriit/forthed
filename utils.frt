( ------------------- Miscellaneous words ------------------- )

( Like allocate but abort in case of error. )
: xallocate ( u -- addr ) allocate
    abort" Can't allocate memory." ;

( Like free but abort in case of error. )
: xfree ( addr -- ) free abort" Can't free." ;

( Skip a char if any is available. )
: skip-char ( c-addr1 u1 -- c-addr2 u2 ) dup 0= if exit then
    1- swap 1+ swap ;

( Skip all leading spaces from the input string. )
: skip-spaces ( c-addr1 u1 -- c-addr2 u2 ) dup 0= if exit then
    over c@ bl = if skip-char recurse then ;

( Skip a char and all spaces after it. )
: skip-char-and-spaces ( c-addr1 u1 -- c-add2 u2 )
    skip-char skip-spaces ;

( Like >number but for single cell numbers. )
: >number-s ( c-addr1 u1 -- u c-addr2 u2 ) >r >r 0 s>d r> r>
    >number >r >r d>s r> r> ;

( Return true if the string starts with a number. )
: start-with-num ( c-addr u -- f ) dup >r >number-s r> <>
    nip nip ;

