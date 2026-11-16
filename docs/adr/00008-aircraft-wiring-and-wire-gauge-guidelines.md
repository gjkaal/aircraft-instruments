# 00008. Aircraft Wiring and Wire Gauge Guidelines

2026-11-16

## Status

__New__

## Context

The engine monitor (ADR-0002) connects to engine sensors (EGT/CHT thermocouples,
NTC thermistors, RPM pickup), to aircraft power, and to other avionics over
CAN-Bus (ADR-0004). It shares the airframe with radio equipment (VHF comm,
transponder) whose wiring runs in the same panel and often in the same bundles.

Task 00023 (user documentation) calls for wiring diagrams, but the repository
had no rules for wire type, gauge, shielding or routing. Without them every
installer makes different choices, and wiring faults (voltage drop, chafing,
EMI from ignition and transmitters, thermocouple errors from wrong extension
wire) turn up as "sensor" or "software" bugs.

Constraints and assumptions:
- Target aircraft are experimental / non-type-certified (homebuilt, microlight,
  LSA). Certified installations must follow the TC holder's and equipment
  manufacturer's approved data; this ADR does not replace that.
- Electrical system is nominally 14 V DC (12 V battery). 28 V systems are
  covered by the same method with the 28 V limits from table 11-6.
- Engines in scope: Rotax 912/914 family (single-terminal resistive temperature
  senders, dedicated rev-counter pickup) and Lycoming/Continental style engines
  (magnetos with P-leads, K-type EGT/CHT probes).
- Engine-bay wiring sees heat, vibration, fuel/oil exposure and strong EMI from
  ignition. Panel wiring sees RF from the VHF and transponder transmitters.

### Sources consulted

- FAA AC 43.13-1B CHG 1, chapter 11 (Aircraft Electrical Systems) - the
  baseline for acceptable practice. Values below are taken from the published
  text: table 11-6 (allowable voltage drop), table 11-9 (current capacity and
  resistance), par. 11-66/11-67 (minimum size, strand count), 11-105 (system
  separation), 11-117 (bend radii), 11-118 (slack, drip loops), 11-124 (heat and
  fluid line separation), splice rules (11-160 range).
- ModAir - Modular Aviation Instruments (open-source CAN-based avionics for
  microlights): https://github.com/rbroich/modair and
  https://hackaday.io/project/19325-modair-modular-aviation-instruments .
  Relevant findings: CAN chosen as system bus for robustness and arbitration,
  120 ohm termination at each end of the bus, MAX6675 cold-junction-compensated
  K-type converters for EGT, NTC thermistor for coolant temperature, and the
  "Lesson Learnt: Shielding" log - noise problems were fixed by re-wiring with
  shielded cable with the shield grounded at ONE end only.
- ModAir Rotax 582 engine interface module: https://hackaday.io/project/21324
  (RPM, 2x EGT, NTC water temperature, MCP2562FD CAN transceiver).
- Garmin GTX-series transponder installation manuals: MIL-W-22759/16 wire,
  AWG 24 minimum for interface wiring, AWG 18/16 may be needed for power;
  M17/128 (RG-400) coax; complete antenna cable max 1.5 dB loss at 1 GHz.
- Garmin G3X installation manual, EGT section: only type-K extension wire,
  equal length positive and negative leads.
- J.P. Instruments EGT-701 manual / FAQ: never splice thermocouple wire with
  copper; tach and fuel flow leads may be extended with copper.
