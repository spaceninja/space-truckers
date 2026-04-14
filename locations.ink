LIST AllLocations = None, Transit, Earth, Luna
LIST LocationStats = Name

/*

    Location Database
    Returns the requested stat for a single location entry.

*/
=== function LocationData(id, data)
{ id:
- Earth:
    ~ return location_db(data, "Earth")
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