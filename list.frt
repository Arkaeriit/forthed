\ #IR utils.frt
( ------------ Basic linked list implementation ------------- )

( The list head 'lst' in prototypes is a pointer to the first )
(  element of the list. The list is NULL terminated. )
: list-init ( -- lst ) cell xallocate dup 0 swap ! ;

( Get the next element from the list. )
: list-next ( node -- node' ) ?dup if @ else
    1 abort" Calling list-next on tail element." then ;

( Get the element at the given index. The list is 0 indexed. )
( Requesting -1 will give the list pointer. )
: (list-get) ( index lst -- node ) swap 1+ 0
    ?do list-next loop ;

( Get the data at the given index of the list. )
: list-get ( index lst -- addr ) (list-get) cell+ ;

( Get the number of elements in the list. )
: list-size ( lst -- u ) -1 swap
    begin ?dup while swap 1+ swap list-next repeat ;

( Add a new element in the list at the given index, allocate )
( the given amount of memory for its data, return a pointer )
( to the data space. )
: list-add ( size index lst -- addr ) 2dup swap 1 - swap
    (list-get) >r (list-get) >r cell+
    xallocate dup dup r> swap ! r> ! cell+ ; 

( Add a new element at the start or end of the list. )
: list-add-head ( size lst -- addr ) 0 rot swap rot list-add ;
: list-add-tail ( size lst -- addr )
    dup list-size rot swap rot list-add ;

( Index of the list element being executed on. )
0 value list-exec-index

( Run an execution token of prototype [ addr -- ] on a range )
( of index from the list. )
: list-exec-on-range ( xt end-index start-index lst -- )
    rot rot ?do
        i to list-exec-index
        2dup i swap list-get swap execute loop 2drop ;

( Run an execution token of prototype [ addr -- ] on the list )
: list-exec ( xt lst -- )
    dup list-size 0 rot list-exec-on-range ;

( Reallocate the node at the given index to have a new size. )
( The size only refer to the content size and does not )
( include the pointer to the next node. )
: list-resize-node ( size index lst -- ) 2dup (list-get)
    3 pick cell+ resize abort" Can't resize node."
    ( size index lst data )
    >r swap 1- swap (list-get) r> swap ! drop ;

( Reallocate all the node so that their data has the given )
( size. )
: list-resize-all-nodes ( size lst -- ) dup list-size 0 ?do
    2dup i swap list-resize-node loop 2drop ;

( Reverse a list. Return the same list that was given. Data )
( is changed in place. )
0 value edited-node
0 value head
0 value tail
: list-reverse ( lst1 -- lst1 ) dup list-size 0= if exit then
    dup dup to head dup list-size
    1- swap (list-get) dup to tail to edited-node
    head list-size 1- 0 swap ?do
        i head (list-get) dup edited-node !
        to edited-node -1 +loop
    0 edited-node ! tail head ! head ;

( Delete the element of the list at the given index. )
: list-delete ( index lst -- ) 2dup (list-get) >r
    swap 1- swap (list-get)
    r> dup @ swap xfree swap ! ;

( Deallocate a list. )
: list-free ( lst -- ) dup list-size dup 0 ?do
    2dup i - 1- swap (list-get) xfree loop
    drop xfree ;

\ #SI
( -------------------------- Test --------------------------- )

list-init constant lst
cell lst list-add-head 1 swap !
cell lst list-add-head 2 swap !
cell lst list-add-head 3 swap !
cell lst list-add-head 4 swap !

:noname @ . cr ; lst list-exec cr
lst list-reverse drop
:noname @ . cr ; lst list-exec cr
2 lst list-delete
:noname @ . cr ; lst list-exec cr
0 lst list-delete
:noname @ . cr ; lst list-exec cr
1 lst list-delete
:noname @ . cr ; lst list-exec cr
lst list-free

list-init list-reverse ." okay" cr list-free
list-init dup 0 swap list-add-head drop list-reverse list-free
bye

