/**
 * Unit tests for extracted port functions.
 *
 *   can_use_flight_mode(is_blocked, fuel, cost)
 *     → true when not is_blocked AND fuel >= cost
 *
 *   get_fuel_purchase_cost(amount)
 *     → FLOOR(amount × get_fuel_price(here))
 *     where here defaults to Earth (fuel price 1.2) at game start
 */

import { describe, it, expect, beforeAll } from "vitest";
import { createStory, L } from "../helpers/story.js";

let story;

beforeAll(() => {
  story = createStory();
  // here starts at Earth (fuel price 1.2)
});

describe("can_use_flight_mode", () => {
  function canUse(isBlocked, fuel, cost) {
    return story.EvaluateFunction("can_use_flight_mode", [isBlocked, fuel, cost]);
  }

  it("returns true when not blocked and fuel >= cost", () => {
    expect(canUse(false, 100, 50)).toBe(true);
  });

  it("returns true when not blocked and fuel exactly equals cost", () => {
    expect(canUse(false, 50, 50)).toBe(true);
  });

  it("returns false when not blocked but fuel < cost", () => {
    expect(canUse(false, 40, 50)).toBe(false);
  });

  it("returns false when blocked regardless of sufficient fuel", () => {
    expect(canUse(true, 300, 50)).toBe(false);
  });

  it("returns false when both blocked and fuel insufficient", () => {
    expect(canUse(true, 10, 50)).toBe(false);
  });
});

describe("get_fuel_purchase_cost", () => {
  function fuelCost(amount) {
    return story.EvaluateFunction("get_fuel_purchase_cost", [amount]);
  }

  // At Earth, fuel price = 1.2
  it("costs FLOOR(amount × 1.2) at Earth", () => {
    expect(fuelCost(10)).toBe(Math.floor(10 * 1.2));   // 12
    expect(fuelCost(15)).toBe(Math.floor(15 * 1.2));   // 18
    expect(fuelCost(100)).toBe(Math.floor(100 * 1.2)); // 120
  });

  it("floors fractional results", () => {
    // 7 × 1.2 = 8.4 → 8
    expect(fuelCost(7)).toBe(8);
  });

  it("returns 0 for zero amount", () => {
    expect(fuelCost(0)).toBe(0);
  });
});
