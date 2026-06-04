( ---------------------- CLI interface ---------------------- )

( Check that the stack is empty. )
: depth-check ( -- ) depth
    abort" Stack should be empty when leaving ed." ;

ed-init
ed-repl
ed-deinit

depth-check
bye

