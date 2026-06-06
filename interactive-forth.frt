( ------------ UI for interactive forth systems ------------- )

( Initialize ed and runs it. When done, de-initialize it and )
( check the stack's integrity. )
: ed ( -- ) depth >r ed-init ed-repl ed-deinit depth r> <>
    if ." Warning: ed changed stack depth." cr then ;

