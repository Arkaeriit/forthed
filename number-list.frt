\ #IR list.frt
( --------------------- List of numbers --------------------- )

( Append a number to the list. )
: nlist-append ( n lst -- ) cell swap list-add-tail ! ;

( Display a list of numbers. )
: n-print ( addr -- ) @ . ;
: nlist-print ( lst -- ) ['] n-print swap list-exec ;

( Get the first number of the list. )
: nlist-get-first ( lst -- n ) 0 swap list-get @ ;

( Return true if all the numbers in the list are between )
( lower and upper included. )
0 value nlist-lower
0 value nlist-higher
0 value nlist-in-range-ok
: nlist-node-in-range ( addr -- ) @ dup nlist-lower >= swap
    nlist-higher <= and 0= if false to nlist-in-range-ok then ;
: nlist-in-range ( lst lower upper -- f ) to nlist-higher
    to nlist-lower true to nlist-in-range-ok
    ['] nlist-node-in-range swap list-exec nlist-in-range-ok ;

