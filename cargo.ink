LIST CargoStats = From, To, Mass, Title, Express, Fragile, Hazardous, Passengers
LIST AllCargo =
    000_Ship,

    // Earth cargo 001 through 099
    (001_Plums), (002_Fish), (003_Water), (004_Seafood), (005_Seeds),
    (006_Honey), (007_Silk), (008_Cotton), (009_Wool), (010_Linen),
    (011_Wheat), (012_Rice), (013_Barley), (014_Oats), (015_Corn),
    (016_Soybeans), (017_Tea), (018_Coffee), (019_Cocoa), (020_Sugar),
    (021_Spices), (022_Saffron), (023_Vanilla), (024_Cinnamon), (025_OliveOil),
    (026_Butter), (027_Cheese), (028_Yogurt), (029_Cream), (030_Eggs),
    (031_Diplomats), (032_Tourists), (033_Beef), (034_Pork), (035_Lamb),
    (036_Chicken), (037_Venison), (038_Salmon), (039_Oysters), (040_Lobster),
    (041_Shrimp), (042_Caviar), (043_Strawberries), (044_Oranges), (045_Lemons),
    (046_Apples), (047_Grapes), (048_Mangoes), (049_Bananas), (050_Peaches),
    (051_Cherries), (052_Scientists), (053_Students), (054_Fertilizer), (055_Herbicide),
    (056_Champagne), (057_Wine), (058_Whiskey), (059_Bourbon), (060_Sake),
    (061_Beer), (062_Rum), (063_Lumber), (064_Bamboo), (065_Cork),
    (066_Beeswax), (067_Lavender), (068_Roses), (069_Orchids), (070_Tulips),
    (071_Coral), (072_Pearls), (073_Amber), (074_Marble), (075_Musicians),
    (076_Clay), (077_Sand), (078_Topsoil), (079_Peat), (080_Leather),
    (081_Denim), (082_Lace), (083_Perfume), (084_Soap), (085_Candles),
    (086_Tobacco), (087_Horses), (088_Cattle), (089_Chickens), (090_Athletes),
    (091_Bees), (092_Saplings), (093_Algae), (094_Mushrooms), (095_Truffles),
    (096_Ginseng), (097_Medicines), (098_Vaccines), (099_Pilgrims),

    // Luna cargo 101 through 199
    (101_Helium), (102_Moonshine), (103_Rocks), (104_Helium),
    (105_He3Canisters), (106_RegolithBricks), (107_SinteredTiles), (108_TychoGlass),
    (109_PrintedCircuits), (110_SolarCells), (111_BasaltFiber), (112_CraterClay),
    (113_TitaniumSlugs), (114_VacuumSteel), (115_AluminumIngots), (116_SilverDust),
    (117_OxygenTanks), (118_CopernRubble), (119_GrimaldiSalt), (120_NeonTubes),
    (121_OpticCable), (122_MareGlass), (123_WaterIce), (124_He3Flasks),
    (125_IronPellets), (126_RareEarths), (127_GrapheneSheets), (128_MedKits),
    (129_LabGear), (130_SensorPacks), (131_CeramicPlates), (132_QuantumChips),
    (133_MagnesiumBars), (134_AnorthiteSlabs), (135_IlmeniteOre), (136_Bearings),
    (137_LunarConcrete), (138_Fertilizer), (139_SolarPanels), (140_BatteryPacks),
    (141_SpinnakerSails), (142_LifeSupport), (143_RadShielding), (144_CarbonNano),
    (145_PumpParts), (146_DrillBits), (147_AirFilters), (148_FusionPellets),
    (149_TranqSand), (150_Botanicals), (151_FiberOptics), (152_ToolSteel),
    (153_CompactReactor), (154_BulkRegolith), (155_PrintedGears), (156_Aerogel),
    (157_ArgonCanisters), (158_Electrolyte), (159_WeldingRods), (160_GyroUnits),
    (161_CobaltPowder), (162_Engineers), (163_Diplomats), (164_Geologists),
    (165_PressureValves), (166_TungstenWire), (167_HullPlates), (168_AntennaParts),
    (169_PropellantMix), (170_NickelSlabs), (171_SlagBricks), (172_ThermalPaste),
    (173_MicroLenses), (174_ZirconiaDust), (175_He3Bulk), (176_LabSamples),
    (177_VacuumTubes), (178_MoonRocks2), (179_CeramicFiber), (180_PlatingComp),
    (181_NavSystems), (182_WaferStock), (183_TitaniumSheet), (184_ShieldComp),
    (185_OpticalGlass), (186_CopernicusClay), (187_ReactorRods), (188_InsulationBatt),
    (189_MiningGear), (190_RegolithBlock), (191_ChromiumDust), (192_GasCartridges),
    (193_CircuitBoards), (194_AramidFabric), (195_PlatinumDust), (196_HeliumTank),
    (197_NitrogenFlasks), (198_CoolantPacks), (199_FresnelLens),

    // Mars cargo 201 through 299
    (201_Plums), (202_Beef), (203_Bugs), (204_Platinum), (205_Tomatoes),
    (206_Mushrooms), (207_IronOre), (208_Basalt), (209_AlgaePaste), (210_CopperWire),
    (211_RegolithBricks), (212_SyntheticRubber), (213_DriedApricots), (214_SoybeanMeal), (215_GreenhousePeppers),
    (216_VatChicken), (217_PotatoStarch), (218_OlympusHoney), (219_UtopiaWheat), (220_HellasRice),
    (221_TerraformEnzymes), (222_NitrogenTanks), (223_SulfurPowder), (224_LabEquipment), (225_ClimateSensors),
    (226_SoilBacteria), (227_Fertilizer), (228_SeedStock), (229_HeatShields), (230_AirlockSeals),
    (231_NeonGas), (232_VallesClay), (233_GlassSheets), (234_SteelBeams), (235_WeldingRods),
    (236_PrintedCircuits), (237_BatteryPacks), (238_SolarCells), (239_WaterFilters), (240_ArcadiaSalt),
    (241_DeuteriumOxide), (242_TharsisSulfur), (243_CobaltIngots), (244_TitaniumBillets), (245_NickelPellets),
    (246_SiliconWafers), (247_GrapheneRolls), (248_PhenolicResin), (249_Pharmaceuticals), (250_MedicalKits),
    (251_VaccineVials), (252_ElysiumLavender), (253_HopsExtract), (254_MaltedBarley), (255_YeastCultures),
    (256_TextileFiber), (257_ProteinBars), (258_FreezedriedMeals), (259_CannedGoods), (260_RecycledPlastics),
    (261_Lubricants), (262_HydraulicFluid), (263_InsulationFoam), (264_ToolSets), (265_SpareParts),
    (266_PipeSegments), (267_ConcreteMix), (268_PavonisGranite), (269_GypsusPowder), (270_CeramicTiles),
    (271_FiberOptics), (272_RadioIsotopes), (273_DustFilters), (274_CompressedCO2), (275_Explosives),
    (276_RocketPropellant), (277_PerchlorateSalt), (278_LiveSeedlings), (279_CoralFragments), (280_MuseumFossils),
    (281_GeologySamples), (282_Engineers), (283_Geologists), (284_DomeWorkers), (285_MedicalStaff),
    (286_AresTea), (287_CactusFruit), (288_MushroomJerky), (289_VatLamb), (290_ChiliPowder),
    (291_ReducedIron), (292_ManganeseOre), (293_AluminumStock), (294_ZincConcentrate), (295_SandstoneBlocks),
    (296_PumpParts), (297_MotorCoils), (298_ServerRacks), (299_OpticalLenses),

    // Ceres cargo 301 through 400
    (301_Ore), (302_Ice), (303_Samples), (304_Colonists),
    (305_Nickel), (306_Iron), (307_Cobalt), (308_Gravel),
    (309_Silicates), (310_Regolith), (311_Carbon), (312_Sulfur),
    (313_Titanium), (314_Platinum), (315_Manganese), (316_Iridium),
    (317_Bauxite), (318_Aggregate), (319_Slag), (320_Tailings),
    (321_Chromite), (322_Olivine), (323_Pellets), (324_Ingots),
    (325_Slurry), (326_Calcite), (327_Phosphate), (328_Zinc),
    (329_RareEarth), (330_Magnesium), (331_Solder), (332_Scrap),
    (333_Tubing), (334_Plating), (335_Fasteners), (336_Drills),
    (337_Bearings), (338_Cutters), (339_Grinders), (340_Blades),
    (341_Pumps), (342_Valves), (343_Filters), (344_Gaskets),
    (345_Cable), (346_Sensors), (347_Batteries), (348_Panels),
    (349_Coolant), (350_Sealant), (351_Lubricant), (352_Resin),
    (353_Adhesive), (354_Fiber), (355_Insulation), (356_Shielding),
    (357_Catalysts), (358_Solvents), (359_Acids), (360_Oxidizer),
    (361_Peroxide), (362_Acetylene), (363_Ammonia), (364_Chlorine),
    (365_Cyanide), (366_Propellant), (367_Rations), (368_Flour),
    (369_Yeast), (370_Algae), (371_Vitamins), (372_Mushrooms),
    (373_Spirits), (374_Whiskey), (375_Hops), (376_Jerky),
    (377_Soylent), (378_Seeds), (379_Soil), (380_Fertilizer),
    (381_Compost), (382_Mulch), (383_Miners), (384_Medics),
    (385_BulkIce), (386_Geodes), (387_Artifacts), (388_Meteorites),
    (389_Antiques), (390_Specimens), (391_Workers), (392_Engineers),
    (393_MiningDrones), (394_Rovers), (395_Scanners), (396_CoreProbes),
    (397_Charges), (398_DrillAssembly), (399_Furnace), (400_Trophies),

    // Ganymede cargo 401 through 499
    (401_Protein), (402_Metals), (403_Samples), (404_Team),
    (405_IceCores), (406_Reagents), (407_Telescopes), (408_Biofilm),
    (409_Cryogenics), (410_Sensors), (411_Regolith), (412_GeneLib),
    (413_Sulfur), (414_Antennas), (415_Isotopes), (416_Coolant),
    (417_Optics), (418_Cultures), (419_Polymers), (420_Datatapes),
    (421_Magnets), (422_Probes), (423_Filters), (424_Catalysts),
    (425_Algae), (426_Titanium), (427_Graphene), (428_Specimens),
    (429_Chassis), (430_Flywheel), (431_Drones), (432_Spectrometer),
    (433_Plankton), (434_Pipettes), (435_Centrifuge), (436_Bacteria),
    (437_Lenses), (438_Fiber), (439_Helium), (440_Germanium),
    (441_Circuits), (442_Primers), (443_Membranes), (444_Enzymes),
    (445_Actuators), (446_Sealant), (447_Gaskets), (448_Wafers),
    (449_Feedstock), (450_Tubing), (451_Insulators), (452_Radiators),
    (453_Scrubbers), (454_Drills), (455_Bolts), (456_Adhesive),
    (457_Pellets), (458_Precursors), (459_Detectors), (460_Winches),
    (461_Bearings), (462_Valves), (463_Capacitors), (464_Thermite),
    (465_Crucibles), (466_Resins), (467_Grease), (468_Spores),
    (469_Yeasts), (470_Stem), (471_Vaccines), (472_Antivenom),
    (473_Serums), (474_Plasma), (475_Xenon), (476_Cartilage),
    (477_Marrow), (478_Tissue), (479_Embryos), (480_Seedlings),
    (481_Mycelia), (482_Lichens), (483_Diatoms), (484_Coral),
    (485_Krill), (486_Larvae), (487_Interns), (488_Lecturers),
    (489_RadioSamples), (490_Silkworms), (491_Archivists),
    (492_Journals), (493_Fossils), (494_Meteorites), (495_Prisms),
    (496_Gratings), (497_Cuvettes), (498_Pipework), (499_Cylinders),

    // Titan cargo 501 through 600
    (501_Methane), (502_Polymers), (503_Samples), (504_Survey), (505_Ethane),
    (506_Propane), (507_Tholin), (508_Butane), (509_Acetylene), (510_Benzene),
    (511_Cyanide), (512_Ammonia), (513_Nitrogen), (514_Slurry), (515_Bitumen),
    (516_Wax), (517_Resin), (518_Sealant), (519_Grease), (520_Coolant),
    (521_Antifreeze), (522_Insulation), (523_Cryogel), (524_Aerogel), (525_Regolith),
    (526_Pebbles), (527_Dust), (528_Silt), (529_Sediment), (530_Cores),
    (531_Fossils), (532_Microbes), (533_Enzymes), (534_Cultures), (535_Spores),
    (536_Settlers), (537_Miners), (538_Engineers), (539_Medics), (540_Geologists),
    (541_Welders), (542_Techs), (543_Suits), (544_Helmets), (545_Boots),
    (546_Gloves), (547_Heaters), (548_Lamps), (549_Drills), (550_Cutters),
    (551_Winches), (552_Cables), (553_Pipe), (554_Valves), (555_Pumps),
    (556_Filters), (557_Sensors), (558_Probes), (559_Drones), (560_Beacons),
    (561_Radios), (562_Relays), (563_Panels), (564_Batteries), (565_Cells),
    (566_Coils), (567_Magnets), (568_Mirrors), (569_Lenses), (570_Optics),
    (571_Chips), (572_Boards), (573_Drives), (574_Servos), (575_Gaskets),
    (576_Bolts), (577_Rivets), (578_Plating), (579_Mesh), (580_Foam),
    (581_Tape), (582_Adhesive), (583_Whiskey), (584_Brandy), (585_Rations),
    (586_Seeds), (587_Fertilizer), (588_Mulch), (589_Pellets), (590_Brine),
    (591_Crystals), (592_Pigment), (593_Dye), (594_Catalysts), (595_Reagents),
    (596_Isotopes), (597_Deuterium), (598_Graphene), (599_Silicone), (600_Solvents)

