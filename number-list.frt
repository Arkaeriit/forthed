\ #IR list.frt
( --------------------- List of numbers --------------------- )

( Append a number to the list. )
: nlist-append ( n lst -- ) cell swap list-add-tail ! ;

( Display a list of numbers. )
: n-print ( addr -- ) @ . ;
: nlist-print ( lst -- ) ['] n-print swap list-exec ;

