( ---------------------- Range parser ----------------------- )

( The range parser parse the start of an ed command and try )
( to find what the range of the command is. )
( The range could either a range shorthand such as ',' or ';' )
( or a more complex range that needs to be computed. )

( Return true if the given string start with a number. )
: ed-range-is-num ( c-addr u -- f ) 2dup 2>r 0 0 2r>
    >number nip nip nip <> nip ;

0 value ed-cmd-len
0 value ed-cmd
0 value range-error

( Same as ed-range-is-num but reads the cached cmd. )
: num-in-cmd ( --  f ) ed-cmd ed-cmd-len ed-range-is-num ;

( Read a number from ed-cmd returns it and advance the cmd. )
: read-num ( -- n ) 0 0 ed-cmd ed-cmd-len >number
    to ed-cmd-len to ed-cmd d>s ;

( The range )
variable first-element
variable last-element

( Eat a char out of the cmd value. )
: eat-char ( -- ) ed-cmd-len 1- to ed-cmd-len
    ed-cmd 1+ to ed-cmd ;

( Try to read an element of a range. Store it at the given )
( address. )
: parse-element ( addr -- ) ed-cmd c@ case
    '.' of ed-current-line swap ! eat-char endof
    '$' of ed-lst list-size swap ! eat-char endof
    '+' of eat-char num-in-cmd if read-num else 1 then
            ed-current-line + swap ! endof
    '-' of eat-char num-in-cmd if read-num else 1 then
            ed-current-line swap - swap ! endof
    ( TODO: regex )
    ( TODO: marks )
    num-in-cmd if read-num rot !
               else true to range-error drop then
    endcase ;
        
( TODO: range modifiers like +++ or -x )

( Try to read the first element of a range. )
: parse-first-element ( -- ) first-element parse-element ;

( See if a range is given with ; or , and act acordingly. )
: try-parse-last-element ( -- ) range-error if exit then
    ed-cmd c@ case
    ',' of eat-char last-element parse-element endof
    ';' of eat-char first-element @ to ed-current-line
            last-element parse-element endof
    ( If none of the cases are a match, there is no other )
    ( value so we assume it's a single line range. )
    first-element @ last-element ! endcase ;

( Try to parse a shorthand, do a full parse otherwise. )
: parse-range ( -- ) ed-cmd c@ case
    ',' of ed-current-line first-element ! ed-lst list-size
            last-element ! eat-char endof
    ';' of 1 first-element ! ed-lst list-size last-element !
            eat-char first-element @ to ed-current-line endof
    ( TODO: global regexes )
    parse-first-element try-parse-last-element
    endcase ;

( Set a range error if the last element is lower than the )
( first. )
: sanitize-range ( -- ) last-element @ first-element @ <
    if true to range-error then ;

( Generate a list of lines from the first and last element. )
( Return 0 if the list can't be made. )
: gen-range ( -- lst ) list-init
    last-element @ 1+ first-element @ 
        do dup i swap nlist-append loop ;

( Reads the range part of a command. Return the range as a )
( number list and the rest of the prompt line. )
( In case of range error, return an empty list and the )
( command unchanged. )
: ed-read-range ( c-addr1 u1 -- lst c-addr2 u2 )
    dup 0= if 2drop list-init 0 0 exit then ( empty line )
    2dup to ed-cmd-len to ed-cmd false to range-error
    parse-range sanitize-range
    range-error if list-init rot rot
                else 2drop gen-range ed-cmd ed-cmd-len then ;

\ #SI
( -------------------------- Test --------------------------- )

s" abcd" ed-read-range type space nlist-print cr
s" 28cmd" ed-read-range type space nlist-print cr
s" 2;8cmd" ed-read-range type space nlist-print cr
s" -1,.CMD" ed-read-range type space nlist-print cr
s" +1,5CMD" ed-read-range type space nlist-print cr
s" 77,50:(" ed-read-range type space nlist-print cr
bye