/*

    Port Economic Identities
    (for cargo authoring reference)

    Earth     — the breadbasket. Biological goods, food, water, luxury items,
                cultural exports. The "old world" producing what can't be grown elsewhere.
    Luna      — mining and light industry. Helium-3, regolith products, manufactured
                goods. Close to Earth, also a trade hub.
    Mars      — agriculture + mining colony. Terraforming-era crops, vat protein,
                mineral wealth. Transitioning from frontier to established.
    Ceres     — belt mining station. Raw materials, ice, frontier supplies.
                Rougher, more industrial.
    Ganymede  — scientific outpost orbiting Jupiter. Research samples, precision
                instruments, biotech. The "university town" of the outer system.
    Titan     — deep frontier. Exotic hydrocarbons, extreme-environment materials,
                survey crews. Edge of civilization.

    Cargo Database

    cargo_db args: data, from, to, mass, title, express, fragile, hazardous, passengers

*/
=== function CargoData(id, data)
{ id:

// ── Earth (001–099) ───────────────────────────────────────────────────────────
- 001_Plums:
    ~ return cargo_db(data, Earth, Luna,      10, "juicy plums",              1, 0, 0, 0)
- 002_Fish:
    ~ return cargo_db(data, Earth, Luna,      20, "fresh fish",               1, 0, 0, 0)
- 003_Water:
    ~ return cargo_db(data, Earth, Mars,      40, "clean water",              0, 0, 0, 0)
- 004_Seafood:
    ~ return cargo_db(data, Earth, Mars,      20, "assorted seafood",         1, 0, 0, 0)
- 005_Seeds:
    ~ return cargo_db(data, Earth, Luna,       5, "heirloom seeds",           0, 0, 0, 0)
- 006_Honey:
    ~ return cargo_db(data, Earth, Luna,      10, "wildflower honey",         0, 0, 0, 0)
- 007_Silk:
    ~ return cargo_db(data, Earth, Luna,       5, "raw silk bolts",           0, 0, 0, 0)
- 008_Cotton:
    ~ return cargo_db(data, Earth, Luna,      15, "cotton bales",             0, 0, 0, 0)
- 009_Wool:
    ~ return cargo_db(data, Earth, Luna,      15, "merino wool",              0, 0, 0, 0)
- 010_Linen:
    ~ return cargo_db(data, Earth, Luna,      10, "Irish linen",              0, 0, 0, 0)
- 011_Wheat:
    ~ return cargo_db(data, Earth, Luna,      30, "winter wheat",             0, 0, 0, 0)
- 012_Rice:
    ~ return cargo_db(data, Earth, Luna,      20, "jasmine rice",             0, 0, 0, 0)
- 013_Barley:
    ~ return cargo_db(data, Earth, Luna,      15, "malting barley",           0, 0, 0, 0)
- 014_Oats:
    ~ return cargo_db(data, Earth, Luna,      10, "rolled oats",              0, 0, 0, 0)
- 015_Corn:
    ~ return cargo_db(data, Earth, Luna,      20, "sweet corn",               0, 0, 0, 0)
- 016_Soybeans:
    ~ return cargo_db(data, Earth, Luna,      20, "organic soybeans",         0, 0, 0, 0)
- 017_Tea:
    ~ return cargo_db(data, Earth, Luna,      10, "Darjeeling tea",           1, 0, 0, 0)
- 018_Coffee:
    ~ return cargo_db(data, Earth, Luna,      10, "Ethiopian coffee",         1, 0, 0, 0)
- 019_Cocoa:
    ~ return cargo_db(data, Earth, Luna,      10, "cacao beans",              0, 0, 0, 0)
- 020_Sugar:
    ~ return cargo_db(data, Earth, Luna,      30, "cane sugar",               0, 0, 0, 0)
- 021_Spices:
    ~ return cargo_db(data, Earth, Luna,       5, "mixed spice crate",        0, 0, 0, 0)
- 022_Saffron:
    ~ return cargo_db(data, Earth, Luna,       5, "saffron threads",          1, 0, 0, 0)
- 023_Vanilla:
    ~ return cargo_db(data, Earth, Luna,      10, "vanilla pods",             1, 0, 0, 0)
- 024_Cinnamon:
    ~ return cargo_db(data, Earth, Luna,      15, "Ceylon cinnamon",          0, 0, 0, 0)
- 025_OliveOil:
    ~ return cargo_db(data, Earth, Luna,      15, "olive oil",                0, 1, 0, 0)
- 026_Butter:
    ~ return cargo_db(data, Earth, Luna,      10, "cultured butter",          0, 1, 0, 0)
- 027_Cheese:
    ~ return cargo_db(data, Earth, Luna,      15, "aged Gruyere",             0, 0, 0, 0)
- 028_Yogurt:
    ~ return cargo_db(data, Earth, Luna,      10, "Greek yogurt",             0, 1, 0, 0)
- 029_Cream:
    ~ return cargo_db(data, Earth, Luna,      15, "heavy cream",              0, 1, 0, 0)
- 030_Eggs:
    ~ return cargo_db(data, Earth, Luna,      20, "free-range eggs",          0, 1, 0, 0)
- 031_Diplomats:
    ~ return cargo_db(data, Earth, Luna,      30, "diplomatic delegation",    0, 0, 0, 1)
- 032_Tourists:
    ~ return cargo_db(data, Earth, Luna,      20, "Luna tourists",            0, 0, 0, 1)
- 033_Beef:
    ~ return cargo_db(data, Earth, Mars,      30, "grass-fed beef",           0, 0, 0, 0)
- 034_Pork:
    ~ return cargo_db(data, Earth, Mars,      20, "cured pork",               0, 0, 0, 0)
- 035_Lamb:
    ~ return cargo_db(data, Earth, Mars,      15, "lamb shanks",              0, 0, 0, 0)
- 036_Chicken:
    ~ return cargo_db(data, Earth, Mars,      20, "free-range chicken",       0, 0, 0, 0)
- 037_Venison:
    ~ return cargo_db(data, Earth, Mars,      15, "smoked venison",           0, 0, 0, 0)
- 038_Salmon:
    ~ return cargo_db(data, Earth, Mars,      10, "Alaskan salmon",           1, 0, 0, 0)
- 039_Oysters:
    ~ return cargo_db(data, Earth, Mars,      10, "Chesapeake oysters",       0, 1, 0, 0)
- 040_Lobster:
    ~ return cargo_db(data, Earth, Mars,      10, "live Maine lobster",       1, 0, 0, 0)
- 041_Shrimp:
    ~ return cargo_db(data, Earth, Mars,      10, "gulf shrimp",              1, 0, 0, 0)
- 042_Caviar:
    ~ return cargo_db(data, Earth, Mars,       5, "beluga caviar",            1, 0, 0, 0)
- 043_Strawberries:
    ~ return cargo_db(data, Earth, Mars,       5, "fresh strawberries",       0, 1, 0, 0)
- 044_Oranges:
    ~ return cargo_db(data, Earth, Mars,      20, "Valencia oranges",         0, 0, 0, 0)
- 045_Lemons:
    ~ return cargo_db(data, Earth, Mars,      15, "Meyer lemons",             0, 0, 0, 0)
- 046_Apples:
    ~ return cargo_db(data, Earth, Mars,      30, "Fuji apples",              0, 0, 0, 0)
- 047_Grapes:
    ~ return cargo_db(data, Earth, Mars,      15, "table grapes",             0, 0, 0, 0)
- 048_Mangoes:
    ~ return cargo_db(data, Earth, Mars,      10, "Alphonso mangoes",         1, 0, 0, 0)
- 049_Bananas:
    ~ return cargo_db(data, Earth, Mars,      30, "plantains",                0, 0, 0, 0)
- 050_Peaches:
    ~ return cargo_db(data, Earth, Mars,      15, "Georgia peaches",          0, 0, 0, 0)
- 051_Cherries:
    ~ return cargo_db(data, Earth, Mars,       5, "Rainier cherries",         0, 0, 0, 0)
- 052_Scientists:
    ~ return cargo_db(data, Earth, Mars,      20, "research team",            0, 0, 0, 1)
- 053_Students:
    ~ return cargo_db(data, Earth, Mars,      30, "exchange students",        0, 0, 0, 1)
- 054_Fertilizer:
    ~ return cargo_db(data, Earth, Mars,      40, "organic fertilizer",       0, 0, 1, 0)
- 055_Herbicide:
    ~ return cargo_db(data, Earth, Mars,      20, "bio-herbicides",           0, 0, 1, 0)
- 056_Champagne:
    ~ return cargo_db(data, Earth, Ceres,     20, "Champagne",                0, 1, 0, 0)
- 057_Wine:
    ~ return cargo_db(data, Earth, Ceres,     30, "Bordeaux wine",            0, 0, 0, 0)
- 058_Whiskey:
    ~ return cargo_db(data, Earth, Ceres,     20, "aged whiskey",             0, 0, 0, 0)
- 059_Bourbon:
    ~ return cargo_db(data, Earth, Ceres,     15, "Kentucky bourbon",         0, 0, 0, 0)
- 060_Sake:
    ~ return cargo_db(data, Earth, Ceres,     10, "junmai sake",              0, 0, 0, 0)
- 061_Beer:
    ~ return cargo_db(data, Earth, Ceres,     30, "craft beer kegs",          0, 0, 0, 0)
- 062_Rum:
    ~ return cargo_db(data, Earth, Ceres,     15, "Caribbean rum",            0, 0, 0, 0)
- 063_Lumber:
    ~ return cargo_db(data, Earth, Ceres,     50, "hardwood lumber",          0, 0, 0, 0)
- 064_Bamboo:
    ~ return cargo_db(data, Earth, Ceres,     40, "bamboo poles",             0, 0, 0, 0)
- 065_Cork:
    ~ return cargo_db(data, Earth, Ceres,     10, "Portuguese cork",          0, 0, 0, 0)
- 066_Beeswax:
    ~ return cargo_db(data, Earth, Ceres,      5, "beeswax blocks",           0, 0, 0, 0)
- 067_Lavender:
    ~ return cargo_db(data, Earth, Ceres,      5, "dried lavender",           0, 0, 0, 0)
- 068_Roses:
    ~ return cargo_db(data, Earth, Ceres,     10, "long-stem roses",          1, 0, 0, 0)
- 069_Orchids:
    ~ return cargo_db(data, Earth, Ceres,     15, "orchid specimens",         0, 0, 0, 0)
- 070_Tulips:
    ~ return cargo_db(data, Earth, Ceres,     15, "Dutch tulip bulbs",        0, 0, 0, 0)
- 071_Coral:
    ~ return cargo_db(data, Earth, Ceres,     40, "live coral",               0, 1, 1, 0)
- 072_Pearls:
    ~ return cargo_db(data, Earth, Ceres,      5, "Tahitian pearls",          0, 0, 0, 0)
- 073_Amber:
    ~ return cargo_db(data, Earth, Ceres,     50, "Baltic amber",             0, 0, 0, 0)
- 074_Marble:
    ~ return cargo_db(data, Earth, Ceres,     50, "Carrara marble",           0, 0, 0, 0)
- 075_Musicians:
    ~ return cargo_db(data, Earth, Ceres,     20, "touring musicians",        0, 0, 0, 1)
- 076_Clay:
    ~ return cargo_db(data, Earth, Ganymede,  40, "pottery clay",             0, 0, 0, 0)
- 077_Sand:
    ~ return cargo_db(data, Earth, Ganymede,  50, "silica sand",              0, 0, 0, 0)
- 078_Topsoil:
    ~ return cargo_db(data, Earth, Ganymede,  40, "enriched topsoil",         0, 0, 0, 0)
- 079_Peat:
    ~ return cargo_db(data, Earth, Ganymede,  30, "sphagnum peat",            0, 0, 0, 0)
- 080_Leather:
    ~ return cargo_db(data, Earth, Ganymede,  15, "tanned leather",           0, 0, 0, 0)
- 081_Denim:
    ~ return cargo_db(data, Earth, Ganymede,  20, "denim bolts",              0, 0, 0, 0)
- 082_Lace:
    ~ return cargo_db(data, Earth, Ganymede,  10, "Belgian lace",             1, 0, 0, 0)
- 083_Perfume:
    ~ return cargo_db(data, Earth, Ganymede,  10, "Parisian perfume",         0, 0, 1, 0)
- 084_Soap:
    ~ return cargo_db(data, Earth, Ganymede,  15, "Marseille soap",           0, 0, 0, 0)
- 085_Candles:
    ~ return cargo_db(data, Earth, Ganymede,  10, "beeswax candles",          1, 0, 0, 0)
- 086_Tobacco:
    ~ return cargo_db(data, Earth, Ganymede,  20, "pipe tobacco",             0, 0, 0, 0)
- 087_Horses:
    ~ return cargo_db(data, Earth, Ganymede,  30, "horses",                   0, 0, 0, 0)
- 088_Cattle:
    ~ return cargo_db(data, Earth, Ganymede,  40, "breeding cattle",          0, 0, 0, 0)
- 089_Chickens:
    ~ return cargo_db(data, Earth, Ganymede,  15, "laying hens",              0, 0, 0, 0)
- 090_Athletes:
    ~ return cargo_db(data, Earth, Ganymede,  30, "sports team",              0, 0, 0, 1)
- 091_Bees:
    ~ return cargo_db(data, Earth, Titan,     15, "honeybee colonies",        0, 0, 0, 0)
- 092_Saplings:
    ~ return cargo_db(data, Earth, Titan,     20, "oak saplings",             0, 0, 0, 0)
- 093_Algae:
    ~ return cargo_db(data, Earth, Titan,     10, "spirulina cultures",       1, 0, 0, 0)
- 094_Mushrooms:
    ~ return cargo_db(data, Earth, Titan,     10, "truffle spawn",            0, 0, 0, 0)
- 095_Truffles:
    ~ return cargo_db(data, Earth, Titan,     20, "Perigord truffles",        1, 0, 1, 0)
- 096_Ginseng:
    ~ return cargo_db(data, Earth, Titan,     10, "wild ginseng",             0, 0, 1, 0)
- 097_Medicines:
    ~ return cargo_db(data, Earth, Titan,     30, "pharmaceutical crate",     1, 0, 1, 0)
- 098_Vaccines:
    ~ return cargo_db(data, Earth, Titan,     20, "vaccine shipment",         1, 0, 1, 0)
- 099_Pilgrims:
    ~ return cargo_db(data, Earth, Titan,     40, "pilgrims",                 0, 0, 0, 0)

// ── Luna (101–199) ────────────────────────────────────────────────────────────
- 101_Helium:
    ~ return cargo_db(data, Luna,  Earth,     20, "helium-3",                 0, 0, 0, 0)
- 102_Moonshine:
    ~ return cargo_db(data, Luna,  Earth,     40, "moonshine",                0, 0, 0, 0)
- 103_Rocks:
    ~ return cargo_db(data, Luna,  Mars,      10, "moon rocks",               0, 0, 0, 0)
- 104_Helium:
    ~ return cargo_db(data, Luna,  Mars,      20, "helium-3",                 0, 0, 0, 0)
- 105_He3Canisters:
    ~ return cargo_db(data, Luna,  Earth,     15, "helium-3 canisters",       1, 0, 0, 0)
- 106_RegolithBricks:
    ~ return cargo_db(data, Luna,  Earth,     30, "sintered regolith",        0, 0, 0, 0)
- 107_SinteredTiles:
    ~ return cargo_db(data, Luna,  Earth,     10, "sintered tiles",           0, 0, 0, 0)
- 108_TychoGlass:
    ~ return cargo_db(data, Luna,  Earth,     15, "Tycho glass",              0, 1, 0, 0)
- 109_PrintedCircuits:
    ~ return cargo_db(data, Luna,  Earth,      5, "printed circuits",         1, 0, 0, 0)
- 110_SolarCells:
    ~ return cargo_db(data, Luna,  Earth,     10, "solar cells",              0, 1, 0, 0)
- 111_BasaltFiber:
    ~ return cargo_db(data, Luna,  Earth,     20, "basalt fiber",             0, 0, 0, 0)
- 112_CraterClay:
    ~ return cargo_db(data, Luna,  Earth,     10, "crater clay",              0, 0, 0, 0)
- 113_TitaniumSlugs:
    ~ return cargo_db(data, Luna,  Earth,     30, "titanium slugs",           0, 0, 0, 0)
- 114_VacuumSteel:
    ~ return cargo_db(data, Luna,  Earth,     50, "vacuum-forged steel",      0, 0, 0, 0)
- 115_AluminumIngots:
    ~ return cargo_db(data, Luna,  Earth,     30, "aluminum ingots",          0, 0, 0, 0)
- 116_SilverDust:
    ~ return cargo_db(data, Luna,  Earth,      5, "silver dust",              1, 0, 0, 0)
- 117_OxygenTanks:
    ~ return cargo_db(data, Luna,  Earth,     15, "oxygen tanks",             0, 0, 1, 0)
- 118_CopernRubble:
    ~ return cargo_db(data, Luna,  Earth,     20, "Copernicus rubble",        0, 0, 0, 0)
- 119_GrimaldiSalt:
    ~ return cargo_db(data, Luna,  Earth,     10, "Grimaldi salt",            0, 0, 0, 0)
- 120_NeonTubes:
    ~ return cargo_db(data, Luna,  Earth,     10, "neon tubes",               1, 0, 0, 0)
- 121_OpticCable:
    ~ return cargo_db(data, Luna,  Earth,     15, "optic cable spools",       0, 0, 0, 0)
- 122_MareGlass:
    ~ return cargo_db(data, Luna,  Earth,     20, "Mare Crisium glass",       0, 1, 0, 0)
- 123_WaterIce:
    ~ return cargo_db(data, Luna,  Earth,     40, "polar water ice",          0, 0, 0, 0)
- 124_He3Flasks:
    ~ return cargo_db(data, Luna,  Earth,      5, "helium-3 flasks",          1, 0, 0, 0)
- 125_IronPellets:
    ~ return cargo_db(data, Luna,  Earth,     30, "iron pellets",             0, 0, 0, 0)
- 126_RareEarths:
    ~ return cargo_db(data, Luna,  Earth,     15, "rare earth oxides",        1, 0, 0, 0)
- 127_GrapheneSheets:
    ~ return cargo_db(data, Luna,  Earth,      5, "graphene sheets",          0, 1, 0, 0)
- 128_MedKits:
    ~ return cargo_db(data, Luna,  Earth,     10, "medical kits",             1, 0, 0, 0)
- 129_LabGear:
    ~ return cargo_db(data, Luna,  Earth,     15, "lab equipment",            0, 1, 1, 0)
- 130_SensorPacks:
    ~ return cargo_db(data, Luna,  Earth,      5, "sensor packs",             1, 0, 0, 0)
- 131_CeramicPlates:
    ~ return cargo_db(data, Luna,  Mars,      15, "ceramic plates",           0, 0, 0, 0)
- 132_QuantumChips:
    ~ return cargo_db(data, Luna,  Mars,       5, "quantum chips",            0, 1, 0, 0)
- 133_MagnesiumBars:
    ~ return cargo_db(data, Luna,  Mars,      30, "magnesium bars",           0, 0, 0, 0)
- 134_AnorthiteSlabs:
    ~ return cargo_db(data, Luna,  Mars,      40, "anorthosite slabs",        0, 0, 0, 0)
- 135_IlmeniteOre:
    ~ return cargo_db(data, Luna,  Mars,      20, "ilmenite ore",             0, 0, 0, 0)
- 136_Bearings:
    ~ return cargo_db(data, Luna,  Mars,      10, "precision bearings",       0, 0, 0, 0)
- 137_LunarConcrete:
    ~ return cargo_db(data, Luna,  Mars,      50, "lunar concrete mix",       0, 0, 0, 0)
- 138_Fertilizer:
    ~ return cargo_db(data, Luna,  Mars,      20, "regolith fertilizer",      0, 0, 0, 0)
- 139_SolarPanels:
    ~ return cargo_db(data, Luna,  Mars,      15, "solar panel array",        0, 1, 0, 0)
- 140_BatteryPacks:
    ~ return cargo_db(data, Luna,  Mars,      10, "battery packs",            0, 0, 1, 0)
- 141_SpinnakerSails:
    ~ return cargo_db(data, Luna,  Mars,      10, "spinnaker sails",          0, 0, 0, 0)
- 142_LifeSupport:
    ~ return cargo_db(data, Luna,  Mars,      20, "life support units",       1, 0, 0, 0)
- 143_RadShielding:
    ~ return cargo_db(data, Luna,  Mars,      40, "radiation shielding",      0, 0, 0, 0)
- 144_CarbonNano:
    ~ return cargo_db(data, Luna,  Mars,      10, "carbon nanotubes",         0, 0, 0, 0)
- 145_PumpParts:
    ~ return cargo_db(data, Luna,  Earth,     10, "pump assemblies",          1, 0, 0, 0)
- 146_DrillBits:
    ~ return cargo_db(data, Luna,  Mars,      15, "diamond drill bits",       0, 0, 0, 0)
- 147_AirFilters:
    ~ return cargo_db(data, Luna,  Mars,      10, "air filters",              1, 0, 0, 0)
- 148_FusionPellets:
    ~ return cargo_db(data, Luna,  Mars,       5, "fusion pellets",           0, 0, 1, 0)
- 149_TranqSand:
    ~ return cargo_db(data, Luna,  Mars,      30, "Tranquility sand",         0, 0, 0, 0)
- 150_Botanicals:
    ~ return cargo_db(data, Luna,  Mars,      15, "dome botanicals",          0, 1, 0, 0)
- 151_FiberOptics:
    ~ return cargo_db(data, Luna,  Mars,      10, "fiber optic bundles",      0, 0, 0, 0)
- 152_ToolSteel:
    ~ return cargo_db(data, Luna,  Mars,      20, "tool steel billets",       0, 0, 0, 0)
- 153_CompactReactor:
    ~ return cargo_db(data, Luna,  Mars,      40, "compact reactor",          1, 0, 1, 0)
- 154_BulkRegolith:
    ~ return cargo_db(data, Luna,  Titan,     40, "bulk regolith",            0, 0, 0, 0)
- 155_PrintedGears:
    ~ return cargo_db(data, Luna,  Mars,      20, "printed gears",            0, 0, 0, 0)
- 156_Aerogel:
    ~ return cargo_db(data, Luna,  Ceres,     15, "aerogel panels",           0, 0, 0, 0)
- 157_ArgonCanisters:
    ~ return cargo_db(data, Luna,  Ceres,     10, "argon canisters",          0, 0, 0, 0)
- 158_Electrolyte:
    ~ return cargo_db(data, Luna,  Ceres,     20, "electrolyte solution",     0, 0, 0, 0)
- 159_WeldingRods:
    ~ return cargo_db(data, Luna,  Ceres,     15, "welding rods",             0, 0, 0, 0)
- 160_GyroUnits:
    ~ return cargo_db(data, Luna,  Ceres,     10, "gyroscope units",          0, 0, 0, 0)
- 161_CobaltPowder:
    ~ return cargo_db(data, Luna,  Ceres,     15, "cobalt powder",            0, 0, 1, 0)
- 162_Engineers:
    ~ return cargo_db(data, Luna,  Ceres,     10, "mining engineers",         0, 0, 0, 1)
- 163_Diplomats:
    ~ return cargo_db(data, Luna,  Ceres,     20, "trade diplomats",          0, 0, 0, 1)
- 164_Geologists:
    ~ return cargo_db(data, Luna,  Ceres,     10, "field geologists",         0, 0, 0, 1)
- 165_PressureValves:
    ~ return cargo_db(data, Luna,  Ceres,     20, "pressure valves",          0, 0, 0, 0)
- 166_TungstenWire:
    ~ return cargo_db(data, Luna,  Ceres,     10, "tungsten wire",            0, 0, 0, 0)
- 167_HullPlates:
    ~ return cargo_db(data, Luna,  Ceres,     50, "hull plates",              0, 0, 0, 0)
- 168_AntennaParts:
    ~ return cargo_db(data, Luna,  Ceres,     30, "antenna components",       0, 0, 0, 0)
- 169_PropellantMix:
    ~ return cargo_db(data, Luna,  Ceres,     30, "propellant mix",           0, 0, 1, 0)
- 170_NickelSlabs:
    ~ return cargo_db(data, Luna,  Ceres,     40, "nickel slabs",             0, 0, 0, 0)
- 171_SlagBricks:
    ~ return cargo_db(data, Luna,  Ceres,     20, "slag bricks",              0, 0, 0, 0)
- 172_ThermalPaste:
    ~ return cargo_db(data, Luna,  Ceres,     15, "thermal paste",            0, 0, 0, 0)
- 173_MicroLenses:
    ~ return cargo_db(data, Luna,  Ceres,      5, "micro lenses",             1, 0, 0, 0)
- 174_ZirconiaDust:
    ~ return cargo_db(data, Luna,  Ceres,     15, "zirconia dust",            0, 0, 0, 0)
- 175_He3Bulk:
    ~ return cargo_db(data, Luna,  Ceres,     30, "helium-3 bulk",            0, 0, 0, 0)
- 176_LabSamples:
    ~ return cargo_db(data, Luna,  Ganymede,   5, "lab samples",              0, 1, 0, 0)
- 177_VacuumTubes:
    ~ return cargo_db(data, Luna,  Ganymede,  10, "vacuum tubes",             0, 0, 0, 0)
- 178_MoonRocks2:
    ~ return cargo_db(data, Luna,  Ganymede,  10, "moon rocks",               0, 0, 0, 0)
- 179_CeramicFiber:
    ~ return cargo_db(data, Luna,  Ganymede,  20, "ceramic fiber rolls",      0, 0, 0, 0)
- 180_PlatingComp:
    ~ return cargo_db(data, Luna,  Ganymede,  15, "plating compound",         0, 0, 0, 0)
- 181_NavSystems:
    ~ return cargo_db(data, Luna,  Ganymede,  15, "navigation systems",       1, 0, 0, 0)
- 182_WaferStock:
    ~ return cargo_db(data, Luna,  Ganymede,  10, "silicon wafer stock",      0, 0, 0, 0)
- 183_TitaniumSheet:
    ~ return cargo_db(data, Luna,  Ganymede,  30, "titanium sheeting",        0, 0, 0, 0)
- 184_ShieldComp:
    ~ return cargo_db(data, Luna,  Ganymede,  20, "shielding compound",       0, 0, 1, 0)
- 185_OpticalGlass:
    ~ return cargo_db(data, Luna,  Ganymede,  15, "optical glass blanks",     0, 1, 0, 0)
- 186_CopernicusClay:
    ~ return cargo_db(data, Luna,  Ganymede,  20, "Copernicus clay",          0, 0, 0, 0)
- 187_ReactorRods:
    ~ return cargo_db(data, Luna,  Ganymede,  30, "reactor control rods",     1, 0, 1, 0)
- 188_InsulationBatt:
    ~ return cargo_db(data, Luna,  Ganymede,  20, "insulation batts",         0, 0, 0, 0)
- 189_MiningGear:
    ~ return cargo_db(data, Luna,  Ganymede,  40, "mining equipment",         0, 0, 0, 0)
- 190_RegolithBlock:
    ~ return cargo_db(data, Luna,  Ganymede,  30, "regolith blocks",          0, 0, 0, 0)
- 191_ChromiumDust:
    ~ return cargo_db(data, Luna,  Titan,     10, "chromium dust",            0, 0, 0, 0)
- 192_GasCartridges:
    ~ return cargo_db(data, Luna,  Titan,     15, "gas cartridges",           0, 0, 0, 0)
- 193_CircuitBoards:
    ~ return cargo_db(data, Luna,  Titan,      5, "circuit boards",           1, 0, 0, 0)
- 194_AramidFabric:
    ~ return cargo_db(data, Luna,  Titan,     20, "aramid fabric",            0, 0, 0, 0)
- 195_PlatinumDust:
    ~ return cargo_db(data, Luna,  Titan,     10, "platinum dust",            0, 0, 0, 0)
- 196_HeliumTank:
    ~ return cargo_db(data, Luna,  Titan,     20, "helium-3 tank",            1, 0, 0, 0)
- 197_NitrogenFlasks:
    ~ return cargo_db(data, Luna,  Titan,     15, "nitrogen flasks",          0, 0, 0, 0)
- 198_CoolantPacks:
    ~ return cargo_db(data, Luna,  Titan,     30, "coolant packs",            0, 0, 0, 0)
- 199_FresnelLens:
    ~ return cargo_db(data, Luna,  Titan,     50, "Fresnel lens array",       0, 1, 0, 0)

// ── Mars (201–299) ────────────────────────────────────────────────────────────
- 201_Plums:
    ~ return cargo_db(data, Mars,  Earth,     10, "red plums",                1, 0, 0, 0)
- 202_Beef:
    ~ return cargo_db(data, Mars,  Earth,     20, "vat-grown beef",           1, 0, 0, 0)
- 203_Bugs:
    ~ return cargo_db(data, Mars,  Luna,      10, "nutritious bugs",          1, 0, 0, 0)
- 204_Platinum:
    ~ return cargo_db(data, Mars,  Luna,      40, "platinum",                 0, 0, 0, 0)
- 205_Tomatoes:
    ~ return cargo_db(data, Mars,  Luna,      10, "greenhouse tomatoes",      1, 0, 0, 0)
- 206_Mushrooms:
    ~ return cargo_db(data, Mars,  Luna,       5, "dried mushrooms",          0, 0, 0, 0)
- 207_IronOre:
    ~ return cargo_db(data, Mars,  Luna,      30, "iron ore",                 0, 0, 0, 0)
- 208_Basalt:
    ~ return cargo_db(data, Mars,  Luna,      20, "basalt gravel",            0, 0, 0, 0)
- 209_AlgaePaste:
    ~ return cargo_db(data, Mars,  Luna,      15, "algae paste",              0, 0, 0, 0)
- 210_CopperWire:
    ~ return cargo_db(data, Mars,  Luna,      15, "copper wire",              0, 0, 0, 0)
- 211_RegolithBricks:
    ~ return cargo_db(data, Mars,  Luna,      30, "regolith bricks",          0, 0, 0, 0)
- 212_SyntheticRubber:
    ~ return cargo_db(data, Mars,  Luna,      20, "synthetic rubber",         0, 0, 0, 0)
- 213_DriedApricots:
    ~ return cargo_db(data, Mars,  Luna,       5, "dried apricots",           1, 0, 0, 0)
- 214_SoybeanMeal:
    ~ return cargo_db(data, Mars,  Luna,      10, "soybean meal",             0, 0, 0, 0)
- 215_GreenhousePeppers:
    ~ return cargo_db(data, Mars,  Luna,      10, "greenhouse peppers",       1, 0, 0, 0)
- 216_VatChicken:
    ~ return cargo_db(data, Mars,  Luna,      15, "vat-grown chicken",        0, 0, 0, 0)
- 217_PotatoStarch:
    ~ return cargo_db(data, Mars,  Luna,      15, "potato starch",            0, 0, 0, 0)
- 218_OlympusHoney:
    ~ return cargo_db(data, Mars,  Luna,      30, "Olympus honey",            0, 1, 0, 0)
- 219_UtopiaWheat:
    ~ return cargo_db(data, Mars,  Luna,      20, "Utopia Planitia wheat",    0, 0, 0, 0)
- 220_HellasRice:
    ~ return cargo_db(data, Mars,  Luna,      10, "Hellas rice",              0, 0, 0, 0)
- 221_TerraformEnzymes:
    ~ return cargo_db(data, Mars,  Luna,      10, "terraforming enzymes",     0, 1, 0, 0)
- 222_NitrogenTanks:
    ~ return cargo_db(data, Mars,  Luna,      30, "nitrogen tanks",           0, 0, 1, 0)
- 223_SulfurPowder:
    ~ return cargo_db(data, Mars,  Luna,      15, "sulfur powder",            0, 0, 1, 0)
- 224_LabEquipment:
    ~ return cargo_db(data, Mars,  Luna,      20, "lab equipment",            0, 1, 0, 0)
- 225_ClimateSensors:
    ~ return cargo_db(data, Mars,  Luna,      40, "climate sensors",          0, 1, 0, 0)
- 226_SoilBacteria:
    ~ return cargo_db(data, Mars,  Luna,      10, "soil bacteria cultures",   0, 1, 0, 0)
- 227_Fertilizer:
    ~ return cargo_db(data, Mars,  Luna,      20, "fertilizer",               0, 0, 0, 0)
- 228_SeedStock:
    ~ return cargo_db(data, Mars,  Luna,      10, "seed stock",               0, 0, 0, 0)
- 229_HeatShields:
    ~ return cargo_db(data, Mars,  Luna,      50, "heat shields",             0, 0, 0, 0)
- 230_AirlockSeals:
    ~ return cargo_db(data, Mars,  Luna,      15, "airlock seals",            1, 0, 0, 0)
- 231_NeonGas:
    ~ return cargo_db(data, Mars,  Luna,      20, "neon gas",                 0, 0, 0, 0)
- 232_VallesClay:
    ~ return cargo_db(data, Mars,  Ceres,     20, "Valles Marineris clay",    0, 0, 0, 0)
- 233_GlassSheets:
    ~ return cargo_db(data, Mars,  Ceres,     15, "glass sheets",             0, 1, 0, 0)
- 234_SteelBeams:
    ~ return cargo_db(data, Mars,  Ceres,     40, "steel beams",              0, 0, 0, 0)
- 235_WeldingRods:
    ~ return cargo_db(data, Mars,  Ceres,     10, "welding rods",             0, 0, 0, 0)
- 236_PrintedCircuits:
    ~ return cargo_db(data, Mars,  Ceres,      5, "printed circuits",         0, 0, 0, 0)
- 237_BatteryPacks:
    ~ return cargo_db(data, Mars,  Ceres,     15, "battery packs",            0, 0, 1, 0)
- 238_SolarCells:
    ~ return cargo_db(data, Mars,  Ceres,     10, "solar cells",              0, 0, 0, 0)
- 239_WaterFilters:
    ~ return cargo_db(data, Mars,  Ceres,     10, "water filters",            0, 0, 0, 0)
- 240_ArcadiaSalt:
    ~ return cargo_db(data, Mars,  Ceres,     15, "Arcadia salt",             0, 0, 0, 0)
- 241_DeuteriumOxide:
    ~ return cargo_db(data, Mars,  Ceres,     30, "deuterium oxide",          0, 0, 1, 0)
- 242_TharsisSulfur:
    ~ return cargo_db(data, Mars,  Ceres,     20, "Tharsis sulfur",           0, 0, 0, 0)
- 243_CobaltIngots:
    ~ return cargo_db(data, Mars,  Ceres,     30, "cobalt ingots",            0, 0, 0, 0)
- 244_TitaniumBillets:
    ~ return cargo_db(data, Mars,  Ceres,     40, "titanium billets",         0, 0, 0, 0)
- 245_NickelPellets:
    ~ return cargo_db(data, Mars,  Ceres,     20, "nickel pellets",           0, 0, 0, 0)
- 246_SiliconWafers:
    ~ return cargo_db(data, Mars,  Ceres,     40, "silicon wafers",           0, 0, 0, 0)
- 247_GrapheneRolls:
    ~ return cargo_db(data, Mars,  Ceres,     10, "graphene rolls",           0, 0, 0, 0)
- 248_PhenolicResin:
    ~ return cargo_db(data, Mars,  Ceres,     15, "phenolic resin",           0, 0, 0, 0)
- 249_Pharmaceuticals:
    ~ return cargo_db(data, Mars,  Ceres,     10, "pharmaceuticals",          1, 0, 0, 0)
- 250_MedicalKits:
    ~ return cargo_db(data, Mars,  Ceres,     15, "medical kits",             1, 0, 0, 0)
- 251_VaccineVials:
    ~ return cargo_db(data, Mars,  Ceres,      5, "vaccine vials",            1, 0, 0, 0)
- 252_ElysiumLavender:
    ~ return cargo_db(data, Mars,  Ceres,      5, "Elysium lavender",         0, 0, 0, 0)
- 253_HopsExtract:
    ~ return cargo_db(data, Mars,  Ceres,     10, "hops extract",             0, 0, 0, 0)
- 254_MaltedBarley:
    ~ return cargo_db(data, Mars,  Ceres,     15, "malted barley",            0, 0, 0, 0)
- 255_YeastCultures:
    ~ return cargo_db(data, Mars,  Ceres,     30, "yeast cultures",           0, 0, 0, 0)
- 256_TextileFiber:
    ~ return cargo_db(data, Mars,  Ceres,     20, "textile fiber",            0, 0, 0, 0)
- 257_ProteinBars:
    ~ return cargo_db(data, Mars,  Earth,     10, "protein bars",             0, 0, 0, 0)
- 258_FreezedriedMeals:
    ~ return cargo_db(data, Mars,  Earth,     15, "freeze-dried meals",       0, 0, 0, 0)
- 259_CannedGoods:
    ~ return cargo_db(data, Mars,  Earth,     20, "canned goods",             0, 0, 0, 0)
- 260_RecycledPlastics:
    ~ return cargo_db(data, Mars,  Earth,     15, "recycled plastics",        0, 0, 0, 0)
- 261_Lubricants:
    ~ return cargo_db(data, Mars,  Earth,     20, "industrial lubricants",    0, 0, 0, 0)
- 262_HydraulicFluid:
    ~ return cargo_db(data, Mars,  Earth,     15, "hydraulic fluid",          0, 0, 1, 0)
- 263_InsulationFoam:
    ~ return cargo_db(data, Mars,  Earth,     10, "insulation foam",          0, 0, 0, 0)
- 264_ToolSets:
    ~ return cargo_db(data, Mars,  Earth,     20, "precision tool sets",      0, 0, 0, 0)
- 265_SpareParts:
    ~ return cargo_db(data, Mars,  Earth,     30, "spare parts",              0, 0, 0, 0)
- 266_PipeSegments:
    ~ return cargo_db(data, Mars,  Earth,     40, "pipe segments",            0, 0, 0, 0)
- 267_ConcreteMix:
    ~ return cargo_db(data, Mars,  Earth,     50, "concrete mix",             0, 0, 0, 0)
- 268_PavonisGranite:
    ~ return cargo_db(data, Mars,  Earth,     30, "Pavonis granite",          0, 0, 0, 0)
- 269_GypsusPowder:
    ~ return cargo_db(data, Mars,  Earth,     15, "gypsum powder",            0, 0, 0, 0)
- 270_CeramicTiles:
    ~ return cargo_db(data, Mars,  Earth,     20, "ceramic tiles",            0, 0, 0, 0)
- 271_FiberOptics:
    ~ return cargo_db(data, Mars,  Earth,      5, "fiber optics",             0, 1, 0, 0)
- 272_RadioIsotopes:
    ~ return cargo_db(data, Mars,  Earth,     10, "radioisotopes",            1, 0, 1, 0)
- 273_DustFilters:
    ~ return cargo_db(data, Mars,  Earth,     10, "dust filters",             0, 0, 0, 0)
- 274_CompressedCO2:
    ~ return cargo_db(data, Mars,  Earth,     30, "compressed CO2",           0, 0, 0, 0)
- 275_Explosives:
    ~ return cargo_db(data, Mars,  Ganymede,  30, "mining explosives",        0, 0, 1, 0)
- 276_RocketPropellant:
    ~ return cargo_db(data, Mars,  Ganymede,  50, "rocket propellant",        0, 1, 1, 0)
- 277_PerchlorateSalt:
    ~ return cargo_db(data, Mars,  Ganymede,  20, "perchlorate salt",         0, 0, 0, 0)
- 278_LiveSeedlings:
    ~ return cargo_db(data, Mars,  Ganymede,  10, "live seedlings",           0, 1, 0, 0)
- 279_CoralFragments:
    ~ return cargo_db(data, Mars,  Ganymede,   5, "coral fragments",          0, 0, 0, 0)
- 280_MuseumFossils:
    ~ return cargo_db(data, Mars,  Ganymede,  15, "museum fossils",           0, 0, 0, 0)
- 281_GeologySamples:
    ~ return cargo_db(data, Mars,  Ganymede,  10, "geology samples",          0, 0, 0, 0)
- 282_Engineers:
    ~ return cargo_db(data, Mars,  Ganymede,  15, "dome engineers",           0, 0, 0, 1)
- 283_Geologists:
    ~ return cargo_db(data, Mars,  Ganymede,  15, "field geologists",         0, 0, 0, 1)
- 284_DomeWorkers:
    ~ return cargo_db(data, Mars,  Ganymede,  20, "dome workers",             0, 0, 0, 1)
- 285_MedicalStaff:
    ~ return cargo_db(data, Mars,  Ganymede,  10, "medical staff",            0, 0, 0, 1)
- 286_AresTea:
    ~ return cargo_db(data, Mars,  Ganymede,   5, "Ares Vallis tea",          1, 0, 0, 0)
- 287_CactusFruit:
    ~ return cargo_db(data, Mars,  Ganymede,  10, "cactus fruit",             1, 0, 0, 0)
- 288_MushroomJerky:
    ~ return cargo_db(data, Mars,  Ganymede,   5, "mushroom jerky",           0, 0, 0, 0)
- 289_VatLamb:
    ~ return cargo_db(data, Mars,  Ganymede,  20, "vat-grown lamb",           1, 0, 0, 0)
- 290_ChiliPowder:
    ~ return cargo_db(data, Mars,  Titan,      5, "chili powder",             0, 0, 0, 0)
- 291_ReducedIron:
    ~ return cargo_db(data, Mars,  Titan,     40, "reduced iron",             0, 0, 0, 0)
- 292_ManganeseOre:
    ~ return cargo_db(data, Mars,  Titan,     30, "manganese ore",            0, 0, 0, 0)
- 293_AluminumStock:
    ~ return cargo_db(data, Mars,  Titan,     30, "aluminum stock",           0, 0, 0, 0)
- 294_ZincConcentrate:
    ~ return cargo_db(data, Mars,  Titan,     20, "zinc concentrate",         0, 0, 0, 0)
- 295_SandstoneBlocks:
    ~ return cargo_db(data, Mars,  Titan,     50, "sandstone blocks",         0, 0, 0, 0)
- 296_PumpParts:
    ~ return cargo_db(data, Mars,  Titan,     15, "pump parts",               0, 0, 0, 0)
- 297_MotorCoils:
    ~ return cargo_db(data, Mars,  Titan,     20, "motor coils",              0, 0, 0, 0)
- 298_ServerRacks:
    ~ return cargo_db(data, Mars,  Titan,     40, "server racks",             1, 0, 1, 0)
- 299_OpticalLenses:
    ~ return cargo_db(data, Mars,  Titan,     10, "optical lenses",           0, 1, 0, 0)

// ── Ceres (301–400) ───────────────────────────────────────────────────────────
- 301_Ore:
    ~ return cargo_db(data, Ceres, Mars,      40, "refined ore",              0, 0, 0, 0)
- 302_Ice:
    ~ return cargo_db(data, Ceres, Earth,     20, "ice cores",                0, 0, 0, 0)
- 303_Samples:
    ~ return cargo_db(data, Ceres, Luna,      10, "belt samples",             0, 1, 0, 0)
- 304_Colonists:
    ~ return cargo_db(data, Ceres, Mars,      10, "colonists",                0, 0, 0, 1) // TODO: transit events
- 305_Nickel:
    ~ return cargo_db(data, Ceres, Mars,      30, "Psyche nickel",            0, 0, 0, 0)
- 306_Iron:
    ~ return cargo_db(data, Ceres, Mars,      40, "Vesta iron",               0, 0, 0, 0)
- 307_Cobalt:
    ~ return cargo_db(data, Ceres, Mars,      20, "cobalt concentrate",       0, 0, 0, 0)
- 308_Gravel:
    ~ return cargo_db(data, Ceres, Mars,      50, "crushed gravel",           0, 0, 0, 0)
- 309_Silicates:
    ~ return cargo_db(data, Ceres, Mars,      30, "processed silicates",      0, 0, 0, 0)
- 310_Regolith:
    ~ return cargo_db(data, Ceres, Mars,      20, "sifted regolith",          0, 0, 0, 0)
- 311_Carbon:
    ~ return cargo_db(data, Ceres, Mars,      15, "compressed carbon",        0, 0, 0, 0)
- 312_Sulfur:
    ~ return cargo_db(data, Ceres, Mars,      15, "raw sulfur",               0, 0, 1, 0)
- 313_Titanium:
    ~ return cargo_db(data, Ceres, Mars,      20, "titanium sponge",          0, 0, 0, 0)
- 314_Platinum:
    ~ return cargo_db(data, Ceres, Mars,      10, "platinum dust",            1, 0, 0, 0)
- 315_Manganese:
    ~ return cargo_db(data, Ceres, Mars,      30, "manganese nodules",        0, 0, 0, 0)
- 316_Iridium:
    ~ return cargo_db(data, Ceres, Mars,       5, "iridium flakes",           1, 0, 0, 0)
- 317_Bauxite:
    ~ return cargo_db(data, Ceres, Mars,      20, "bauxite ore",              0, 0, 0, 0)
- 318_Aggregate:
    ~ return cargo_db(data, Ceres, Mars,      50, "construction aggregate",   0, 0, 0, 0)
- 319_Slag:
    ~ return cargo_db(data, Ceres, Mars,      40, "smelter slag",             0, 0, 0, 0)
- 320_Tailings:
    ~ return cargo_db(data, Ceres, Mars,      30, "mine tailings",            0, 0, 1, 0)
- 321_Chromite:
    ~ return cargo_db(data, Ceres, Mars,      15, "chromite sand",            0, 0, 0, 0)
- 322_Olivine:
    ~ return cargo_db(data, Ceres, Mars,      10, "olivine crystals",         0, 1, 0, 0)
- 323_Pellets:
    ~ return cargo_db(data, Ceres, Mars,      20, "iron pellets",             0, 0, 0, 0)
- 324_Ingots:
    ~ return cargo_db(data, Ceres, Mars,      30, "alloy ingots",             0, 0, 0, 0)
- 325_Slurry:
    ~ return cargo_db(data, Ceres, Mars,      15, "mineral slurry",           0, 0, 1, 0)
- 326_Calcite:
    ~ return cargo_db(data, Ceres, Mars,      10, "calcite powder",           0, 0, 0, 0)
- 327_Phosphate:
    ~ return cargo_db(data, Ceres, Mars,      15, "phosphate rock",           0, 0, 0, 0)
- 328_Zinc:
    ~ return cargo_db(data, Ceres, Mars,      20, "zinc castings",            0, 0, 0, 0)
- 329_RareEarth:
    ~ return cargo_db(data, Ceres, Mars,       5, "rare earth dust",          1, 0, 0, 0)
- 330_Magnesium:
    ~ return cargo_db(data, Ceres, Mars,      15, "magnesium strips",         0, 0, 0, 0)
- 331_Solder:
    ~ return cargo_db(data, Ceres, Mars,      10, "tin solder",               0, 0, 0, 0)
- 332_Scrap:
    ~ return cargo_db(data, Ceres, Mars,      40, "scrap metal",              0, 0, 0, 0)
- 333_Tubing:
    ~ return cargo_db(data, Ceres, Ganymede,  20, "steel tubing",             0, 0, 0, 0)
- 334_Plating:
    ~ return cargo_db(data, Ceres, Ganymede,  40, "salvaged hull plating",    0, 0, 0, 0)
- 335_Fasteners:
    ~ return cargo_db(data, Ceres, Ganymede,  15, "bulk fasteners",           0, 0, 0, 0)
- 336_Drills:
    ~ return cargo_db(data, Ceres, Ganymede,  20, "diamond drills",           0, 0, 0, 0)
- 337_Bearings:
    ~ return cargo_db(data, Ceres, Ganymede,  10, "ceramic bearings",         0, 0, 0, 0)
- 338_Cutters:
    ~ return cargo_db(data, Ceres, Ganymede,  15, "plasma cutters",           1, 0, 0, 0)
- 339_Grinders:
    ~ return cargo_db(data, Ceres, Ganymede,  30, "rock grinders",            0, 0, 0, 0)
- 340_Blades:
    ~ return cargo_db(data, Ceres, Ganymede,  10, "saw blades",               0, 0, 0, 0)
- 341_Pumps:
    ~ return cargo_db(data, Ceres, Ganymede,  20, "vacuum pumps",             0, 0, 0, 0)
- 342_Valves:
    ~ return cargo_db(data, Ceres, Ganymede,  10, "pressure valves",          0, 0, 0, 0)
- 343_Filters:
    ~ return cargo_db(data, Ceres, Ganymede,  10, "air filters",              0, 0, 0, 0)
- 344_Gaskets:
    ~ return cargo_db(data, Ceres, Ganymede,   5, "hull gaskets",             0, 0, 0, 0)
- 345_Cable:
    ~ return cargo_db(data, Ceres, Ganymede,  15, "shielded cable",           0, 0, 0, 0)
- 346_Sensors:
    ~ return cargo_db(data, Ceres, Ganymede,   5, "seismic sensors",          0, 1, 0, 0)
- 347_Batteries:
    ~ return cargo_db(data, Ceres, Ganymede,  20, "mining batteries",         0, 0, 1, 0)
- 348_Panels:
    ~ return cargo_db(data, Ceres, Ganymede,  10, "solar panels",             0, 1, 0, 0)
- 349_Coolant:
    ~ return cargo_db(data, Ceres, Ganymede,  15, "reactor coolant",          0, 0, 1, 0)
- 350_Sealant:
    ~ return cargo_db(data, Ceres, Ganymede,  10, "hull sealant",             0, 0, 0, 0)
- 351_Lubricant:
    ~ return cargo_db(data, Ceres, Ganymede,  15, "drill lubricant",          0, 0, 0, 0)
- 352_Resin:
    ~ return cargo_db(data, Ceres, Ganymede,  20, "industrial resin",         0, 0, 0, 0)
- 353_Adhesive:
    ~ return cargo_db(data, Ceres, Ganymede,   5, "vacuum adhesive",          0, 0, 0, 0)
- 354_Fiber:
    ~ return cargo_db(data, Ceres, Ganymede,  10, "carbon fiber",             0, 0, 0, 0)
- 355_Insulation:
    ~ return cargo_db(data, Ceres, Ganymede,  15, "thermal insulation",       0, 0, 0, 0)
- 356_Shielding:
    ~ return cargo_db(data, Ceres, Ganymede,  30, "rad shielding",            0, 0, 0, 0)
- 357_Catalysts:
    ~ return cargo_db(data, Ceres, Ganymede,   5, "spent catalysts",          1, 0, 1, 0)
- 358_Solvents:
    ~ return cargo_db(data, Ceres, Luna,      10, "cleaning solvents",        0, 0, 1, 0)
- 359_Acids:
    ~ return cargo_db(data, Ceres, Luna,      15, "etching acids",            0, 0, 1, 0)
- 360_Oxidizer:
    ~ return cargo_db(data, Ceres, Luna,      20, "liquid oxidizer",          0, 0, 1, 0)
- 361_Peroxide:
    ~ return cargo_db(data, Ceres, Luna,      10, "hydrogen peroxide",        1, 0, 1, 0)
- 362_Acetylene:
    ~ return cargo_db(data, Ceres, Luna,      15, "acetylene tanks",          0, 0, 1, 0)
- 363_Ammonia:
    ~ return cargo_db(data, Ceres, Luna,      20, "ammonia ice",              0, 0, 0, 0)
- 364_Chlorine:
    ~ return cargo_db(data, Ceres, Luna,      10, "chlorine tablets",         0, 0, 0, 0)
- 365_Cyanide:
    ~ return cargo_db(data, Ceres, Luna,       5, "gold cyanide",             1, 0, 1, 0)
- 366_Propellant:
    ~ return cargo_db(data, Ceres, Luna,      30, "solid propellant",         0, 0, 0, 0)
- 367_Rations:
    ~ return cargo_db(data, Ceres, Luna,      15, "emergency rations",        1, 0, 0, 0)
- 368_Flour:
    ~ return cargo_db(data, Ceres, Luna,      20, "cricket flour",            0, 0, 0, 0)
- 369_Yeast:
    ~ return cargo_db(data, Ceres, Luna,       5, "brewer's yeast",           1, 0, 0, 0)
- 370_Algae:
    ~ return cargo_db(data, Ceres, Luna,      10, "dried algae",              0, 0, 0, 0)
- 371_Vitamins:
    ~ return cargo_db(data, Ceres, Luna,       5, "vitamin packs",            1, 0, 0, 0)
- 372_Mushrooms:
    ~ return cargo_db(data, Ceres, Luna,      10, "cave mushrooms",           0, 1, 0, 0)
- 373_Spirits:
    ~ return cargo_db(data, Ceres, Luna,      15, "belt spirits",             0, 0, 0, 0)
- 374_Whiskey:
    ~ return cargo_db(data, Ceres, Luna,      20, "belt whiskey",             0, 0, 0, 0)
- 375_Hops:
    ~ return cargo_db(data, Ceres, Luna,      10, "hydroponic hops",          0, 0, 0, 0)
- 376_Jerky:
    ~ return cargo_db(data, Ceres, Luna,      10, "vat jerky",                0, 0, 0, 0)
- 377_Soylent:
    ~ return cargo_db(data, Ceres, Earth,     10, "soylent bricks",           0, 0, 0, 0)
- 378_Seeds:
    ~ return cargo_db(data, Ceres, Earth,      5, "heirloom seeds",           0, 1, 0, 0)
- 379_Soil:
    ~ return cargo_db(data, Ceres, Earth,     30, "asteroid soil",            0, 0, 0, 0)
- 380_Fertilizer:
    ~ return cargo_db(data, Ceres, Earth,     20, "nitrogen fertilizer",      0, 0, 0, 0)
- 381_Compost:
    ~ return cargo_db(data, Ceres, Earth,     15, "worm compost",             0, 0, 0, 0)
- 382_Mulch:
    ~ return cargo_db(data, Ceres, Earth,     15, "regolith mulch",           0, 0, 0, 0)
- 383_Miners:
    ~ return cargo_db(data, Ceres, Earth,     10, "retired miners",           0, 0, 0, 1)
- 384_Medics:
    ~ return cargo_db(data, Ceres, Earth,     10, "field medics",             1, 0, 0, 0)
- 385_BulkIce:
    ~ return cargo_db(data, Ceres, Earth,     40, "bulk ice",                 0, 0, 0, 0)
- 386_Geodes:
    ~ return cargo_db(data, Ceres, Earth,     20, "split geodes",             0, 1, 1, 0)
- 387_Artifacts:
    ~ return cargo_db(data, Ceres, Earth,     15, "belt artifacts",           0, 1, 1, 0)
- 388_Meteorites:
    ~ return cargo_db(data, Ceres, Earth,     30, "meteorite chunks",         0, 0, 0, 0)
- 389_Antiques:
    ~ return cargo_db(data, Ceres, Earth,     20, "mining antiques",          0, 0, 0, 0)
- 390_Specimens:
    ~ return cargo_db(data, Ceres, Earth,     10, "pressed specimens",        0, 1, 0, 0)
- 391_Workers:
    ~ return cargo_db(data, Ceres, Titan,     10, "contract workers",         0, 0, 0, 1)
- 392_Engineers:
    ~ return cargo_db(data, Ceres, Titan,     15, "rig engineers",            0, 0, 0, 1)
- 393_MiningDrones:
    ~ return cargo_db(data, Ceres, Titan,     30, "mining drones",            0, 0, 0, 0)
- 394_Rovers:
    ~ return cargo_db(data, Ceres, Titan,     50, "survey rovers",            0, 0, 0, 0)
- 395_Scanners:
    ~ return cargo_db(data, Ceres, Titan,     20, "deep scanners",            0, 0, 0, 0)
- 396_CoreProbes:
    ~ return cargo_db(data, Ceres, Titan,     40, "core probes",              1, 0, 0, 0)
- 397_Charges:
    ~ return cargo_db(data, Ceres, Titan,     30, "shaped charges",           0, 0, 1, 0)
- 398_DrillAssembly:
    ~ return cargo_db(data, Ceres, Titan,     50, "drill assemblies",         1, 0, 0, 0)
- 399_Furnace:
    ~ return cargo_db(data, Ceres, Titan,     40, "blast furnace",            1, 0, 0, 0)
- 400_Trophies:
    ~ return cargo_db(data, Ceres, Titan,     30, "competition trophies",     0, 0, 0, 0)

// ── Ganymede (401–499) ────────────────────────────────────────────────────────
- 401_Protein:
    ~ return cargo_db(data, Ganymede, Ceres,  20, "synthetic protein",        0, 0, 0, 0)
- 402_Metals:
    ~ return cargo_db(data, Ganymede, Mars,   40, "industrial metals",        0, 0, 0, 0)
- 403_Samples:
    ~ return cargo_db(data, Ganymede, Earth,  10, "Europa samples",           0, 1, 0, 0)
- 404_Team:
    ~ return cargo_db(data, Ganymede, Ceres,  10, "research team",            0, 0, 0, 1) // TODO: transit events
- 405_IceCores:
    ~ return cargo_db(data, Ganymede, Titan,  20, "Europa ice cores",         0, 0, 0, 0)
- 406_Reagents:
    ~ return cargo_db(data, Ganymede, Titan,  10, "chemical reagents",        0, 0, 0, 0)
- 407_Telescopes:
    ~ return cargo_db(data, Ganymede, Titan,  15, "telescope mirrors",        0, 1, 0, 0)
- 408_Biofilm:
    ~ return cargo_db(data, Ganymede, Titan,  10, "biofilm slides",           0, 1, 0, 0)
- 409_Cryogenics:
    ~ return cargo_db(data, Ganymede, Titan,  20, "cryogenic dewars",         0, 0, 0, 0)
- 410_Sensors:
    ~ return cargo_db(data, Ganymede, Titan,  30, "magnetic sensor array",    0, 0, 0, 0)
- 411_Regolith:
    ~ return cargo_db(data, Ganymede, Titan,  30, "Callisto regolith",        0, 0, 0, 0)
- 412_GeneLib:
    ~ return cargo_db(data, Ganymede, Titan,  10, "gene library",             0, 1, 0, 0)
- 413_Sulfur:
    ~ return cargo_db(data, Ganymede, Titan,  15, "Io sulfur extract",        0, 0, 1, 0)
- 414_Antennas:
    ~ return cargo_db(data, Ganymede, Titan,  20, "antenna arrays",           0, 0, 0, 0)
- 415_Isotopes:
    ~ return cargo_db(data, Ganymede, Titan,   5, "stable isotopes",          1, 0, 0, 0)
- 416_Coolant:
    ~ return cargo_db(data, Ganymede, Titan,  30, "reactor coolant",          0, 0, 1, 0)
- 417_Optics:
    ~ return cargo_db(data, Ganymede, Titan,  10, "adaptive optics",          0, 1, 0, 0)
- 418_Cultures:
    ~ return cargo_db(data, Ganymede, Titan,  10, "protein cultures",         0, 1, 0, 0)
- 419_Polymers:
    ~ return cargo_db(data, Ganymede, Titan,  15, "conductive polymers",      0, 0, 0, 0)
- 420_Datatapes:
    ~ return cargo_db(data, Ganymede, Titan,  10, "archival datatapes",       0, 0, 0, 0)
- 421_Magnets:
    ~ return cargo_db(data, Ganymede, Titan,  40, "superconducting magnets",  0, 0, 0, 0)
- 422_Probes:
    ~ return cargo_db(data, Ganymede, Titan,  15, "atmospheric probes",       1, 0, 0, 0)
- 423_Filters:
    ~ return cargo_db(data, Ganymede, Titan,  40, "nanoscale filters",        0, 0, 0, 0)
- 424_Catalysts:
    ~ return cargo_db(data, Ganymede, Titan,  10, "platinum catalysts",       1, 0, 0, 0)
- 425_Algae:
    ~ return cargo_db(data, Ganymede, Titan,  20, "spirulina algae",          0, 0, 0, 0)
- 426_Titanium:
    ~ return cargo_db(data, Ganymede, Titan,  50, "titanium plate",           0, 0, 0, 0)
- 427_Graphene:
    ~ return cargo_db(data, Ganymede, Titan,  20, "graphene sheets",          0, 0, 0, 0)
- 428_Specimens:
    ~ return cargo_db(data, Ganymede, Titan,  15, "geological specimens",     0, 1, 0, 0)
- 429_Chassis:
    ~ return cargo_db(data, Ganymede, Titan,  40, "rover chassis",            0, 0, 0, 0)
- 430_Flywheel:
    ~ return cargo_db(data, Ganymede, Titan,  50, "flywheel battery",         0, 0, 0, 0)
- 431_Drones:
    ~ return cargo_db(data, Ganymede, Titan,  30, "survey drones",            0, 0, 0, 0)
- 432_Spectrometer:
    ~ return cargo_db(data, Ganymede, Titan,  20, "spectrometer array",       0, 1, 0, 0)
- 433_Plankton:
    ~ return cargo_db(data, Ganymede, Titan,  30, "bioluminescent plankton",  1, 0, 0, 0)
- 434_Pipettes:
    ~ return cargo_db(data, Ganymede, Ceres,   5, "precision pipettes",       0, 1, 0, 0)
- 435_Centrifuge:
    ~ return cargo_db(data, Ganymede, Ceres,  30, "centrifuge rotor",         0, 0, 0, 0)
- 436_Bacteria:
    ~ return cargo_db(data, Ganymede, Ceres,  10, "engineered bacteria",      0, 0, 1, 0)
- 437_Lenses:
    ~ return cargo_db(data, Ganymede, Ceres,  10, "spectrometer lenses",      0, 1, 0, 0)
- 438_Fiber:
    ~ return cargo_db(data, Ganymede, Ceres,  15, "optical fiber",            0, 0, 0, 0)
- 439_Helium:
    ~ return cargo_db(data, Ganymede, Ceres,  20, "liquid helium",            0, 0, 1, 0)
- 440_Germanium:
    ~ return cargo_db(data, Ganymede, Ceres,  20, "germanium ingots",         0, 0, 0, 0)
- 441_Circuits:
    ~ return cargo_db(data, Ganymede, Ceres,  10, "printed circuits",         0, 0, 0, 0)
- 442_Primers:
    ~ return cargo_db(data, Ganymede, Ceres,   5, "PCR primers",              1, 0, 0, 0)
- 443_Membranes:
    ~ return cargo_db(data, Ganymede, Ceres,  15, "osmotic membranes",        0, 0, 0, 0)
- 444_Enzymes:
    ~ return cargo_db(data, Ganymede, Ceres,  10, "restriction enzymes",      0, 1, 0, 0)
- 445_Actuators:
    ~ return cargo_db(data, Ganymede, Ceres,  20, "linear actuators",         0, 0, 0, 0)
- 446_Sealant:
    ~ return cargo_db(data, Ganymede, Ceres,  15, "vacuum sealant",           0, 0, 0, 0)
- 447_Gaskets:
    ~ return cargo_db(data, Ganymede, Ceres,  30, "pressure gaskets",         0, 0, 0, 0)
- 448_Wafers:
    ~ return cargo_db(data, Ganymede, Ceres,   5, "silicon wafers",           0, 1, 0, 0)
- 449_Feedstock:
    ~ return cargo_db(data, Ganymede, Ceres,  40, "printer feedstock",        0, 0, 0, 0)
- 450_Tubing:
    ~ return cargo_db(data, Ganymede, Ceres,  20, "silicone tubing",          0, 0, 0, 0)
- 451_Insulators:
    ~ return cargo_db(data, Ganymede, Ceres,  15, "thermal insulators",       0, 0, 0, 0)
- 452_Radiators:
    ~ return cargo_db(data, Ganymede, Ceres,  30, "heat radiators",           0, 0, 0, 0)
- 453_Scrubbers:
    ~ return cargo_db(data, Ganymede, Ceres,  50, "CO2 scrubbers",            0, 0, 0, 0)
- 454_Drills:
    ~ return cargo_db(data, Ganymede, Ceres,  40, "core drill bits",          0, 0, 0, 0)
- 455_Bolts:
    ~ return cargo_db(data, Ganymede, Ceres,  15, "titanium bolts",           0, 0, 0, 0)
- 456_Adhesive:
    ~ return cargo_db(data, Ganymede, Ceres,  10, "cryogenic adhesive",       1, 0, 1, 0)
- 457_Pellets:
    ~ return cargo_db(data, Ganymede, Mars,   20, "fuel pellets",             0, 0, 1, 0)
- 458_Precursors:
    ~ return cargo_db(data, Ganymede, Mars,   15, "pharmaceutical precursors",1, 0, 0, 0)
- 459_Detectors:
    ~ return cargo_db(data, Ganymede, Mars,   10, "particle detectors",       0, 1, 0, 0)
- 460_Winches:
    ~ return cargo_db(data, Ganymede, Mars,   30, "tether winches",           0, 0, 0, 0)
- 461_Bearings:
    ~ return cargo_db(data, Ganymede, Mars,   15, "ceramic bearings",         0, 0, 0, 0)
- 462_Valves:
    ~ return cargo_db(data, Ganymede, Mars,   10, "cryogenic valves",         0, 0, 0, 0)
- 463_Capacitors:
    ~ return cargo_db(data, Ganymede, Mars,    5, "supercapacitors",          0, 0, 0, 0)
- 464_Thermite:
    ~ return cargo_db(data, Ganymede, Mars,   10, "thermite charges",         0, 0, 1, 0)
- 465_Crucibles:
    ~ return cargo_db(data, Ganymede, Mars,   20, "iridium crucibles",        0, 0, 0, 0)
- 466_Resins:
    ~ return cargo_db(data, Ganymede, Mars,   30, "epoxy resins",             0, 0, 0, 0)
- 467_Grease:
    ~ return cargo_db(data, Ganymede, Mars,   15, "vacuum grease",            0, 0, 0, 0)
- 468_Spores:
    ~ return cargo_db(data, Ganymede, Mars,    5, "mycorrhizal spores",       0, 0, 0, 0)
- 469_Yeasts:
    ~ return cargo_db(data, Ganymede, Mars,   10, "engineered yeasts",        0, 0, 0, 0)
- 470_Stem:
    ~ return cargo_db(data, Ganymede, Mars,   10, "stem cell vials",          1, 0, 0, 0)
- 471_Vaccines:
    ~ return cargo_db(data, Ganymede, Mars,   15, "lyophilized vaccines",     1, 0, 0, 0)
- 472_Antivenom:
    ~ return cargo_db(data, Ganymede, Mars,    5, "synthetic antivenom",      1, 0, 0, 0)
- 473_Serums:
    ~ return cargo_db(data, Ganymede, Mars,   20, "diagnostic serums",        0, 0, 0, 0)
- 474_Plasma:
    ~ return cargo_db(data, Ganymede, Mars,   20, "blood plasma",             1, 0, 1, 0)
- 475_Xenon:
    ~ return cargo_db(data, Ganymede, Mars,   15, "xenon gas cylinders",      0, 0, 0, 0)
- 476_Cartilage:
    ~ return cargo_db(data, Ganymede, Luna,   10, "synthetic cartilage",      0, 0, 0, 0)
- 477_Marrow:
    ~ return cargo_db(data, Ganymede, Luna,   15, "bone marrow cultures",     0, 1, 0, 0)
- 478_Tissue:
    ~ return cargo_db(data, Ganymede, Luna,   10, "tissue scaffolds",         0, 0, 0, 0)
- 479_Embryos:
    ~ return cargo_db(data, Ganymede, Luna,   15, "frozen embryos",           0, 0, 0, 0)
- 480_Seedlings:
    ~ return cargo_db(data, Ganymede, Luna,   10, "hydroponic seedlings",     0, 0, 0, 0)
- 481_Mycelia:
    ~ return cargo_db(data, Ganymede, Luna,   20, "mycelia blocks",           0, 0, 0, 0)
- 482_Lichens:
    ~ return cargo_db(data, Ganymede, Luna,   20, "radiation-tolerant lichen",0, 0, 0, 0)
- 483_Diatoms:
    ~ return cargo_db(data, Ganymede, Luna,   30, "diatom cultures",          0, 0, 0, 0)
- 484_Coral:
    ~ return cargo_db(data, Ganymede, Luna,   20, "coral fragments",          0, 0, 0, 0)
- 485_Krill:
    ~ return cargo_db(data, Ganymede, Luna,   40, "freeze-dried krill",       0, 0, 0, 0)
- 486_Larvae:
    ~ return cargo_db(data, Ganymede, Luna,    5, "insect larvae",            0, 0, 0, 0)
- 487_Interns:
    ~ return cargo_db(data, Ganymede, Luna,   10, "summer interns",           0, 0, 0, 1)
- 488_Lecturers:
    ~ return cargo_db(data, Ganymede, Luna,   30, "visiting lecturers",       0, 0, 0, 1)
- 489_RadioSamples:
    ~ return cargo_db(data, Ganymede, Luna,   10, "radioactive samples",      0, 1, 1, 0)
- 490_Silkworms:
    ~ return cargo_db(data, Ganymede, Luna,   15, "silkworm cocoons",         1, 0, 0, 0)
- 491_Archivists:
    ~ return cargo_db(data, Ganymede, Earth,   5, "data archivists",          0, 0, 0, 0)
- 492_Journals:
    ~ return cargo_db(data, Ganymede, Earth,   5, "research journals",        0, 0, 0, 0)
- 493_Fossils:
    ~ return cargo_db(data, Ganymede, Earth,  30, "subsurface fossils",       0, 0, 0, 0)
- 494_Meteorites:
    ~ return cargo_db(data, Ganymede, Earth,  40, "tagged meteorites",        0, 0, 0, 0)
- 495_Prisms:
    ~ return cargo_db(data, Ganymede, Earth,  15, "calibration prisms",       1, 0, 0, 0)
- 496_Gratings:
    ~ return cargo_db(data, Ganymede, Earth,  15, "diffraction gratings",     0, 0, 0, 0)
- 497_Cuvettes:
    ~ return cargo_db(data, Ganymede, Earth,  20, "quartz cuvettes",          0, 0, 0, 0)
- 498_Pipework:
    ~ return cargo_db(data, Ganymede, Earth,  50, "hab pipework",             0, 0, 0, 0)
- 499_Cylinders:
    ~ return cargo_db(data, Ganymede, Earth,  20, "pressurized cylinders",    0, 0, 0, 0)

// ── Titan (501–600) ───────────────────────────────────────────────────────────
- 501_Methane:
    ~ return cargo_db(data, Titan, Ganymede,  40, "liquid methane",           0, 0, 1, 0)
- 502_Polymers:
    ~ return cargo_db(data, Titan, Ceres,     20, "exotic polymers",          0, 0, 0, 0)
- 503_Samples:
    ~ return cargo_db(data, Titan, Mars,      10, "atmosphere samples",       0, 1, 0, 0)
- 504_Survey:
    ~ return cargo_db(data, Titan, Ganymede,  10, "survey team",              0, 0, 0, 1) // TODO: transit events
- 505_Ethane:
    ~ return cargo_db(data, Titan, Ganymede,  30, "ethane drums",             0, 0, 1, 0)
- 506_Propane:
    ~ return cargo_db(data, Titan, Ganymede,  40, "propane tanks",            0, 0, 1, 0)
- 507_Tholin:
    ~ return cargo_db(data, Titan, Ganymede,  15, "tholin extract",           0, 0, 0, 0)
- 508_Butane:
    ~ return cargo_db(data, Titan, Ganymede,  20, "butane canisters",         0, 0, 1, 0)
- 509_Acetylene:
    ~ return cargo_db(data, Titan, Ganymede,  10, "acetylene torches",        1, 0, 1, 0)
- 510_Benzene:
    ~ return cargo_db(data, Titan, Ganymede,  15, "benzene solvent",          1, 0, 0, 0)
- 511_Cyanide:
    ~ return cargo_db(data, Titan, Ganymede,   5, "hydrogen cyanide",         0, 1, 1, 0)
- 512_Ammonia:
    ~ return cargo_db(data, Titan, Ganymede,  20, "ammonia ice",              0, 0, 0, 0)
- 513_Nitrogen:
    ~ return cargo_db(data, Titan, Ganymede,  30, "liquid nitrogen",          0, 0, 0, 0)
- 514_Slurry:
    ~ return cargo_db(data, Titan, Ganymede,  40, "hydrocarbon slurry",       0, 0, 0, 0)
- 515_Bitumen:
    ~ return cargo_db(data, Titan, Ganymede,  50, "raw bitumen",              0, 0, 0, 0)
- 516_Wax:
    ~ return cargo_db(data, Titan, Ganymede,  10, "paraffin wax",             0, 0, 0, 0)
- 517_Resin:
    ~ return cargo_db(data, Titan, Ganymede,  15, "cryogenic resin",          0, 0, 0, 0)
- 518_Sealant:
    ~ return cargo_db(data, Titan, Ganymede,  10, "hull sealant",             0, 0, 0, 0)
- 519_Grease:
    ~ return cargo_db(data, Titan, Ganymede,  20, "bearing grease",           0, 0, 0, 0)
- 520_Coolant:
    ~ return cargo_db(data, Titan, Ganymede,  15, "reactor coolant",          0, 0, 0, 0)
- 521_Antifreeze:
    ~ return cargo_db(data, Titan, Ganymede,  10, "antifreeze concentrate",   1, 0, 0, 0)
- 522_Insulation:
    ~ return cargo_db(data, Titan, Ganymede,  20, "thermal insulation",       0, 0, 0, 0)
- 523_Cryogel:
    ~ return cargo_db(data, Titan, Ganymede,  10, "cryogel sheets",           0, 1, 0, 0)
- 524_Aerogel:
    ~ return cargo_db(data, Titan, Ganymede,   5, "aerogel blankets",         0, 1, 0, 0)
- 525_Regolith:
    ~ return cargo_db(data, Titan, Ganymede,  30, "processed regolith",       0, 0, 0, 0)
- 526_Pebbles:
    ~ return cargo_db(data, Titan, Ganymede,  20, "Hyperion pebbles",         0, 0, 0, 0)
- 527_Dust:
    ~ return cargo_db(data, Titan, Ganymede,  15, "ring particle dust",       0, 0, 0, 0)
- 528_Silt:
    ~ return cargo_db(data, Titan, Ganymede,  10, "lakebed silt",             0, 0, 0, 0)
- 529_Sediment:
    ~ return cargo_db(data, Titan, Ganymede,  15, "Kraken Mare sediment",     0, 0, 0, 0)
- 530_Cores:
    ~ return cargo_db(data, Titan, Ganymede,  30, "ice shelf cores",          0, 0, 0, 0)
- 531_Fossils:
    ~ return cargo_db(data, Titan, Ganymede,   5, "microbe fossils",          0, 1, 0, 0)
- 532_Microbes:
    ~ return cargo_db(data, Titan, Ganymede,  10, "live microbe cultures",    0, 1, 1, 0)
- 533_Enzymes:
    ~ return cargo_db(data, Titan, Ceres,      5, "cold-adapted enzymes",     0, 0, 0, 0)
- 534_Cultures:
    ~ return cargo_db(data, Titan, Ceres,     10, "cryophile cultures",       0, 1, 0, 0)
- 535_Spores:
    ~ return cargo_db(data, Titan, Ceres,      5, "engineered spores",        0, 0, 1, 0)
- 536_Settlers:
    ~ return cargo_db(data, Titan, Ceres,     15, "frontier settlers",        0, 0, 0, 1)
- 537_Miners:
    ~ return cargo_db(data, Titan, Ceres,     15, "ice miners",               0, 0, 0, 1)
- 538_Engineers:
    ~ return cargo_db(data, Titan, Ceres,     10, "hab engineers",            0, 0, 0, 1)
- 539_Medics:
    ~ return cargo_db(data, Titan, Ceres,     10, "field medics",             0, 0, 0, 1)
- 540_Geologists:
    ~ return cargo_db(data, Titan, Ceres,     20, "geologists with samples",  0, 0, 0, 1)
- 541_Welders:
    ~ return cargo_db(data, Titan, Ceres,     15, "orbital welders",          0, 0, 0, 1)
- 542_Techs:
    ~ return cargo_db(data, Titan, Ceres,     10, "replacement techs",        1, 0, 0, 0)
- 543_Suits:
    ~ return cargo_db(data, Titan, Ceres,     20, "pressure suits",           0, 0, 0, 0)
- 544_Helmets:
    ~ return cargo_db(data, Titan, Ceres,     10, "insulated helmets",        0, 0, 0, 0)
- 545_Boots:
    ~ return cargo_db(data, Titan, Ceres,      5, "mag-lock boots",           0, 0, 0, 0)
- 546_Gloves:
    ~ return cargo_db(data, Titan, Ceres,      5, "heated gloves",            0, 0, 0, 0)
- 547_Heaters:
    ~ return cargo_db(data, Titan, Ceres,     20, "portable heaters",         0, 0, 0, 0)
- 548_Lamps:
    ~ return cargo_db(data, Titan, Ceres,     10, "UV grow lamps",            0, 0, 0, 0)
- 549_Drills:
    ~ return cargo_db(data, Titan, Ceres,     30, "core drills",              0, 0, 0, 0)
- 550_Cutters:
    ~ return cargo_db(data, Titan, Ceres,     15, "plasma cutters",           1, 0, 0, 0)
- 551_Winches:
    ~ return cargo_db(data, Titan, Ceres,     30, "cargo winches",            0, 0, 0, 0)
- 552_Cables:
    ~ return cargo_db(data, Titan, Ceres,     20, "tether cables",            0, 0, 0, 0)
- 553_Pipe:
    ~ return cargo_db(data, Titan, Ceres,     40, "insulated pipe",           0, 0, 0, 0)
- 554_Valves:
    ~ return cargo_db(data, Titan, Ceres,     15, "pressure valves",          0, 0, 0, 0)
- 555_Pumps:
    ~ return cargo_db(data, Titan, Ceres,     30, "cryogenic pumps",          0, 0, 0, 0)
- 556_Filters:
    ~ return cargo_db(data, Titan, Ceres,     15, "atmo filters",             0, 0, 0, 0)
- 557_Sensors:
    ~ return cargo_db(data, Titan, Mars,      10, "methane sensors",          1, 0, 0, 0)
- 558_Probes:
    ~ return cargo_db(data, Titan, Mars,      15, "surface probes",           0, 0, 0, 0)
- 559_Drones:
    ~ return cargo_db(data, Titan, Mars,      20, "survey drones",            1, 0, 0, 0)
- 560_Beacons:
    ~ return cargo_db(data, Titan, Mars,      10, "nav beacons",              0, 0, 0, 0)
- 561_Radios:
    ~ return cargo_db(data, Titan, Mars,      10, "deep-space radios",        0, 0, 0, 0)
- 562_Relays:
    ~ return cargo_db(data, Titan, Mars,      15, "comms relays",             0, 0, 0, 0)
- 563_Panels:
    ~ return cargo_db(data, Titan, Mars,      20, "solar panels",             0, 0, 0, 0)
- 564_Batteries:
    ~ return cargo_db(data, Titan, Mars,      20, "solid-state batteries",    0, 1, 0, 0)
- 565_Cells:
    ~ return cargo_db(data, Titan, Mars,      15, "fuel cells",               0, 0, 0, 0)
- 566_Coils:
    ~ return cargo_db(data, Titan, Mars,      20, "superconductor coils",     0, 0, 0, 0)
- 567_Magnets:
    ~ return cargo_db(data, Titan, Mars,      30, "shielding magnets",        0, 0, 0, 0)
- 568_Mirrors:
    ~ return cargo_db(data, Titan, Mars,      10, "telescope mirrors",        0, 1, 0, 0)
- 569_Lenses:
    ~ return cargo_db(data, Titan, Mars,       5, "optical lenses",           0, 1, 0, 0)
- 570_Optics:
    ~ return cargo_db(data, Titan, Mars,      10, "fiber optics",             1, 0, 0, 0)
- 571_Chips:
    ~ return cargo_db(data, Titan, Mars,       5, "rad-hard chips",           1, 0, 0, 0)
- 572_Boards:
    ~ return cargo_db(data, Titan, Mars,      15, "circuit boards",           0, 0, 0, 0)
- 573_Drives:
    ~ return cargo_db(data, Titan, Mars,      20, "data drives",              0, 0, 0, 0)
- 574_Servos:
    ~ return cargo_db(data, Titan, Mars,      15, "micro servos",             0, 0, 0, 0)
- 575_Gaskets:
    ~ return cargo_db(data, Titan, Mars,      10, "silicone gaskets",         0, 0, 0, 0)
- 576_Bolts:
    ~ return cargo_db(data, Titan, Luna,      20, "titanium bolts",           0, 0, 0, 0)
- 577_Rivets:
    ~ return cargo_db(data, Titan, Luna,      10, "blind rivets",             0, 0, 0, 0)
- 578_Plating:
    ~ return cargo_db(data, Titan, Luna,      40, "hull plating",             0, 0, 0, 0)
- 579_Mesh:
    ~ return cargo_db(data, Titan, Luna,      30, "radiation mesh",           0, 0, 0, 0)
- 580_Foam:
    ~ return cargo_db(data, Titan, Luna,      15, "expanding foam",           0, 0, 0, 0)
- 581_Tape:
    ~ return cargo_db(data, Titan, Luna,       5, "vacuum tape",              0, 0, 0, 0)
- 582_Adhesive:
    ~ return cargo_db(data, Titan, Luna,      10, "industrial adhesive",      0, 0, 1, 0)
- 583_Whiskey:
    ~ return cargo_db(data, Titan, Luna,      20, "frontier whiskey",         1, 0, 0, 0)
- 584_Brandy:
    ~ return cargo_db(data, Titan, Luna,      15, "methane brandy",           0, 0, 0, 0)
- 585_Rations:
    ~ return cargo_db(data, Titan, Luna,      30, "freeze-dried rations",     0, 0, 0, 0)
- 586_Seeds:
    ~ return cargo_db(data, Titan, Luna,      10, "cold-hardy seeds",         0, 0, 0, 0)
- 587_Fertilizer:
    ~ return cargo_db(data, Titan, Luna,      30, "nitrogen fertilizer",      0, 0, 1, 0)
- 588_Mulch:
    ~ return cargo_db(data, Titan, Luna,      20, "organic mulch",            0, 0, 0, 0)
- 589_Pellets:
    ~ return cargo_db(data, Titan, Luna,      40, "fuel pellets",             0, 0, 0, 0)
- 590_Brine:
    ~ return cargo_db(data, Titan, Luna,      50, "Enceladus brine",          0, 0, 0, 0)
- 591_Crystals:
    ~ return cargo_db(data, Titan, Earth,     10, "exotic crystals",          1, 0, 1, 0)
- 592_Pigment:
    ~ return cargo_db(data, Titan, Earth,     15, "tholin pigment",           0, 0, 0, 0)
- 593_Dye:
    ~ return cargo_db(data, Titan, Earth,     20, "organic dye",              0, 0, 0, 0)
- 594_Catalysts:
    ~ return cargo_db(data, Titan, Earth,     30, "platinum catalysts",       1, 0, 1, 0)
- 595_Reagents:
    ~ return cargo_db(data, Titan, Earth,     40, "chemical reagents",        0, 0, 1, 0)
- 596_Isotopes:
    ~ return cargo_db(data, Titan, Earth,     50, "radioactive isotopes",     0, 0, 1, 0)
- 597_Deuterium:
    ~ return cargo_db(data, Titan, Earth,     40, "heavy water",              0, 0, 0, 0)
- 598_Graphene:
    ~ return cargo_db(data, Titan, Earth,     30, "graphene rolls",           1, 0, 0, 0)
- 599_Silicone:
    ~ return cargo_db(data, Titan, Earth,     50, "silicone stock",           0, 0, 0, 0)
- 600_Solvents:
    ~ return cargo_db(data, Titan, Earth,     20, "industrial solvents",      0, 0, 0, 0)

- else:
    [ Error: no data associated with {id}. ]
}

