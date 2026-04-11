/**
 * Simulate average profit for Earth↔Luna trips on a Tier 1 engine in Eco mode.
 * Profit = total cargo pay − fuel cost in euros.
 *
 * Reads cargo data from the compiled Ink source via inkjs, then runs
 * randomized cargo draws to estimate average per-trip profit.
 *
 * Express and Passenger cargo are excluded (unavailable at T1 without modules).
 *
 * Usage: node scripts/profit-sim.mjs
 */

import { createStory, L } from "../tests/helpers/story.js";

const ITERATIONS = 200;
const story = createStory();

// Game constants (see space-truckers.ink, locations.ink)
const DISTANCE_EARTH_LUNA = 5;
const FUEL_PRICE_INNER = 1.2; // Earth and Luna fuel price
const ECO_FUEL_FACTOR = 1.1; // T1 engine EcoFuel
const PAY_RATE = 3; // VAR PayRate
const SHIP_HULL_MASS = 5; // added in get_trip_fuel_cost

// ── Cargo name map (number prefix → full item name) ─────────────────────────

const cargoNameMap = new Map();
const { result: allCargoDef } = story.listDefinitions.TryListGetDefinition("AllCargo", null);
for (const [jsonKey] of allCargoDef._items) {
  const { itemName } = JSON.parse(jsonKey);
  cargoNameMap.set(itemName.split("_")[0], itemName);
}

function cargoItem(paddedNum) {
  const name = cargoNameMap.get(paddedNum);
  return name ? L(story, `AllCargo.${name}`) : null;
}

// ── Extract cargo pool for a port ───────────────────────────────────────────

function extractPortCargo(fromPort) {
  const ranges = { Earth: [1, 99], Luna: [101, 199] };
  const [lo, hi] = ranges[fromPort];
  const pool = [];

  for (let n = lo; n <= hi; n++) {
    const itemL = cargoItem(String(n).padStart(3, "0"));
    if (!itemL) continue;

    const from = story.EvaluateFunction("CargoData", [itemL, L(story, "CargoStats.From")]);
    if (from.toString() !== fromPort) continue;

    const to = story.EvaluateFunction("CargoData", [itemL, L(story, "CargoStats.To")]);
    const mass = story.EvaluateFunction("CargoData", [itemL, L(story, "CargoStats.Mass")]);
    const express = story.EvaluateFunction("CargoData", [itemL, L(story, "CargoStats.Express")]);
    const fragile = story.EvaluateFunction("CargoData", [itemL, L(story, "CargoStats.Fragile")]);
    const hazardous = story.EvaluateFunction("CargoData", [itemL, L(story, "CargoStats.Hazardous")]);
    const passengers = story.EvaluateFunction("CargoData", [itemL, L(story, "CargoStats.Passengers")]);

    // Not available at T1 without modules
    if (express || passengers) continue;

    // Pay formula: FLOOR(mass × distance × PayRate), +50% per flag
    const basePay = Math.floor(mass * DISTANCE_EARTH_LUNA * PAY_RATE);
    let totalPay = basePay;
    if (fragile) totalPay += Math.floor(basePay / 2);
    if (hazardous) totalPay += Math.floor(basePay / 2);

    pool.push({
      name: itemL.toString(),
      to: to.toString(),
      mass,
      pay: totalPay,
    });
  }

  return pool;
}

// ── Helpers ─────────────────────────────────────────────────────────────────

function fuelCostEuros(cargoMass) {
  const fuelUnits = Math.floor(DISTANCE_EARTH_LUNA * (cargoMass + SHIP_HULL_MASS) * ECO_FUEL_FACTOR);
  return Math.floor(fuelUnits * FUEL_PRICE_INNER);
}

function randomSubset(arr, n) {
  const copy = [...arr];
  const result = [];
  for (let i = 0; i < n && copy.length > 0; i++) {
    const idx = Math.floor(Math.random() * copy.length);
    result.push(copy.splice(idx, 1)[0]);
  }
  return result;
}

// ── Simulation ──────────────────────────────────────────────────────────────

function simulate(fromPort, toPort) {
  const portCargo = extractPortCargo(fromPort);
  const destCount = portCargo.filter(c => c.to === toPort).length;

  console.log(`\n${fromPort} → ${toPort}`);
  console.log(`  Port cargo pool: ${portCargo.length} items (excl. Express/Passengers)`);
  console.log(`  ${toPort}-bound: ${destCount} items`);

  const results = [];
  for (let i = 0; i < ITERATIONS; i++) {
    const drawn = randomSubset(portCargo, 5);
    const destItems = drawn.filter(c => c.to === toPort);

    if (destItems.length === 0) {
      results.push({ pay: 0, fuelCost: 0, profit: 0, items: 0, mass: 0 });
      continue;
    }

    const totalMass = destItems.reduce((sum, c) => sum + c.mass, 0);
    const totalPay = destItems.reduce((sum, c) => sum + c.pay, 0);
    const fuel = fuelCostEuros(totalMass);

    results.push({
      pay: totalPay,
      fuelCost: fuel,
      profit: totalPay - fuel,
      items: destItems.length,
      mass: totalMass,
    });
  }

  return results;
}

// ── Reporting ───────────────────────────────────────────────────────────────

function report(label, results) {
  const avg = (arr) => arr.reduce((a, b) => a + b, 0) / arr.length;

  console.log(`\n=== ${label} (${results.length} runs, Eco mode, T1 engine) ===`);
  console.log(`Avg dest items:   ${avg(results.map(r => r.items)).toFixed(1)} of 5 drawn`);
  console.log(`Avg cargo mass:   ${avg(results.map(r => r.mass)).toFixed(0)}t`);
  console.log(`Avg cargo pay:    ${avg(results.map(r => r.pay)).toFixed(0)} €`);
  console.log(`Avg fuel cost:    ${avg(results.map(r => r.fuelCost)).toFixed(0)} €`);
  console.log(`Avg profit:       ${avg(results.map(r => r.profit)).toFixed(0)} €`);
  console.log(`Min profit:       ${Math.min(...results.map(r => r.profit))} €`);
  console.log(`Max profit:       ${Math.max(...results.map(r => r.profit))} €`);
  console.log(`Zero-cargo runs:  ${results.filter(r => r.items === 0).length}`);
}

// ── Main ────────────────────────────────────────────────────────────────────

const earthToLuna = simulate("Earth", "Luna");
report("Earth → Luna", earthToLuna);

const lunaToEarth = simulate("Luna", "Earth");
report("Luna → Earth", lunaToEarth);

const roundTrips = earthToLuna.map((e, i) => ({
  pay: e.pay + lunaToEarth[i].pay,
  fuelCost: e.fuelCost + lunaToEarth[i].fuelCost,
  profit: e.profit + lunaToEarth[i].profit,
  items: e.items + lunaToEarth[i].items,
  mass: 0,
}));
report("Round trip (Earth → Luna → Earth)", roundTrips);
