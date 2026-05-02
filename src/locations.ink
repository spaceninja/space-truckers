LIST AllLocations = None, Transit, Luna, Mars
LIST LocationStats = Name

VAR here = None

/*

    Location Database
    Returns the requested stat for a single location entry.

*/
=== function LocationData(id, data)
{ id:
- Mars:
    ~ return location_db(data, "Mars")
- Luna:
    ~ return location_db(data, "Moon Base")
- else:
    [ Error: no location data associated with {id}. ]
}

/*

    Location Database Row
    Returns the requested stat for a single location entry.

*/
=== function location_db(id, nameData)
{ id:
- Name:     ~ return nameData
}