/*

    Cargo Database Row
    Returns the requested stat for a single cargo entry.

*/
=== function cargo_db(data, fromData, toData, massData, titleData, isExpress, isFragile, isHazardous, isPassengers)
{ data:
- From:       ~ return fromData
- To:         ~ return toData
- Mass:       ~ return massData
- Title:      ~ return titleData
- Express:    ~ return isExpress
- Fragile:    ~ return isFragile
- Hazardous:  ~ return isHazardous
- Passengers: ~ return isPassengers
}

/*

    Computed Cargo Pay

    base_pay = FLOOR(mass × distance × PayRate)
    Each flag (Express, Fragile, Hazardous, Passengers) adds +50% of base_pay.

*/
=== function get_cargo_pay(cargo, distance)
~ temp mass = CargoData(cargo, Mass)
~ temp base_pay = FLOOR(mass * distance * PayRate)
~ temp total = base_pay
{ CargoData(cargo, Express):
    ~ total = total + base_pay / 2
}
{ CargoData(cargo, Fragile):
    ~ total = total + base_pay / 2
}
{ CargoData(cargo, Hazardous):
    ~ total = total + base_pay / 2
}
{ CargoData(cargo, Passengers):
    ~ total = total + base_pay / 2
}
~ return total

/*

    Cargo Helper Functions (used by port.ink departure checks)

*/

