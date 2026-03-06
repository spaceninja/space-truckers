INCLUDE port.ink
INCLUDE ship.ink
INCLUDE cargo.ink
INCLUDE locations.ink
INCLUDE functions.ink


VAR PlayerBankBalance = 50

VAR ShipEconomyMode = 3
VAR ShipBalanceMode = 4
VAR ShipTurboMode = 5
VAR ShipCargoCapacity = 40
VAR ShipFuelCapacity = 1000
VAR ShipFuel = 750
VAR ShipCargo = ()

-> arrive_in_port(here)
//-> transit(Mars, 300, 7)