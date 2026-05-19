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
0 value ed-file-modified

( Initializes the editor. )
: ed-init ( -- ) list-init to ed-lst
    0 to ed-current-line 
    ed-mode-command to ed-mode
    0 to ed-quit
    false to ed-file-modified ;

( Print the famous error message. )
: ed-error ( -- ) ." ?" cr ;

( Print the error and exit the caller if the flag is false. )
: ed-error-command ( f -- ) postpone 0= postpone if
    postpone ed-error postpone exit postpone then ; immediate

\ #IR range-parser.frt

( ---------------------- Command range ---------------------- )

( If the given range is empty, add the current line in it. )
: ed-range-default-cl ( range -- range ) dup list-size 0= if
    dup ed-current-line swap nlist-append then ;

( Return true if all the values in the range are between 0 )
( and the text list size. )
: ed-range-0-to-size ( range -- f ) 0 ed-lst list-size
    nlist-in-range ;

( Return true if all the values in the range are between 1 )
( and the text list size. )
: ed-range-1-to-size ( range -- f ) 1 ed-lst list-size
    nlist-in-range ;

( Return true if the range is of size 1. )
: ed-range-size-1 ( range -- f ) list-size 1 = ;

( Check that the range is empty. )
: ed-check-range-empty ( range -- f ) list-size 0= ;

( Check that the values in the range are ordered. It should )
( be the case because of how the range parser works, but )
( it can't hurt to check. )
0 value last-line
0 value ordered
: check-order-node ( addr -- ) @ dup last-line
    > ordered and to ordered
    to last-line ;
: ed-check-range-ordered ( range -- f )
    -1 to last-line true to ordered
    ['] check-order-node swap list-exec ordered ;

( Prepare a range for an input command. Return true if the )
( range is valid. )
: ed-range-input ( range -- range f ) ed-range-default-cl
    dup dup ed-range-0-to-size swap ed-range-size-1 and ;

( Prepare a range for an action on lines. Return true if the )
( range is valid. )
: ed-range-action ( range -- range f ) ed-range-default-cl
    dup dup ed-range-1-to-size
    swap ed-check-range-ordered and ;

( ------------------- Reading and writing ------------------- )

( Set the file as modified. )
: ed-touch-file ( -- ) true to ed-file-modified ;

( ----------------------- Input mode ------------------------ )

( Process a line input in the input mode. )
: ed-process-input ( c-addr u -- ) 2dup s" ." compare 0= if
        2drop ed-mode-command to ed-mode else
    ed-touch-file ed-current-line ed-lst slist-add
    ed-current-line 1+ to ed-current-line then ;

( ----------------------- Normal mode ----------------------- )

( Execute an action on all lines in the given range, and set )
( the current line for each ones. The xt must have prototype )
( [c-addr n -- ]. Convert between the 0-indexing of the list )
( and the 1-indexing of the lines. )
0 value exec-on-range-xt
: exec-on-node ( addr -- ) @ dup to ed-current-line
    1- ed-lst slist-get exec-on-range-xt execute ;
: ed-exec-on-range ( range 'xt -- ) to exec-on-range-xt
    ['] exec-on-node swap list-exec ;

( Execute the a command. )
: ed-command-a ( range -- ) ed-range-input
    ed-error-command
    ed-mode-input to ed-mode
    dup nlist-get-first to ed-current-line 
    list-free ;

( Execute the Q command. )
: ed-command-Q ( range -- )
    ( ed-check-range-empty ed-error-command ) list-free
    1 to ed-quit ;

( Execute the d command. )
: action-d ( addr -- ) @ 1- ed-lst list-delete ;
: ed-command-d ( range -- ) ed-range-action ed-error-command
    list-reverse dup ['] action-d swap list-exec list-free
    ed-touch-file ;

( Execute the p command. )
: action-p ( c-addr u -- ) type cr ;
: ed-command-p ( range -- ) ed-range-action ed-error-command
    dup ['] action-p ed-exec-on-range list-free ;

( Process a line input in the command mode.)
: ed-process-command ( c-addr u -- ) ed-read-range
    2dup s" a" compare 0= if 2drop ed-command-a exit then
    2dup s" Q" compare 0= if 2drop ed-command-Q exit then
    2dup s" p" compare 0= if 2drop ed-command-p exit then
    2dup s" d" compare 0= if 2drop ed-command-d exit then
    2dup s" "  compare 0= if 2drop list-free    exit then
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
