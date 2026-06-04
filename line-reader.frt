( ----------------------- Line reader ----------------------- )

( Code to read line from files into owned string. The )
( returned string is ALLOCATE-ed and will be as big as )
( needed. The buffer will be freed by the caller. )

( Size of chunks read from the file. )
10 constant line-buffer-chunk-size

0 value line-buffer
0 value line-buffer-size

( Increase the size of the line buffer by the chunk size. )
: bump-line-buffer-size ( -- ) line-buffer line-buffer-size
    line-buffer-chunk-size + dup to line-buffer-size
    resize abort" Can't resize buffer." to line-buffer ;

( Initialize the buffer. )
: init-line-buffer ( -- ) 0 allocate abort" Can't allocate."
    to line-buffer 0 to line-buffer-size ;

( Get the last chunk of the buffer, intended to feed )
( read-line. )
: get-last-buffer-chunk ( -- c-addr u ) line-buffer
    line-buffer-size + line-buffer-chunk-size -
    line-buffer-chunk-size ;

( Feed the last chunk to read-line and return a flag telling )
( that the file is not fully read yet and the number of read )
( chars as reported by read-line. )
: feed-to-read-line ( fileid -- f u ) >r get-last-buffer-chunk
    r> read-line 0= and swap ;

( Read a whole line from the file and return it in an )
( allocated string. Return the string and a flag telling )
( that the file is not fully read. )
0 value fileid-save
: read-line-allocated ( fileid -- c-addr u f ) to fileid-save
    init-line-buffer 0 0 begin bump-line-buffer-size
        2drop fileid-save feed-to-read-line dup
        line-buffer-chunk-size <> until
    line-buffer-size + line-buffer-chunk-size - ( f u )
    line-buffer swap rot ;

\ #SI
( -------------------------- Test --------------------------- )

: test-loop s" line-reader.frt" r/o open-file
    abort" Can't open"
    begin dup read-line-allocated >r 2dup type cr drop free
        abort" Can't free." r> 0= until
    close-file ;
test-loop bye
