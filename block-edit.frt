\ #IR ed.frt
( ---------------------- Block edition ---------------------- )

( Blocks numers are given in the format )
( <start block>,<end block> or <block>. )

0 value blocks-start
0 value blocks-end

( Keeps the string on the stack and return a string telling )
( if it's fully a number.)
: is-str-a-number? ( c-addr1 u1 -- c-addr1 u1 f ) 2dup
    ?dup 0= if drop false exit then
    >number-s 0= nip nip ;

( From a string, return it a copy of it having skipped until )
( just after the char c is found. Return a flag telling if )
( the char was found. )
0 value c-to-skip-at
: skip-until-c ( c-addr1 u1 c -- c-addr1 u1 c-addr2 u2 f )
    to c-to-skip-at 2dup
    ( c1 u1 c1 u1 | c )
    0 ?do dup i + c@ c-to-skip-at = if
        i + ( add1 u1 add2 ) over i - true unloop exit
        then loop
    drop 0 0 false ;

( Try to skip a char in the string. If there was a char, )
( return true. If there wasn't, return false. )
: try-skip ( c-addr1 u1 -- c-addr2 u2 f ) dup 0= if
    false else 1- swap 1+ swap true then ;

( If the input string is a single number, set that number to )
( both block values and return true. Otherwise, return false )
( and the string as-is. )
: try-parse-one-block ( c-addr1 u1 -- true | c-addr1 u1 false )
    is-str-a-number? if >number-s 2drop dup to blocks-start
        to blocks-end true else false then ;

( If the input is in the format <number>,<number>, sets the )
( number in the block values and return true. )
: try-parse-two-blocks ( c-addr u -- f ) 2dup start-with-num
    0= if 2drop false exit then
    >number-s try-skip 0= if drop 2drop false exit then
    try-parse-one-block if to blocks-start true
        else 2drop drop false ;

( Parse the input as blocks. Return true if it worked. )
: try-parse-blocks ( c-addr u -- f ) try-parse-one-block
    if exit then
    try-parse-two-blocks ;

