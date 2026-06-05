\ #IR block-edit.frt
( ------------ Combined blocks and file support ------------- )

defer ed-write-to-file-block
defer ed-append-to-file-block
defer ed-read-file-block

action-of ed-write-to-file is ed-write-to-file-block
action-of ed-append-to-file is ed-append-to-file-block
action-of ed-read-file is ed-read-file-block

\ #IR file-edit.frt
( ------------ Combined blocks and file support ------------- )

defer ed-write-to-file-file
defer ed-append-to-file-file
defer ed-read-file-file

action-of ed-write-to-file is ed-write-to-file-file
action-of ed-append-to-file is ed-append-to-file-file
action-of ed-read-file is ed-read-file-file

( If the filename given could be a range of block, execute )
( the token for blocks. Otherwise, execute the token for )
( file. Feed c-addr u x to the xt. Return the output of the )
( called token. )
: choose-token ( c-addr u x file-xt block-xt  -- f ) 4 pick
    4 pick try-parse-blocks if nip else drop then execute ;

( ed-write-to-file )
:noname ( c-addr u range -- f ) ['] ed-write-to-file-file
    ['] ed-write-to-file-block choose-token ;
    is ed-write-to-file

( ed-append-to-file )
:noname ( c-addr u range -- f ) ['] ed-append-to-file-file
    ['] ed-append-to-file-block choose-token ;
    is ed-append-to-file

( ed-read-file )
:noname ( c-addr u range -- f ) ['] ed-read-file-file
    ['] ed-read-file-block choose-token ;
    is ed-read-file

