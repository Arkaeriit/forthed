\ #IR txt-list.frt
\ #IN number-list.frt
( ------------------------ ED editor ------------------------ )

( ED modes )
0 constant ed-mode-prompt
1 constant ed-mode-input

( ED state )
0 value ed-lst
0 value ed-current-line
0 value ed-mode

( Initializes the editor. )
: ed-init ( -- ) list-init to ed-lst
    0 to ed-current-line 
    ed-mode-prompt to ed-mode ;

( Print the famous error message. )
: ed-error ( -- ) ." ?" cr ;

( Reads the range part of a command. Return the range as a )
( number list and the rest of the prompt line. )
: ed-read-range ( c-addr1 u1 -- lst c-addr2 u2 )
    ( TODO: for now, only read single numbers )
    >r >r 0 s>d r> r> >number >r >r d>s
    list-init 2dup nlist-append nip r> r> ;

( Check that the given range is valid for an input command. )
( This means that it contains a single number number between )
( 0 and the size of the text. )
( TODO: change API so that a default range can be created. )
: ed-check-range-input ( range -- f ) dup list-size 1 = if
        nlist-get-first dup 0< if false else
            ed-lst list-size <= if true else false then then
    else false then ;

( Process a line input in the input mode. )
: ed-process-input ( c-addr u -- ) 2dup s" ." compare 0= if
        2drop ed-mode-prompt to ed-mode else
    ed-current-line ed-lst slist-add
    ed-current-line 1+ to ed-current-line then ;

( Execute the a command. )
: ed-command-a ( range -- ) dup ed-check-range-input
    0= if ed-error exit then
    ed-mode-input to ed-mode
    nlist-get-first to ed-current-line ;

( Process a line input in the prompt mode.)
: ed-process-prompt ( c-addr u -- ) ed-read-range
    2dup s" a" compare 0= if 2drop ed-command-a exit then
    2drop ed-error ;

( Process a line input. )
: ed-process ( c-addr u -- ) ed-mode case
    ed-mode-prompt of ed-process-prompt endof
    ed-mode-input  of ed-process-input  endof
    ed-error endcase ;


( -------------------------- Test --------------------------- )

ed-init
s" 0a" ed-process
s" first line" ed-process
s" second line" ed-process
s" ." ed-process
s" 1a" ed-process
s" between" ed-process
s" ." ed-process
ed-lst slist-print
ed-lst list-free
bye
