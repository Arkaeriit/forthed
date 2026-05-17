\ #IR txt-list.frt
\ #IN number-list.frt
( ------------------------ ED editor ------------------------ )

( ED modes )
0 constant ed-mode-prompt
1 constant ed-mode-input

( ED state )
0 value ed-lst
0 value ed-current-line
0 value ed-mode

( Initializes the editor. )
: ed-init ( -- ) list-init to ed-lst
    0 to ed-current-line 
    ed-mode-prompt to ed-mode ;

( Process a line input in the input mode. )
: ed-process-input ( c-addr u -- ) 2dup s" ." compare 0= if
        2drop ed-mode-prompt to ed-mode else
    ed-current-line ed-lst slist-add
    ed-current-line 1+ to ed-current-line then ;

( -------------------------- Test --------------------------- )

ed-init
s" first line" ed-process-input
s" second line" ed-process-input
s" ." ed-process-input
ed-lst slist-print
ed-lst list-free
bye