/*

    Returns true if any cargo in the hold is Express.

*/
=== function cargo_has_express(items)
~ temp item = pop(items)
{ item:
    { CargoData(item, Express):
        ~ return true
    }
    ~ return cargo_has_express(items)
}
~ return false

/*

    Returns the single Express destination if all Express cargo shares one destination,
    or None if there is no Express cargo, or if Express cargo exists for multiple destinations.

*/
=== function cargo_express_destination(items)
~ return _cargo_express_destination_r(items, None)

/*

    Internal recursive helper for cargo_express_destination.

*/
=== function _cargo_express_destination_r(items, found)
~ temp item = pop(items)
{ item:
    { CargoData(item, Express):
        { found == None:
            ~ return _cargo_express_destination_r(items, CargoData(item, To))
        - else:
            { found != CargoData(item, To):
                ~ return None // conflict: Express cargo bound for multiple destinations
            }
        }
    }
    ~ return _cargo_express_destination_r(items, found)
}
~ return found

/*

    Returns true if the hold contains both Hazardous and non-Hazardous cargo.

*/
=== function cargo_is_mixed_hazardous(items)
~ return _cargo_is_mixed_hazardous_r(items, false, false)

/*

    Internal recursive helper for cargo_is_mixed_hazardous.

*/
=== function _cargo_is_mixed_hazardous_r(items, has_hazardous, has_clean)
~ temp item = pop(items)
{ item:
    { CargoData(item, Hazardous):
        ~ return _cargo_is_mixed_hazardous_r(items, true, has_clean)
    - else:
        ~ return _cargo_is_mixed_hazardous_r(items, has_hazardous, true)
    }
}
~ return has_hazardous and has_clean

