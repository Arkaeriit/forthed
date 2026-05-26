\ #IR list.frt
( ----------------- Linked list of strings ------------------ )

( The linked list contains owned copies of the strings. The )
( size of the string is stored on a cell, followed by the   )
( content of the string.                                    )

( Copies the string at addr, with the size on a cell and the )
( content following. )
: str-copy-owned ( c-addr u addr -- ) 2dup ! cell+ swap move ;

( Returns the string stored at the given address as a forth )
( string. )
: str-get ( addr -- c-addr u ) dup @ swap cell+ swap ;

( Add the string at the given index to the list. )
: slist-add ( c-addr u index lst -- ) >r >r dup cell+ r> r>
    list-add str-copy-owned ;

( Get the string stored at the given index. )
: slist-get ( index lst -- c-addr u ) list-get str-get ;

( Truncate all strings in the list to the given size. )
1 value slist-len
: truncating ( addr -- ) dup @ slist-len > if
    <# 10 hold s"  is too long. Truncating it." holds
       list-exec-index 1 + s>d #s s" Line " holds #> type
    slist-len swap ! else drop then ;
: slist-truncate ( len lst -- ) swap to slist-len
    ['] truncating swap list-exec ;
    
( Pad all strings to the given size with the given char. )
( Truncate strings that are longer than the given size. )
bl value slist-padding
: padding ( addr -- ) dup @ slist-len < if
    dup str-get slist-len swap
    ?do dup i + slist-padding swap c! loop drop
    slist-len swap !
    else drop then ;
: slist-pad ( c len lst -- ) 2dup slist-truncate
    2dup swap cell+ swap list-resize-all-nodes
    2 pick to slist-padding ['] padding swap list-exec 2drop ;

( Prints the content of a string list. )
: str-print ( addr -- ) str-get type cr ;
: slist-print ( lst -- ) ['] str-print swap list-exec ;

\ #SI
( -------------------------- Test --------------------------- )

list-init constant lst
s" abcd" 0 lst slist-add
s" EFGH" 0 lst slist-add
s" 0" 0 lst slist-add
s" YOLO" 0 lst slist-add
lst slist-print
2 lst slist-truncate
lst slist-print
s" This is a long line" 3 lst slist-add
'x' 5 lst slist-pad
lst slist-print
lst list-free
bye