- ISO 11898-2 (CAN high-speed physical layer) and avionics CAN installation
  practice (Garmin G3X CAN stub limit of 1 ft in current manuals, per builder
  reports - verify against the installed equipment's manual).

## Decision

We adopt the following wiring guidelines for all engine monitor installations
and document them in the installation manual (task 00023). Where an equipment
manufacturer's installation manual is stricter or different, the manufacturer
wins for that equipment's wiring.

### 1. Wire type

| Use                         | Wire                                              |
| --------------------------- | ------------------------------------------------- |
| General hook-up, power      | MIL-W-22759/16 (Tefzel, tin-plated copper, 150 C) |
| Lightweight panel wiring    | MIL-W-22759/32 or /34 (cross-linked ETFE)         |
| Shielded signal / data      | M27500 jacketed cable built from 22759/16 or /32  |
| CAN-Bus                     | M27500 shielded twisted pair, 22 or 24 AWG, or a  |
|                             | dedicated 120 ohm CAN cable rated >= 150 C        |
| Thermocouple extension      | Type K (chromel/alumel) extension wire, 20 AWG,   |
|                             | high-temperature insulation (glass/PTFE)          |
| RF (VHF, transponder)       | M17/128 (RG-400) double-shielded, stranded center |

Not allowed: PVC-insulated wire (toxic smoke, low temperature rating), solid
conductor wire, any wire with fewer than 19 strands (AC 43.13 11-66a), solid
center coax (11-120), automotive wire in the engine bay.

### 2. Gauge selection method

Two checks; the larger resulting gauge wins.

1. **Current capacity** - table 11-9 (bundled, 70 C ambient), using the
   insulation's temperature rating:

   | AWG | 105 C ins. | 150 C ins. | 200 C ins. | ohm/1000 ft |
   | --- | ---------- | ---------- | ---------- | ----------- |
   | 24  | 2.5 A      | 4 A        | 5 A        | 28.4        |
   | 22  | 3 A        | 5 A        | 6 A        | 16.2        |
   | 20  | 4 A        | 7 A        | 9 A        | 9.88        |
   | 18  | 6 A        | 9 A        | 12 A       | 6.23        |
   | 16  | 7 A        | 11 A       | 14 A       | 4.81        |
   | 14  | 10 A       | 14 A       | 18 A       | 3.06        |
   | 12  | 13 A       | 19 A       | 25 A       | 2.02        |
   | 10  | 17 A       | 26 A       | 32 A       | 1.26        |

   These are conservative (33+ wires per bundle, 60,000 ft). For smaller
   bundles use the derating curves (AC 43.13 figures 11-4a, 11-5, 11-6).

2. **Voltage drop** - table 11-6, bus to equipment ground:

   | System | Continuous | Intermittent (<= 2 min) |
   | ------ | ---------- | ----------------------- |
   | 14 V   | 0.5 V      | 1 V                     |
   | 28 V   | 1 V        | 2 V                     |

   Maximum total conductor length (feet, supply + return if the return is a
   wire) for 0.5 V drop at 20 C, from table 11-9 resistance:

   | AWG | 1 A | 2 A | 3 A | 5 A | 7 A | 10 A | 15 A |
   | --- | --- | --- | --- | --- | --- | ---- | ---- |
   | 24  | 18  | 9   | 6   | 4   | -   | -    | -    |
   | 22  | 31  | 15  | 10  | 6   | -   | -    | -    |
   | 20  | 51  | 25  | 17  | 10  | 7   | -    | -    |
   | 18  | 80  | 40  | 27  | 16  | 11  | 8    | -    |
   | 16  | 104 | 52  | 35  | 21  | 15  | 10   | -    |
   | 14  | 163 | 82  | 54  | 33  | 23  | 16   | 11   |
   | 12  | 248 | 124 | 83  | 50  | 35  | 25   | 17   |
   | 10  | 397 | 198 | 132 | 79  | 57  | 40   | 26   |

   "-" = exceeds the 150 C bundle current rating for that gauge.
   Formula: L_ft = V_drop * 1000 / (I * R_per_1000ft). Wire resistance rises
   ~0.4 %/C, so allow margin for hot engine-bay runs.

3. **Mechanical minimum** - AWG 22 is the smallest gauge used in this project.
   AWG 24 only inside the panel, only in high-strength alloy, and only where the
   connected equipment manual specifies it (AC 43.13 11-67a). Wires smaller than
   AWG 20 get extra clamping, are grouped with at least three other wires and
   get strain relief at terminations (11-66a). In the engine bay use AWG 20 or
   larger except for thermocouple and shielded sensor cable.

4. **Circuit protection** - every power wire is protected at the bus by a fuse
   or breaker sized to protect the *wire*, not the load. The wire must carry the
   protection device's rating continuously.

### 3. Recommended gauges per circuit (14 V, typical light aircraft runs)

Indicative values. Always check against the method above and the equipment
installation manual.

| Circuit                                  | Gauge          | Notes |
| ---------------------------------------- | -------------- | ----- |
| Engine monitor (Pi + CAN HAT) power      | 20 AWG         | 3 A fuse/breaker; < 1 A typical draw. Separate ground wire to panel ground bus |
| CAN-Bus data                             | 22-24 AWG STP  | See section 4 |
| VHF comm power                           | 18-20 AWG      | Transmit draw several amps; size for TX current, per manual |
| VHF comm / transponder antenna           | RG-400         | Keep runs short; check loss budget (1.5 dB at 1 GHz for transponders) |
| Transponder power                        | 20-22 AWG      | Per manual; Garmin GTX allows 24 AWG interface, 18/16 power in some cases |
| Mic / headset / audio                    | 22-24 AWG shielded (twisted pair for mic) | Shield grounded at the audio panel/radio only |
| Transponder altitude encoder / data      | 22-24 AWG, shielded for serial data | |
| Magneto P-leads                          | 18-20 AWG shielded | Shield grounded at the engine/magneto end; see section 6 |
| RPM pickup (Rotax rev counter, Hall, VR) | 22 AWG shielded twisted pair | Shield grounded at the monitor end only |
| EGT / CHT thermocouples                  | 20 AWG type K extension | No copper in the thermocouple circuit; see section 5 |
| NTC thermistors / Rotax temp senders     | 22 AWG         | Dedicated ground return; see section 5 |
| Pressure senders (oil, fuel, MAP)        | 22 AWG, 3-wire | Shielded if the run passes ignition wiring |
| Starter, battery, alternator B-lead      | 4-8 AWG / 10 AWG | Not engine monitor scope; per AC 43.13 chart |

### 4. CAN-Bus wiring

- **Cable**: shielded twisted pair, 120 ohm characteristic impedance, 22 or
  24 AWG (e.g. M27500-xxSC2 or equivalent CAN cable). Do not use two loose
  wires or a non-twisted pair.
- **Topology**: one linear bus (daisy chain). No star, no ring. Each node
  either sits on the bus (in-out wiring at the connector) or on a stub.
- **Stub length**: target <= 0.3 m (1 ft) per stub. ISO 11898 tolerates more
  at 500 kbps, but current Garmin G3X manuals limit stubs to 1 ft, so we use the
  strictest limit to remain compatible with mixed-vendor buses.
- **Bus length**: at 500 kbps the theoretical limit is ~100 m; in a light
  aircraft keep it well under 20 m. Not a practical constraint.
- **Termination**: exactly two 120 ohm resistors, one at each physical end of
  the bus. With power off, CAN-H to CAN-L must read ~60 ohm. 120 ohm means
  one terminator missing; ~40 ohm means a third terminator. The engine monitor's
  termination is jumper/config selectable and OFF by default.
- **Shield**: grounded at one point only (preferably the panel ground bus or the
  node nearest it), continued through each node's connector, not connected to
  CAN ground at other nodes. This follows the ModAir shielding lesson and
  general practice; where a vendor manual (e.g. Garmin) prescribes a
  different shield scheme for its stubs, follow it for those stubs.
- **CAN ground**: carry a reference ground with the bus (spare conductor or
  power-ground pair) so all transceivers share a common-mode reference.
- **Bus power**: if nodes are powered via the CAN harness (ModAir style), use a
  separate 20 AWG power pair in the same harness, fused at the source; never
  draw power from the shield.
- **Routing**: keep CAN harness away from ignition leads and transmitter coax;
  cross at 90 degrees where unavoidable.
- **Connectors**: locking connectors (D-sub with screws, or circular
  MIL-DTL-38999/Deutsch DT in the engine bay). Pin assignments recorded in the
  installation manual.

### 5. Temperature sensors

**Thermocouples (EGT, CHT, K-type)**
- Use the probe's own leads as far as possible; extend only with type K
  extension wire of the same type. Yellow = chromel (+), red = alumel (-).
- Never splice with copper wire or use copper terminal blocks inside the
  run: every copper/alloy joint creates a new junction and a reading error.
  The only copper transition is at the converter input (cold junction), which
  must be on the same isothermal block as the cold-junction sensor
  (MAX31855/MAX31856/MAX6675 style, per ADR-0003).
- Keep positive and negative leads of each probe equal in length.
- Splices: crimp with butt splices matching the alloy, or solder with
  zinc-chloride flux (JPI guidance); prefer probe connectors made of thermocouple
  alloy.
- Route away from ignition leads; thermocouple runs do not need a shield in
  normal installations, but use shielded extension where the monitor shows
  ignition noise.
- Use high-temperature insulation within the cowling; bend radius per probe
  manufacturer (AC 43.13 11-115 aa).

**NTC thermistors / Rotax CHT, coolant and oil temperature senders**
- Copper wire, 22 AWG. Lead resistance is negligible compared to the
  kilo-ohm range of the sensor, so gauge is set by mechanical strength.
- Rotax senders are single-terminal and ground through the engine case. Run a
  dedicated ground wire (18-20 AWG) from the engine case ground point to the
  monitor's sensor ground; do not rely on airframe ground through engine
  mounts and the battery cable, as starter and alternator currents shift the
  reference and corrupt readings.
- Two-wire sensors: twist signal and return together.

### 6. RPM and magneto wiring

- **Preferred source**: a dedicated pickup - Rotax rev-counter/trigger output,
  Hall sensor, or VR/magnetic pickup - wired as shielded twisted pair, 22 AWG,
  shield grounded at the monitor end only.
- **Magneto P-lead tapping** (Lycoming/Continental): allowed only through an
  isolating input on the monitor (high-value series resistor plus clamp, or an
  opto/transformer coupled input). P-lead pulses reach several hundred volts.
  The tap must not be able to ground the P-lead (kills the magneto) or open
  it (live magneto when switched off). Use a separate tap wire, spliced with an
  environmentally sealed splice, not by breaking the P-lead.
- **P-leads themselves**: shielded wire, 18-20 AWG, shield grounded at the
  magneto end, routed away from the panel avionics. P-lead and ignition switch
  wiring follow the magneto/ignition manufacturer's manual.
- **Electronic ignition** (P-Mag, SDS, Rotax 912iS): use the ignition's
  dedicated tach output where available.

### 7. Radio equipment (VHF, transponder) relationship

The engine monitor does not wire radios, but must coexist with them:
- Radio power and RF wiring follow the radio's installation manual (wire
  type, gauge, coax type, maximum coax length/loss).
