\ #IR line-reader.frt
( ------------------- Reading and writing ------------------- )

0 value opened-file
0 value file-edit-worked

( Sets the file being edited to the given filename and fam. )
( Return true if it worked. )
: set-opened-file ( c-addr u fam f[create-flag] -- f )
    if create-file else open-file then
    if ." Can't open file" cr false to file-edit-worked cr
        false else to opened-file true then ;

( Writing to a file )
: file-edit-write-line ( c-addr u -- ) opened-file
    write-line drop ( as the ior is not specified in the )
    ( standard I prefer to drop it rather than misinterpret )
    ( it ) ;

( Do the write action on the given range. )
: file-edit-with-fam ( c-addr u range fam -- f )
    true to file-edit-worked
    >r >r rot rot
    r> r> set-opened-file 0= if exit then
    ['] file-edit-write-line ed-exec-on-range
    opened-file close-file abort" Can't close file"
    file-edit-worked ;

( ed-write-to-file )
:noname ( c-addr u range -- f ) w/o true file-edit-with-fam ;
    is ed-write-to-file

( ed-append-to-file )
:noname ( c-addr u range -- f ) w/o false file-edit-with-fam ;
    is ed-append-to-file

( ed-read-file )
:noname ( c-addr u1 u2 -- f ) >r r/o false set-opened-file
    dup 0= if r> drop exit then
    0 xallocate 0 begin drop xfree
        opened-file read-line-allocated while
        2dup r@ ed-lst slist-add r> 1+ >r repeat
    r> drop true ; is ed-read-file

\ #SI
( -------------------------- Test --------------------------- )

ed-init
s" /tmp/isk.txt" ed-set-default-filename
ed-repl
ed-deinit
bye

