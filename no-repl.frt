( ----------- UI for Forth systems without accept ----------- )

:noname ( -- ) ." ed-repl isn't available on this system."
    cr ; is ed-repl

( Parse the rest of the line as an ed command. Used to run )
( ed from an interactive Forth. )
: ed ( -- ) ed-parse-cmd ;