- Coax bend radius >= 6x cable outside diameter (AC 43.13 11-117a). Never
  kink, step on or clamp coax tightly (11-121).
- Route engine monitor sensor and CAN wiring in separate bundles from
  transmitter coax and high-current feeders (AC 43.13 11-105). Where
  unavoidable, cross at 90 degrees.
- Audio and mic wiring: shielded, shields grounded at one point (radio or
  audio panel) to prevent ground loops and alternator whine.
- After installation, perform the AC 43.13 11-107 interference test: key each
  transmitter on several frequencies and verify the engine monitor readings and
  CAN traffic are unaffected (no frame errors, no reading jumps).

### 8. Grounding and power

- Single-point (star) ground: panel ground bus connected to the engine case
  (via a heavy ground strap) and battery negative. All avionics and the engine
  monitor ground at the panel ground bus with their own ground wire, sized like
  the supply wire.
- No airframe-structure ground returns for sensors or avionics in composite
  or tube-and-fabric aircraft; use ground wires.
- Separate power feed (own fuse/breaker) for the engine monitor so a fault
  elsewhere does not blank engine data.

### 9. Installation practice (AC 43.13 chapter 11)

- Support wires at intervals of no more than 24 inches; bundles must not
  deflect more than 1/2 inch between supports (11-118).
