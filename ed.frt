\ #IR txt-list.frt
\ #IN number-list.frt
( ------------------------ ED editor ------------------------ )
( ----------------------------  ----------------------------- )

( --------------------- Internal state ---------------------- )

( ED modes )
0 constant ed-mode-command
1 constant ed-mode-input

( ED state )
0 value ed-lst
0 value ed-current-line
0 value ed-mode
0 value ed-quit

( Initializes the editor. )
: ed-init ( -- ) list-init to ed-lst
    0 to ed-current-line 
    ed-mode-command to ed-mode
    0 to ed-quit ;

( Print the famous error message. )
: ed-error ( -- ) ." ?" cr ;

( Print the error and exit the caller if the flag is false. )
: ed-error-command ( f -- ) postpone 0= postpone if
    postpone ed-error postpone exit postpone then ; immediate

( ---------------------- Command range ---------------------- )

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

( Check that the range is empty. )
: ed-check-range-empty ( range -- f ) list-size 0= ;

( ----------------------- Input mode ------------------------ )

( Process a line input in the input mode. )
: ed-process-input ( c-addr u -- ) 2dup s" ." compare 0= if
        2drop ed-mode-command to ed-mode else
    ed-current-line ed-lst slist-add
    ed-current-line 1+ to ed-current-line then ;

( ----------------------- Normal mode ----------------------- )

( Execute the a command. )
: ed-command-a ( range -- ) dup ed-check-range-input
    ed-error-command
    ed-mode-input to ed-mode
    dup nlist-get-first to ed-current-line 
    list-free ;

( Execute the Q command. )
: ed-command-Q ( range -- )
    ( ed-check-range-empty ed-error-command ) list-free
    1 to ed-quit ;

( Execute the p command. ) ( TODO: range )
: ed-command-p ( range -- ) list-free 
    ed-lst slist-print ; 

( Process a line input in the command mode.)
: ed-process-command ( c-addr u -- ) ed-read-range
    2dup s" a" compare 0= if 2drop ed-command-a exit then
    2dup s" Q" compare 0= if 2drop ed-command-Q exit then
    2dup s" p" compare 0= if 2drop ed-command-p exit then
    2drop list-free ed-error ;

( Process a line input. )
: ed-process ( c-addr u -- ) ed-mode case
    ed-mode-command of ed-process-command endof
    ed-mode-input   of ed-process-input   endof
    ed-error endcase ;

( --------------------------- UI ---------------------------- )

( Parse the rest of the line as an ed command. Used to run )
( ed from an interactive Forth. )
: ed ( "parse the rest of the line" -- ) 10 parse ed-process ;

( ED repl. )
1024 constant ed-line-size
ed-line-size buffer: ed-line
: ed-repl ( -- ) ( TODO : prompt ) begin
        ed-line ed-line-size accept ed-line swap ed-process
    ed-quit until ;

( -------------------------- Test --------------------------- )

ed-init
ed 0a
ed first line
ed second line
ed .
ed 1a
ed between
ed .
ed-lst slist-print
ed-repl
ed-lst list-free
bye
