\ #IR ed.frt
( ------------------- Reading and writing ------------------- )

0 value file-being-edited

( Sets the file being edited to the given filename and fam. )
( Return true if it worked. )
: set-file-being-edited ( c-addr u fam -- f ) create-file
    if ." Can't open file" cr false
    else to file-being-edited true then ;

( Writing to a file )
: file-edit-write-line ( c-addr u -- ) file-being-edited 
    write-line drop ;

( Do the write action on the given range. )
: file-edit-with-fam ( c-addr u range fam -- ) >r rot rot r>
    set-file-being-edited 0= if exit then
    ['] file-edit-write-line ed-exec-on-range
    file-being-edited close-file abort" Can't close file" ;

( ed-write-to-file )
:noname ( c-addr u range -- ) w/o file-edit-with-fam ;
    is ed-write-to-file

( -------------------------- Test --------------------------- )

ed-init
s" /tmp/isk.txt" ed-set-default-filename
ed-repl
ed-deinit
bye

