( ------------------- Miscellaneous words ------------------- )

( Like allocate but abort in case of error. )
: xallocate ( u -- addr ) allocate
    abort" Can't allocate memory." ;

