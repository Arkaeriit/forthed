( ---------------------- Block edition ---------------------- )
( ----------------------------  ----------------------------- )

( ------------------- Parsing block range ------------------- )

( Blocks numers are given in the format )
( <start block>,<end block> or <block>. )

0 value blocks-start
-1 value blocks-end

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
        else 2drop drop false then ;

( Return true if the start block is lower than the end )
( block. As the numbers are parsed as unsigned, no need to )
( check for positivity. )
: validate-blocks ( -- f ) blocks-end blocks-start > ;

( Parse the input as blocks. Return true if it worked. )
: try-parse-blocks ( c-addr u -- f ) try-parse-one-block
    if true exit then
    try-parse-two-blocks validate-blocks and ;

( --------------------- Writing blocks ---------------------- )

( The blocks are written assuming that they are made of )
( lines with a default of 16 lines if 64 chars. )

1024 value ed-block-size
64 value ed-block-line-size
: ed-lines-in-block ( -- u )
    ed-block-size ed-block-line-size / ;

( Get the number of blocks that can be written to. )
: available-blocks ( -- u ) blocks-end blocks-start - 1+ ;

( Get the number of lines that can be written to the blocks. )
: available-lines ( -- u )
    available-blocks ed-lines-in-block * ;

( Return true if there is enough space in the blocks to )
( write the file. )
: enough-space-in-blocks? ( range1 -- range1 f ) dup list-size
    available-lines <= ;

( Prepare the file to be written to block. To do so, pad )
( each lines with spaces. )
: prepare-file ( -- ) bl ed-block-line-size ed-lst slist-pad ;

0 value current-block-buffer
0 value current-block-number
0 value current-line

( Increase the current line. If it's bigger that the lines )
( in a block, update the block buffer. )
: increase-line ( -- ) current-line ed-lines-in-block 1- =
    if update save-buffers 0 to current-line
        current-block-number 1+ dup to current-block-number
        buffer to current-block-buffer
    else current-line 1+ to current-line then ;

( Add a line of text to the current-block-buffer. )
: add-line-to-block ( c-addr u -- ) ed-block-line-size <>
    abort" Line is not of the block line size."
    current-line ed-block-line-size * current-block-buffer +
    ed-block-line-size move increase-line ;

( Write lines of spaces until all allocated blocks are )
( filled. enough-space-in-blocks? already ensured that there )
( were some free space. )
: fill-with-space ( -- ) ed-block-line-size xallocate
    dup ed-block-line-size bl fill ed-block-line-size
    begin current-block-number blocks-end <= while
        2dup add-line-to-block repeat
    drop xfree ;

( ed-write-to-file )
:noname ( c-addr u range -- f ) >r try-parse-blocks 0= if
    r> drop false exit then
    r> enough-space-in-blocks? 0= if drop false exit then
    blocks-start to current-block-number 0 to current-line
    current-block-number buffer to current-block-buffer
    prepare-file ['] add-line-to-block ed-exec-on-range
    fill-with-space true ; is ed-write-to-file

( ed-append-to-file )
:noname ( c-addr u range -- f ) drop 2drop false
    ." Can't append to blocks." cr ;
    is ed-append-to-file

\ #SI
( -------------------------- Test --------------------------- )

ed-init
ed 0a
ed abcd
ed 1234
ed .
ed w 99,101
ed Q
ed-deinit
99 list
bye

