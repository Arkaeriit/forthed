( ---------------------- CLI interface ---------------------- )

( Check that the stack is empty. )
: depth-check ( -- ) depth
    abort" Stack should be empty when leaving ed." ;

( Print the help message. )
: print-help ( -- )
    ." Forthed is a simple text editor inpired by ed." cr cr
    ." Invoking forthed without arguments run it with no"
    ."  file opened yet." cr
    ." Invoking it with '-h' or '--help' as argument prints"
    ."  this message." cr
    ." Runing it with any other argument will treat the"
    ."  argument as a file to open." cr ;

( If the first argument asks for help, prints it and return )
( true Otherwise, false true an the argument. )
: check-for-help ( -- true | c-addr u false )
    next-arg dup 0= if false exit then
    2dup s" -h" compare 0= >r
    2dup s" --help" compare 0= r> or
    if 2drop print-help true else false then ;

( If the file at the given path exist, run the E command. )
: E-if-exists ( c-addr u -- ) r/o open-file if drop
    else close-file drop list-init ed-command-E then ;

: main ( -- )
    check-for-help if exit then
    ed-init
    dup 0<> if 2dup ed-set-default-filename E-if-exists then
    ed-repl ed-deinit ;

main
depth-check
bye

