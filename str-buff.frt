( --------------------- String buffers ---------------------- )

( Buffers that store owned copies of strings. )

( Create a string buffer. )
: str-buff: ( "name" -- ) 2 cells buffer: ;

( Init a string buffer. )
: str-buff-init ( str-b -- )
    dup 0 swap ! cell+ 0 xallocate swap ! ;

( Frees a string buffer. )
: str-buff-free ( str-b -- ) cell+ @ xfree ;

( Copy a string to the string buffer. )
: str-buff-set ( c-addr u str-b -- ) >r r@
    cell+ dup @ xfree over xallocate swap !
    dup r@ ! r> cell+ @ swap move ;

( Get the content of the string buffer as a Forth string. )
: str-buff-get ( str-b -- c-addr u ) dup cell+ @ swap @ ;

\ #SI
( -------------------------- Test --------------------------- )

str-buff: b1
b1 str-buff-init
str-buff: b2
b2 str-buff-init

s" abcd" b1 str-buff-set
s" 1234" b2 str-buff-set
b1 str-buff-get type cr
b2 str-buff-get type cr

s" ABCD" b1 str-buff-set
s" 9876" b2 str-buff-set
b1 str-buff-get type cr
b2 str-buff-get type cr

b1 str-buff-free
b2 str-buff-free
depth . cr
bye

