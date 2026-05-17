( ------------------- Miscellaneous words ------------------- )

( Like allocate but abort in case of error. )
: xallocate ( u -- addr ) allocate
    abort" Can't allocate memory." ;

( Like free but abort in case of error. )
: xfree ( addr -- ) free abort" Can't free." ;