- Bend radius: >= 10x the largest wire OD in a bundle; 6x at breakouts or
  reversals if supported (11-117).
- Slack for two re-terminations at every connector; drip loops ahead of
  connectors in the engine bay (11-118, 11-118A).
- Keep wiring >= 6 inches above fuel/oil lines where possible, never less
  than 2 inches unless clamped to keep at least 1/2 inch (11-124); never run
  parallel to fluid lines.
- Keep >= 1/2 inch from control cables under light hand pressure.
- Splices: not within 12 inches of a connector or termination (with listed
  exceptions); self-insulated or environmentally sealed splices in the engine
  bay; no more than needed.
- Use proper ratcheting crimp tools for the contact type; no solder-only
  terminals in vibration areas.
- Label each wire with its wire number at both ends, using the numbering
  system of ADR-0009 (1xx engine, 2xx comms, 3xx power/ground); record it
  in the wire list.
- Firewall penetrations through fire-rated grommets / pass-throughs.

## Consequences

**Positive**
- One documented, traceable basis (AC 43.13-1B values) for every gauge and
  routing choice; wiring diagrams for task 00023 can reference this ADR.
- CAN-Bus rules (single linear bus, 2x 120 ohm, <= 1 ft stubs, single-point
  shield) keep the monitor compatible with mixed-vendor buses (Garmin, ModAir
  style nodes).
- Thermocouple and ground-return rules remove the most common sources of
  inaccurate EGT/CHT and temperature readings, which would otherwise be
  misdiagnosed as software or calibration faults.
- Isolated P-lead input protects magneto function (safety).

**Negative / trade-offs**
- Aviation-grade wire (22759, M27500, RG-400) and sealed splices cost more
  than automotive alternatives, and builders need proper crimp tools.
- AWG 22 minimum and dedicated ground returns add some weight versus AWG 24 and
  airframe ground.
- The hardware design must provide: selectable CAN termination, a protected
  isolated RPM input for P-lead use, a dedicated sensor ground pin, and
  thermocouple converters with on-board cold-junction compensation. These
  feed into the sensor (ADR-0003) and CAN (ADR-0004) hardware tasks.

**Risks / open points**
- This ADR is guidance for experimental installations; it does not certify an
  installation. Certified aircraft need approved data.
- Vendor-specific CAN shield and stub rules (Garmin, Dynon, MGL) differ;
  installers must check the manual of every node on a shared bus.
- Rotax rev-counter signal characteristics (pulses per revolution, pull-up
  needs) vary by engine variant; confirm against the Rotax installation manual
  and set pulses-per-revolution in configuration.
- Indicative radio gauges in section 3 must be verified against the specific
  radio's installation manual.

**Follow-up**
- Task 00023: produce wiring diagrams and a connector pinout based on this ADR.
- Add a wiring checklist (60 ohm CAN check, thermocouple polarity, ground
  continuity, interference test) to the hardware validation task.
