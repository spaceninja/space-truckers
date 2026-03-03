LIST Locations = Transit, Earth, Mars, Luna
LIST PortMetrics = ToEarth, ToLuna, ToMars

/*

    Cargo Database

*/
=== function get_distance(from, to)
{ from:
- Earth:
    ~ return distance_db(to, 0, 10, 20)
- Luna:
    ~ return distance_db(to, 10, 0, 10)
- Mars:
    ~ return distance_db(to, 20, 10, 0)
- else:
    [ Error: no data associated with {from}. ]
}

=== function distance_db(to, toEarth, toLuna, toMars)
{to:
- Earth:  ~ return toEarth
- Luna:  ~ return toLuna
- Mars:  ~ return toMars
}
