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
2 cells buffer: ed-default-filename

( Initializes the editor. )
: ed-init ( -- ) list-init to ed-lst
    0 to ed-current-line 
    ed-mode-command to ed-mode
    0 to ed-quit
    false to ed-file-modified
    ed-default-filename dup 0 swap ! cell+ 0 xallocate swap ! ;

( Free the memory allocated by ed. )
: ed-deinit ( -- ) ed-lst list-free ed-default-filename cell+
    @ xfree ;

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

( If the given range is empty, make a range with the whole )
( file in it.)
: ed-range-default-whole ( range -- range )
    dup list-size 0= if s" 1;$?" ed-read-range 2drop then ;

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

( Return true if the range is for the whole file. )
: ed-range-is-whole-file ( range -- range f ) dup list-size
    ed-lst list-size = ;

( Prepare a range for an action on lines. Return true if the )
( range is valid. )
: ed-range-action ( range -- range f ) ed-range-default-cl
    dup dup ed-range-1-to-size
    swap ed-check-range-ordered and ;

( Prepare a range for action on the whole file. Return true )
( if the range is valid. )
: ed-range-whole-file ( range -- range f )
    ed-range-default-whole dup ed-range-1-to-size ;

( ------------------- Reading and writing ------------------- )

( Forthed can read and write Forth blocks, files, or both. )
( The specific read and write implementation are handled in )
( separate files for either of the 3 cases. )

( Set the file as modified. )
: ed-touch-file ( -- ) true to ed-file-modified ;

( Set the default filename. Copy the string. )
: ed-set-default-filename ( c-addr u -- ) ed-default-filename
    cell+ dup @ xfree over xallocate swap !
    dup ed-default-filename !
    ed-default-filename cell+ @ swap move ;

( Get the default filename as a string. )
: ed-get-default-filename ( c-addr u -- ) ed-default-filename
    dup cell+ @ swap @ ;

( If the given string is not empty return it with leading )
( spaces skiped. If it is empty, return the defaut filename. )
: ed-defaut-filename-if-needed ( c-addr1 u1 -- c-addr2 u2 )
    skip-spaces dup 0=
        if 2drop ed-get-default-filename then ;

( Write a range of lines to the given _filename_. )
defer ed-write-to-file ( c-addr u range -- )

( Append a range of lines to the given _filename_. )
defer ed-append-to-file ( c-addr u range -- )

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

( Execute the w command. )
: ed-command-w ( range c-addr u -- )
    ed-defaut-filename-if-needed
    over ed-range-whole-file ed-error-command
    ed-range-is-whole-file if false to ed-file-modified then
    dup >r ed-write-to-file r> list-free ;

( Process a line input in the command mode.)
: ed-process-command ( c-addr u -- ) ed-read-range
    2dup s" a" compare 0= if 2drop ed-command-a exit then
    2dup s" Q" compare 0= if 2drop ed-command-Q exit then
    2dup s" p" compare 0= if 2drop ed-command-p exit then
    2dup s" d" compare 0= if 2drop ed-command-d exit then
    2dup s" w" compare 0= if       ed-command-w exit then
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
s" file.txt" ed-set-default-filename depth . cr
ed-get-default-filename type depth . cr
s"    otherfile.docx" ed-defaut-filename-if-needed type cr
s"    " ed-defaut-filename-if-needed type cr
depth . cr

ed 0a
ed first line
ed second line
ed .
ed 1a
ed between
ed .
ed-lst slist-print
ed-repl
ed-deinit
bye