/*

    Returns true if any cargo in the hold blocks Turbo mode (Fragile or Passengers).

*/
=== function cargo_blocks_turbo(items)
~ temp item = pop(items)
{ item:
    { CargoData(item, Fragile) or CargoData(item, Passengers):
        ~ return true
    }
    ~ return cargo_blocks_turbo(items)
}
~ return false

/*

    Gets a randomized selection of cargo from the specified port.
    Express cargo is filtered out if the destination is unreachable in Turbo
    at the player's current engine tier.

*/
=== function get_available_cargo(port, count)
~ temp _cargo = AllCargo
~ return validated_list_random_subset_of_size(_cargo, -> cargo_is_available, port, count)

/*

    Check if a piece of cargo is available at the given port.
    Cargo must originate from this port. Express cargo is only shown
    if the player can afford Turbo to the destination.

*/
=== function cargo_is_available(cargo, port)
~ temp from = CargoData(cargo, From)
{ from != port:
    ~ return false
}
// Filter out cargo the player can't physically carry to its destination
~ temp trip_mass = CargoData(cargo, Mass) + 5
~ temp eco_fuel = EngineData(ShipManufacturer, ShipEngineTier, EcoFuel)
~ temp trip_cost = FLOOR(get_distance(here, CargoData(cargo, To)) * trip_mass * eco_fuel)
{ trip_cost > ShipFuelCapacity:
    ~ return false
}
{ CargoData(cargo, Express):
    ~ return can_turbo_to(CargoData(cargo, To))
}
~ return true

/*

    Returns true if the player's ship can reach the given destination at Turbo speed
    within its current fuel capacity.

*/
=== function can_turbo_to(destination)
~ temp turbo_fuel = EngineData(ShipManufacturer, ShipEngineTier, TurboFuel)
~ return get_trip_fuel_cost(here, destination, turbo_fuel) <= ShipFuelCapacity

/*

    Returns the total mass of a list of items.

*/
=== function total_mass(items)
~ temp item = pop(items)
{ item:
    ~ return CargoData(item, Mass) + total_mass(items)
}
~ return 0

/*

    Count Paperwork Chunks
    Hybrid model: 1 base flight log chunk + 1 extra per cargo item
    that has any special flag (Express, Hazardous, or Passengers).
    A cargo item with multiple flags still only adds 1 chunk.

*/
=== function count_paperwork_chunks(items)
~ return 1 + _count_flagged_cargo(items)

=== function _count_flagged_cargo(items)
~ temp item = pop(items)
{ item:
    { CargoData(item, Express) or CargoData(item, Hazardous) or CargoData(item, Passengers):
        ~ return 1 + _count_flagged_cargo(items)
    - else:
        ~ return _count_flagged_cargo(items)
    }
}
~ return 0
