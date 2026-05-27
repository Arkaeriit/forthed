\ #IR txt-list.frt
\ #IN number-list.frt
\ #IR str-buff.frt
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
str-buff: ed-default-filename
0 value ed-cmd-suffix
str-buff: ed-cmd-argument

( Initializes the editor. )
: ed-init ( -- ) list-init to ed-lst
    0 to ed-current-line 
    ed-mode-command to ed-mode
    0 to ed-quit
    false to ed-file-modified
    ed-default-filename str-buff-init
    ed-cmd-argument str-buff-init ;

( Free the memory allocated by ed. )
: ed-deinit ( -- ) ed-lst list-free
    ed-default-filename str-buff-free
    ed-cmd-argument str-buff-free ;

( Print the famous error message. )
: ed-error ( -- ) ." ?" cr ;

( Print the error and exit the caller if the flag is false. )
( Free range if it exits. )
: ed-error-command ( range f -- range | ) postpone 0=
    postpone if postpone ed-error postpone list-free
        postpone exit postpone then ; immediate

( Get the command argument as a string. )
: ed-cmd-argument-get ( -- c-addr u ) ed-cmd-argument
    str-buff-get ;

( Set the command argument as a string. )
: ed-cmd-argument-set ( c-addr u -- ) ed-cmd-argument
    str-buff-set ;

\ #IR range-parser.frt

( ---------------------- Command range ---------------------- )

( If the given range is empty, add the current line in it. )
: ed-range-default-cl ( range -- range ) dup list-size 0= if
    dup ed-current-line swap nlist-append then ;

( If the given range is empty, make a range with the whole )
( file in it.)
: ed-range-default-whole ( range -- range )
    dup list-size 0=
    if list-free s" 1;$?" ed-read-range 2drop then ;

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
: ed-check-range-empty ( range -- range f ) dup list-size 0= ;

( Check that the range is empty. Error and exit if it isn't. )
( Free the range in any case. )
: ed-no-range-command ( range -- )
    postpone ed-check-range-empty postpone ed-error-command
    postpone list-free ; immediate

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
: ed-set-default-filename ( c-addr u -- )
    ed-default-filename str-buff-set ;

( Get the default filename as a string. )
: ed-get-default-filename ( c-addr u -- )
    ed-default-filename str-buff-get ;

( If the given string is not empty return it with leading )
( spaces skiped. If it is empty, return the defaut filename. )
: ed-defaut-filename-if-needed ( c-addr1 u1 -- c-addr2 u2 )
    skip-spaces dup 0=
        if 2drop ed-get-default-filename then ;

( Write a range of lines to the given _filename_. Return )
( true if this worked. )
defer ed-write-to-file ( c-addr u range -- f )

( Append a range of lines to the given _filename_. Return )
( true if this worked. )
defer ed-append-to-file ( c-addr u range -- f )

( ----------------------- Input mode ------------------------ )

( Process a line input in the input mode. )
: ed-process-input ( c-addr u -- ) 2dup s" ." compare 0= if
        2drop ed-mode-command to ed-mode else
    ed-touch-file ed-current-line ed-lst slist-add
    ed-current-line 1+ to ed-current-line then ;

( ----------------------- Normal mode ----------------------- )

( Parse the given command. Return the first caracter. Store )
( the second character in the prefix value and store the )
( rest in the command argument. )
: ed-read-cmd ( c-addr u -- c ) over c@ >r skip-char
    ?dup 0= if drop 0 to ed-cmd-suffix s" "
                ed-cmd-argument-set r> exit then
    over c@ to ed-cmd-suffix ( I use the fact that no cmd )
                             ( use both argument and sufix. )
    skip-spaces ed-cmd-argument-set r> ;

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
    ed-no-range-command
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

( Execute the w or w command. )
0 value ed-wW-xt
: ed-command-w-or-W ( range -- )
    ed-cmd-argument-get
    ed-defaut-filename-if-needed
    rot ed-range-whole-file ed-error-command
    ed-range-is-whole-file if false to ed-file-modified then
    >r r@ ed-wW-xt execute r> list-free
    0= if ed-error then ;

( Execute the w command. )
: ed-command-w ( range -- )
    ['] ed-write-to-file to ed-wW-xt ed-command-w-or-W ;

( Execute the w command. )
: ed-command-Wa ( range -- )
    ['] ed-append-to-file to ed-wW-xt ed-command-w-or-W ;

( Execute the f command. )
: ed-command-f ( range -- ) ed-no-range-command
    ed-cmd-argument-get ?dup 0=
        if drop ed-get-default-filename type cr
        else ed-set-default-filename then ;

( Process a line input in the command mode.)
: ed-process-command ( c-addr u -- ) ed-read-range
    dup 0= if 2drop list-free ed-error exit then
    ed-read-cmd case
        'a' of ed-command-a  endof
        'Q' of ed-command-Q  endof
        'p' of ed-command-p  endof
        'd' of ed-command-d  endof
        'w' of ed-command-w  endof
        'f' of ed-command-f  endof
        'W' of ed-command-Wa endof
        >r list-free ed-error r>
    endcase ;

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

\ #SI
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

