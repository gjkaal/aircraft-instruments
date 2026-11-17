# 00009. Reference Wiring Diagram for Generic Panel Setup

2026-11-16

## Status

__New__

## Context

ADR-0008 defines wire types, gauges, shielding and routing rules, but gives no
picture of how a complete installation fits together. Builders need a
reference diagram showing how the engine monitor shares power, ground and
panel space with the minimum avionics of a light experimental aircraft, plus
the ignition (magneto) wiring that the engine monitor taps for RPM.

Reference equipment:
- Arduino-based engine monitor node (sensor inputs, CAN-Bus output) and a
  CAN display node.
- VHF radio: Trig TY91 remote unit with TC90 panel controller (display),
  built-in 2-place intercom. Installation manual 00839-00 issue AH:
  https://trig-avionics.com/library/00839-00-AH%20TY91%20and%20TY92%20Installation%20Manual.pdf
- Transponder: Trig TT21 or TT22 remote unit with TC20 panel controller
  (display). The TC20 contains the altitude encoder (static port on the TC20),
  so no separate encoder is needed. Installation manual 00560-00 issue AQ:
  https://trig-avionics.com/library/00560-00%20AQ%20TT21TT22%20Installation%20Manual.pdf
- The manuals are copyrighted and not stored in git. Download them into
  `docs/manuals/` (ignored by `.gitignore`) for local reference.
- Optional GPS position source for ADS-B Out (e.g. Trig TN72 or other
  supported RS-232 GPS).
- Two headsets (pilot and passenger).
- Two magnetos (or two Rotax ignition circuits) with separate ignition
  switches. No starter.

Power switching requirements:
- A master switch for the battery.
- A switch for the critical communication equipment (VHF and transponder).
- A separate switch for the engine monitor and other electronics.

The diagrams must be readable in the repository (Markdown rendered on
GitHub) and maintainable as text so they can be reviewed in pull requests.
Every wire needs a unique identifier so the diagram, the wire list, the labels
in the aircraft and troubleshooting notes all refer to the same thing.

Assumptions:
- 14 V DC electrical system, battery + alternator/generator with regulator.
- Engine monitor based on an Arduino-class microcontroller (e.g. Mega 2560)
  with MCP2515 CAN controller, MAX31855-class thermocouple converters and a
  DC-DC converter. The external wiring is identical for the Raspberry Pi
  variant from ADR-0001/ADR-0002.

## Decision

We document the reference installation with Mermaid diagrams and a wire list
in this ADR, and identify every wire with a numeric wire number. Gauges and
cable types follow ADR-0008, except where the Trig installation manuals give
specific values; those values are used and marked "(Trig)". The manuals
always take precedence for Trig equipment.

### 1. Wire numbering system

A wire number has the form `SNN[C]`:

- `S` - system group (first digit):

  | Group | System                                                       | Range   |
  | ----- | ------------------------------------------------------------ | ------- |
  | 1     | Engine systems (monitor, sensors, display, CAN-Bus, ignition) | 100-199 |
  | 2     | Communication (VHF, transponder, GPS, audio, antennas)       | 200-299 |
  | 3     | Power distribution, switching and grounding                  | 300-399 |
  | 4     | Lighting (reserved)                                          | 400-499 |
  | 5     | Flight instruments / EFIS (reserved)                         | 500-599 |
  | 6     | Fuel system (reserved)                                       | 600-699 |
  | 7-9   | Reserved                                                     | -       |

- `NN` - circuit number within the group. Sub-ranges keep related circuits
  together (see the allocation table). Gaps are intentional so circuits can
  be added later without renumbering.
- `C` - optional conductor letter for multi-conductor cables or harnesses:
  `A`, `B`, `C`, ... for the conductors, `S` for the shield/drain.
  Single-conductor wires have no letter. Example: `121A` = EGT 1 chromel (+),
  `121B` = EGT 1 alumel (-), `211A` = TC90 TMAP A.

Rules:
- A wire keeps its number through in-line connectors and the firewall
  pass-through. If a run is split into separately replaceable segments, append
  `-1`, `-2` from the source end (e.g. `121A-1`, `121A-2`).
- The power feed of a unit uses the number of the system the unit belongs to
  (the VHF feed is 2xx, not 3xx). 3xx is only for distribution and switching:
  battery, master, buses, bus switches, ground bus and ground straps.
- Each wire is marked at both ends (laser/ink-jet sleeve or heat-shrink
  label, not hot stamp on thin-wall wire, see ADR-0008) and within 3 inches of
  every connector or splice.
- The wire list (section 10) is the source of truth; diagrams show the numbers.
  Numbers are never reused after a wire is removed.

#### Allocation

| Range   | Use                                         |
| ------- | ------------------------------------------- |
| 101-109 | Engine monitor power and ground             |
| 111-119 | Engine display / EFIS power and ground      |
| 121-129 | Thermocouples (121-124 EGT, 125-128 CHT)    |
| 141-149 | Resistive and voltage senders (temp, press) |
| 151-159 | RPM pickups                                 |
| 161-169 | Sensor ground returns                       |
| 171-179 | CAN-Bus segments                            |
| 181-189 | Ignition: P-leads / kill wires, switch grounds |
| 201-209 | VHF (TY91) power and ground                 |
| 211-219 | VHF controller (TC90) interconnect          |
| 221-229 | VHF RF (coax)                               |
| 231-239 | Transponder (TT21/TT22) power and ground    |
| 241-244 | Transponder controller (TC20) interconnect  |
| 245-249 | GPS power, ground and data                  |
| 251-259 | Transponder RF (coax)                       |
| 261-279 | Audio pilot position                        |
| 281-289 | Audio passenger position                    |
| 291-299 | PTT and intercom key                        |
| 301-309 | Battery, master contactor, master switch, alternator |
| 311-319 | Switched buses (COMMS, ENGINE / ELEC)       |
| 321-339 | Ground bus and ground straps                |

### 2. System overview

All units and wire groups in one picture. Detail per subsystem follows in
sections 3-8; the wire list (section 10) has every conductor.

```mermaid
flowchart TB
    subgraph PWR["Power (3xx)"]
        BAT["Battery 12V"]
        CONT["Master contactor"]
        ALT["Alternator + regulator"]
        MSW["MASTER switch"]
        MBUS["Main bus"]
        CSW["COMMS switch"]
        ESW["ENGINE / ELEC switch"]
        CBUS["COMMS bus"]
        EBUS["ENGINE / ELEC bus"]
        GND["Panel ground bus"]
    end

    subgraph ENG["Engine (1xx)"]
        MAGL["Left magneto"]
        MAGR["Right magneto"]
        SENS["EGT / CHT / oil temp / oil press"]
        RPMP["RPM pickup"]
        ECASE["Engine case ground"]
    end

    subgraph IGN["Ignition switches (1xx)"]
        SWL["MAG L"]
        SWR["MAG R"]
    end

    subgraph EMS["Engine monitoring (1xx)"]
        EM["Arduino engine monitor"]
        DISP["Engine display / EFIS"]
    end

    subgraph COM["Comms (2xx)"]
        TY91["Trig TY91 VHF"]
        TC90["TC90 controller"]
        TT["Trig TT21/TT22"]
        TC20["TC20 controller + encoder"]
        GPS["GPS (ADS-B)"]
        JACKS["Headset jacks pilot + passenger"]
        PTT["PTT pilot / passenger"]
        VANT["VHF antenna"]
        XANT["XPDR antenna"]
    end

    BAT -- "301" --> CONT
    CONT -- "302" --> MBUS
    ALT -- "303" --> MBUS
    BAT -- "304" --> MSW
    MSW -- "305" --> CONT
    MBUS -- "311" --> CSW
    CSW -- "312" --> CBUS
    MBUS -- "313" --> ESW
    ESW -- "314" --> EBUS
    GND -- "321" --> ECASE
    ECASE -- "322" --> BAT

    EBUS -- "101 / 102" --> EM
    EBUS -- "111 / 112" --> DISP
    SENS -- "121-128, 141-142" --> EM
    RPMP -- "151" --> EM
    ECASE -- "161" --> EM
    EM == "171-172 CAN" ==> DISP

    MAGL -- "181" --> SWL
    MAGR -- "182" --> SWR
    SWL -- "183" --> ECASE
    SWR -- "184" --> ECASE
    MAGL -. "152 alt. RPM tap" .-> EM

    CBUS -- "201-204" --> TY91
    TY91 -- "211" --- TC90
    TY91 -- "221 coax" --- VANT
    TY91 -- "261-262, 281-282" --- JACKS
    TY91 -- "291-293" --- PTT
    CBUS -- "231-233" --> TT
    TT -- "241" --- TC20
    TT -- "251 coax" --- XANT
    CBUS -- "245 / 247" --> GPS
    GPS -- "246" --> TT
```

Ground returns (102, 112, 203-204, 232-233, 247, 323) all go to the panel
ground bus; they are left out of this overview for readability.

### 3. Power distribution and switching

```mermaid
flowchart LR
    subgraph SRC["Source"]
        BAT["Battery 12V"]
        CONT["Master contactor"]
        ALT["Alternator / generator + regulator"]
    end

    subgraph SW["Panel switches"]
        MSW["MASTER switch"]
        CSW["COMMS switch (VHF + XPDR)"]
        ESW["ENGINE / ELEC switch"]
    end

    MBUS["Main bus"]
    CBUS["COMMS bus"]
    EBUS["ENGINE / ELEC bus"]
    GND["Panel ground bus (star point)"]
    ENGGND["Engine case ground"]

    subgraph COMMS["Communication equipment"]
        TY91["Trig TY91 VHF"]
        TT2X["Trig TT21/TT22 transponder"]
        GPS["GPS (ADS-B position)"]
    end

    subgraph ELEC["Engine monitor and electronics"]
        EM["Arduino engine monitor"]
        DISP["Engine display / EFIS"]
    end

    BAT -- "301: 8-10 AWG" --> CONT
    CONT -- "302: 8-10 AWG" --> MBUS
    ALT -- "303: per alternator/regulator manual" --> MBUS
    BAT -- "304: fuse 5A, 20 AWG" --> MSW
    MSW -- "305: 20 AWG" --> CONT
    CONT -- "323: coil ground 20 AWG" --> GND

    MBUS -- "311: CB 10A, 14 AWG" --> CSW
    CSW -- "312: 14 AWG" --> CBUS
    MBUS -- "313: CB 10A, 14 AWG" --> ESW
    ESW -- "314: 14 AWG" --> EBUS

    CBUS -- "201 + 202: CB 5A, 2x 20 AWG (Trig)" --> TY91
    CBUS -- "231: CB 3A, 20 AWG (Trig)" --> TT2X
    CBUS -- "245: CB 2A, 22 AWG" --> GPS
    EBUS -- "101: CB 3A, 20 AWG" --> EM
    EBUS -- "111: CB 3A, 20 AWG" --> DISP

    TY91 -- "203 + 204: 2x 20 AWG" --> GND
    TT2X -- "232 + 233: 2x 20 AWG" --> GND
    GPS -- "247: 22 AWG" --> GND
    EM -- "102: 20 AWG" --> GND
    DISP -- "112: 20 AWG" --> GND
    GND -- "321: 8-10 AWG" --> ENGGND
    ENGGND -- "322: ground strap" --> BAT
```

Notes:
- No starter, so the main power cables (301, 302) are sized for the maximum
  alternator output plus margin rather than for starter current.
- MASTER switches the contactor coil. A small aircraft with a low total load
  may use a suitably rated master switch directly in the battery line instead
  of a contactor; then 304/305 disappear and 301/302 go through the switch.
- COMMS and ENGINE / ELEC are independent: an electrical fault on one bus can
  be isolated without losing the other. The ENGINE / ELEC switch can stay on
  while radios are switched off during start-up transients.
- Bus switches may be implemented as circuit-breaker switches (combined
  switch and breaker); then 311/313 have no separate breaker.
- Both TY91 power pins (24, 25) and at least two grounds must be wired; peak
  transmit current exceeds one connector pin's rating (Trig 5.6.11).
- The TT21/TT22 power input is NOT protected against reverse polarity;
  verify 231 polarity before first power-up (Trig 5.6.1).
- Breaker values protect the wire (ADR-0008 section 2, item 4).

### 4. Ignition (magnetos) and RPM

The ignition circuits are independent of the aircraft electrical system:
they must work with MASTER off and must not depend on any bus.

```mermaid
flowchart LR
    subgraph ENGINE["Engine"]
        MAGL["Left magneto (or Rotax ignition A)"]
        MAGR["Right magneto (or Rotax ignition B)"]
        PICK["Rotax rev-counter pickup / Hall sensor"]
        ECASE["Engine case ground point"]
    end

    FW["Firewall pass-through, fire-rated"]

    subgraph PANELSW["Panel"]
        SWL["MAG L switch (ON = open, OFF = ground)"]
        SWR["MAG R switch (ON = open, OFF = ground)"]
    end

    EM["Engine monitor: isolated RPM input"]

    MAGL -- "181 A/S: P-lead, shielded 18-20 AWG" --> FW
    MAGR -- "182 A/S: P-lead, shielded 18-20 AWG" --> FW
    FW -- "181A" --> SWL
    FW -- "182A" --> SWR
    SWL -- "183: 18 AWG switch ground" --> ECASE
    SWR -- "184: 18 AWG switch ground" --> ECASE

    PICK -- "151 A/B/S: 22 AWG STP (preferred)" --> EM
    MAGL -. "152: alternative isolated P-lead tap, 22 AWG" .-> EM
```

Rules:
- A magneto is LIVE when its P-lead is open. A broken P-lead, a loose switch
  terminal or a failed switch ground leaves the magneto live with the switch
  OFF. Do the magneto ground check (switch each magneto OFF briefly at idle
  and confirm the RPM drop / engine stumble) after every change to this
  wiring.
- Use separate switches for left and right; do not use a switch that can
  ground both through a single contact. A key switch without start position
  is an alternative.
- P-lead shield (181S, 182S) grounded at the magneto end; at the switch end
  the shield is trimmed back and insulated. If the magneto or ignition
  manufacturer prescribes a different scheme, follow the manufacturer.
- Switch grounds 183/184 run to the engine case ground point, not only to the
  panel ground bus, so the kill path does not depend on the airframe ground
  strap.
- RPM: use the dedicated pickup (151) where available (Rotax rev-counter
  output, Hall sensor). For magneto engines without a pickup, use tap 152 on
  ONE P-lead only, connected to the P-lead with an environmentally sealed
  splice near the switch, into the engine monitor's isolated, protected input
  (ADR-0008 section 6). The tap must never be able to ground the P-lead.
- Route P-leads away from audio, CAN and coax bundles; cross at 90 degrees.

### 5. Engine monitor detail: sensors and CAN-Bus

```mermaid
flowchart LR
    subgraph ENGINE["Engine bay"]
        EGT["EGT probes 1-4, type K"]
        CHT["CHT probes 1-4, type K"]
        OILT["Oil temp sender NTC"]
        OILP["Oil pressure sender 0-5V"]
        RPM["RPM pickup / P-lead tap (section 4)"]
        ECASE["Engine case ground point"]
    end

    FW["Firewall pass-through, fire-rated"]

    subgraph EMU["Arduino engine monitor"]
        PSU["DC-DC 14V to 5V, TVS + reverse polarity"]
        MCU["Arduino Mega 2560"]
        TC["MAX31855 x8, cold junction on board"]
        ADC["Analog inputs + reference"]
        CNT["Protected RPM input (counter / interrupt)"]
        CANC["MCP2515 + transceiver"]
        TERM["120 ohm termination jumper ON"]
    end

    subgraph BUS["CAN-Bus"]
        DISP["Display / EFIS, 120 ohm term ON (bus end)"]
        NODE["Other CAN node (stub max 0.3 m)"]
    end

    EGT -- "121-124 A/B: type K ext. 20 AWG, no copper" --> FW
    CHT -- "125-128 A/B: type K ext. 20 AWG" --> FW
    OILT -- "141: 22 AWG" --> FW
    OILP -- "142 A/B/C/S: 22 AWG 3-wire, shielded" --> FW
    RPM -- "151 A/B/S or 152" --> FW
    ECASE -- "161: 18-20 AWG sensor ground" --> FW

    FW --> TC
    FW --> ADC
    FW --> CNT

    PSU --> MCU
    TC -- "SPI" --> MCU
    ADC --> MCU
    CNT --> MCU
    MCU -- "SPI" --> CANC
    CANC --- TERM
    CANC == "171 A/B/C/S: STP 120 ohm" ==> NODE
    NODE == "172 A/B/C/S: STP 120 ohm" ==> DISP
```

Notes:
- CAN conductors: `A` = CAN-H, `B` = CAN-L, `C` = CAN-GND, `S` = shield.
  Shield of 171/172 is grounded at one point only (ADR-0008 section 4).
- Thermocouple conductors: `A` = chromel (+, yellow), `B` = alumel (-, red).
- Oil pressure conductors: `A` = +5 V excitation, `B` = signal,
  `C` = sender return, `S` = shield.
- RPM conductors (151): `A` = signal, `B` = return, `S` = shield.
- Bus order: engine monitor (end, terminated) -> other nodes -> display (end,
  terminated). If the engine monitor is not at a bus end, its termination
  jumper is OFF. Check: about 60 ohm between 171A and 171B with power off.
- The Arduino Mega's on-board regulator is not suitable for direct 14 V
  aircraft power (heat at 14.4 V charging voltage, no transient protection).
  Use an external DC-DC converter with input TVS diode and reverse polarity
  protection.
- Rotax single-terminal senders use the engine case as return: wire 161 is
  mandatory (ADR-0008 section 5).
- The Trig TMAP bus (RS-485 based, VHF and transponder controllers) is a
  separate, point-to-point Trig link; it is not connected to the CAN-Bus.

#### Engine monitor connector pin-out

The engine monitor uses MIL-C-24308 (MIL-DTL-24308) D-sub connectors with
crimp contacts, the same family as the Trig equipment. One crimp tool
(M22520/2-01 with M22520/2-08 positioner) and one socket contact
(M39029/63-368, 20-24 AWG) cover the whole panel.

| Connector | Type                  | Function                         |
| --------- | --------------------- | -------------------------------- |
| J1        | DB-25 (25-way)        | Thermocouples (EGT, CHT)         |
| J2        | DA-15 (15-way)        | Power, analog senders, RPM       |
| J3        | DE-9 (9-way)          | CAN-Bus port 1                   |
| J4        | DE-9 (9-way)          | CAN-Bus port 2 (parallel to J3)  |

Conventions:
- The unit has male (pin) connectors; the harness has female (socket)
  connectors, so no live pins are exposed on a disconnected harness.
- All connectors are secured with jackscrews (ADR-0008: locking connectors).
- Each connector has a different size, so harness plugs cannot be swapped
  between J1, J2 and J3/J4. J3 and J4 are electrically identical.
- Pin numbers as marked on the connector; viewed from the wiring side of the
  harness plug, pin 1 is top right.

Connector selection - options considered:

| Option                                   | Pro                                              | Con                                          |
| ---------------------------------------- | ------------------------------------------------ | -------------------------------------------- |
| MIL-DTL-24308 D-sub, crimp (chosen)      | Same contacts and crimp tool as Trig TY91/TC90/TT21/TC20; cheap; widely available; contacts individually replaceable | Not sealed; moderate vibration resistance; cabin side of firewall only |
| Circular MIL-DTL-38999 or Deutsch DT/DTM | Sealed, keyed, very good vibration resistance; suitable for firewall-forward mounting | More expensive; different contacts and crimp tool; larger panel footprint |
| Thermocouple-alloy connectors for J1     | No copper in the thermocouple path at all       | Bulky and expensive for 8+ channels; separate connector per probe or special multi-pin blocks |

D-sub is chosen because the engine monitor is mounted behind the panel (cabin
side, like the Trig units), and sharing one contact type and tool with the
radio and transponder harnesses keeps installation simple. If the unit is ever
moved firewall-forward, the connectors change to sealed circulars; the pin
assignment by function (J1 thermocouples, J2 power/senders/RPM, J3/J4 CAN)
remains.

Pin location rationale:
- Thermocouples are on their own connector (J1) so J1 can be placed on the
  converter board and kept isothermal with the cold-junction sensors; mixing
  them with power pins would bring current-heated contacts next to them.
- Each thermocouple pair uses vertically adjacent pins (+ on the top row,
  - directly below), so both K/Cu transitions of a pair are at the same
  temperature and the pair is easy to check by eye.
- EGT on TC1-4 and CHT on TC5-8 follows wire numbers 121-128 in order, so
  wire number, channel and pin increase together.
- Power (J2-1, J2-2) and sensor ground (J2-3) are separate pins at the start
  of J2, keeping supply current out of the analog reference.
- Each sender keeps its conductors on consecutive pins (oil pressure 5-7 with
  shield on 9, RPM 10-12), so a cable's conductors are not spread over the
  connector.
- The P-lead tap (J2-15) is in a corner with its neighbours (J2-8, J2-14)
  left empty, giving creepage distance for several-hundred-volt pulses and
  preventing a pin-to-pin short from grounding the P-lead or injecting high
  voltage into a neighbouring input.
- CAN uses the standard CiA 303-1 DE-9 pin-out, so off-the-shelf CAN cables,
  adapters and bus analysers plug in directly for troubleshooting.
- Spare and reserved pins are at the end of each pin range, so growth (TC9-10,
  extra analog input) does not move existing pins and harnesses stay valid.

**J1 - Thermocouples (DB-25)**

Each thermocouple has + on the top row and - directly below it on the bottom
row, so a pair always sits on adjacent pins.

| Pin | Signal       | Wire  | Pin | Signal       | Wire  |
| --- | ------------ | ----- | --- | ------------ | ----- |
| 1   | TC1 + EGT 1  | 121A  | 14  | TC1 - EGT 1  | 121B  |
| 2   | TC2 + EGT 2  | 122A  | 15  | TC2 - EGT 2  | 122B  |
| 3   | TC3 + EGT 3  | 123A  | 16  | TC3 - EGT 3  | 123B  |
| 4   | TC4 + EGT 4  | 124A  | 17  | TC4 - EGT 4  | 124B  |
| 5   | TC5 + CHT 1  | 125A  | 18  | TC5 - CHT 1  | 125B  |
| 6   | TC6 + CHT 2  | 126A  | 19  | TC6 - CHT 2  | 126B  |
| 7   | TC7 + CHT 3  | 127A  | 20  | TC7 - CHT 3  | 127B  |
| 8   | TC8 + CHT 4  | 128A  | 21  | TC8 - CHT 4  | 128B  |
| 9   | Reserved TC9 +  | -  | 22  | Reserved TC9 -  | -  |
| 10  | Reserved TC10 + | -  | 23  | Reserved TC10 - | -  |
| 11  | Reserved     | -     | 24  | Reserved     | -     |
| 12  | Reserved     | -     | 25  | Reserved     | -     |
| 13  | Reserved     | -     |     |              |       |

- Thermocouple wire runs directly into J1 (stranded type K extension wire,
  no copper in between). The copper D-sub contacts form the K/Cu transition;
  both contacts of a pair are at the same temperature, so the errors cancel
  provided J1 is isothermal with the cold-junction sensors. J1 is therefore
  mounted on the same board as the MAX31855 converters, close to them and
  away from the DC-DC converter and other heat sources.
- Reserved TC9/TC10 allow 6-cylinder engines (or EGT/CHT 5-6) without a
  connector change; a 6-cylinder variant renumbers per the allocation table.
- Thermocouple inputs are floating (no ground on J1); MAX31855 inputs must
  not be grounded externally. Grounded-junction probes are not supported.

**J2 - Power, senders and RPM (DA-15)**

| Pin | Signal                         | Wire  | Notes                                   |
| --- | ------------------------------ | ----- | --------------------------------------- |
| 1   | +14 V power in                 | 101   | From ENGINE/ELEC bus, CB 3A             |
| 2   | Power ground                   | 102   | To panel ground bus                     |
| 3   | Sensor ground                  | 161   | From engine case ground point           |
| 4   | Oil temperature in (NTC)       | 141   | Internal pull-up; return via pin 3      |
| 5   | Sender excitation +5 V out     | 142A  | Current limited, shared with pin 13     |
| 6   | Oil pressure signal in         | 142B  | 0-5 V                                   |
| 7   | Oil pressure sender return     | 142C  | Analog ground                           |
| 8   | NC - keep empty                | -     | HV clearance for pin 15                 |
| 9   | Oil pressure shield            | 142S  | Grounded at monitor end only            |
| 10  | RPM signal in (pickup)         | 151A  | Hall / VR / Rotax trigger               |
| 11  | RPM return                     | 151B  |                                         |
| 12  | RPM shield                     | 151S  | Grounded at monitor end only            |
| 13  | Spare analog in (0-5 V)        | -     | Fuel pressure, fuel level, MAP, ...     |
| 14  | NC - keep empty                | -     | HV clearance for pin 15                 |
| 15  | RPM P-lead tap in (isolated)   | 152   | Alternative to 151; see section 4       |

- Power (pins 1, 2) and sensor ground (pin 3) are separate pins: 102 carries
  supply current, 161 only carries sender return current, so the analog
  reference is not shifted by supply current (ADR-0008 section 5).
- Pins 8 and 14 are left empty around pin 15 because P-lead pulses reach
  several hundred volts. Pin 15 enters a protected, isolated input (series
  resistor, clamp, opto/transformer) directly behind the connector. Use either
  151 (pins 10-12) or 152 (pin 15), not both.
- Shields 142S and 151S are connected to the sensor ground inside the unit;
  at the sender/pickup end they are trimmed and insulated.

**J3 / J4 - CAN-Bus (DE-9, CiA 303-1 pin-out)**

J3 and J4 are wired in parallel inside the unit, so the bus can pass through
the engine monitor (in on J3, out on J4). At a bus end only one is used.

| Pin | Signal          | Wire  | Notes                                       |
| --- | --------------- | ----- | ------------------------------------------- |
| 1   | Reserved        | -     |                                             |
| 2   | CAN-L           | 17xB  |                                             |
| 3   | CAN-GND         | 17xC  | Transceiver ground reference                |
| 4   | Reserved        | -     |                                             |
| 5   | CAN shield      | 17xS  | J3-5 and J4-5 joined; to ground only via JP2 |
| 6   | Reserved        | -     | (CiA optional GND, not used)                |
| 7   | CAN-H           | 17xA  |                                             |
| 8   | Reserved        | -     |                                             |
| 9   | Reserved        | -     | (CiA optional V+, not used: unit has own power on J2) |

`17x` = the CAN segment wire connected to that port (171 in this reference
setup, which uses J4 only; a pass-through installation uses 17n on J3 and
17n+1 on J4).

Jumpers:
- JP1 - CAN termination 120 ohm between CAN-H and CAN-L. ON only when the
  engine monitor is at a physical end of the bus (as in this reference setup).
- JP2 - CAN shield to ground. ON only on the single node chosen as the shield
  ground point (ADR-0008 section 4). Default OFF: shield passes through J3/J4
  without being grounded.

### 6. VHF radio: Trig TY91 + TC90

TY91 connector: 25-way D-sub (Trig 5.5.1). TC90 connector: 15-way D-sub
(Trig 5.7.1). Crimp contacts accept 20-24 AWG.

```mermaid
flowchart LR
    CBUS["COMMS bus"]
    GND["Panel ground bus"]

    subgraph TY91["Trig TY91 (25-way)"]
        P24["24, 25: Aircraft power"]
        P19["19, 22: Ground"]
        P3["3, 4: TMAP1 A / B"]
        P12["12: Controller power 12V"]
        P13["13: Power ON"]
        P9["9: Ground"]
        RF["TNC antenna"]
    end

    subgraph TC90["Trig TC90 controller (15-way)"]
        C2["2, 3: TMAP A / B"]
        C9["9: Power in"]
        C10["10: Power ground"]
        C8["8: Remote ON"]
        C7["7: Ground"]
    end

    VANT["VHF comm antenna (ground plane >= 1 m2 on composite)"]

    CBUS -- "201 to pin 24, 202 to pin 25: CB 5A, 20 AWG" --> P24
    P19 -- "203 from pin 19, 204 from pin 22: 20 AWG" --> GND
    P3 -- "211A/B: twisted pair 22 AWG" --> C2
    P12 -- "211C: 22 AWG" --> C9
    P9 -- "211D: 22 AWG" --> C10
    C8 -- "211E: 22 AWG" --> P13
    C7 -- "211F: 22 AWG, to pin 9" --> P9
    RF -- "221: RG-400 / RG-142B, TNC" --> VANT
```

TC90 interconnect 211 (Trig 5.10.1):

| Cond. | TY91 pin        | TC90 pin        | Notes                          |
| ----- | --------------- | --------------- | ------------------------------ |
| 211A  | 3 TMAP1 A       | 2 TMAP A        | Twist with 211B, 1 turn / 1-2 in |
| 211B  | 4 TMAP1 B       | 3 TMAP B        |                                |
| 211C  | 12 Ctrl power   | 9 Power in      | NEVER connect to aircraft power |
| 211D  | 9 Ground        | 10 Power ground |                                |
| 211E  | 13 Power ON     | 8 Remote ON     | TC90 power switch turns TY91 on |
| 211F  | 9 Ground        | 7 Ground        | Return for 211E                |

- Max 211 length: 28 m at 20 AWG, 15.6 m at 22 AWG, 10 m at 24 AWG (TC90
  power line < 1 ohm, Trig 5.10.1).
- 211 may share a loom with the TC20 interconnect (241); audio and antenna
  wiring must be kept apart (Trig 5.10.1 note).
- Unused: pins 5, 6 (RS-232, not used), 7, 8 (TMAP2, for a second TC90),
  16 (reserved), 18 (TX interlock, dual VHF only), 20 (aux audio), 1, 2
  (speaker - add as 205/206 if a cabin speaker is fitted).
- Antenna: 221 RG-400 or RG-142B, 50 ohm (Trig 5.11.2); keep at least 2 ft
  from any GPS antenna and at least 3 ft from the transponder antenna.

### 7. Dual headset, PTT and intercom (TY91)

The TY91 has one headphone output (mono) intended for one or two 300-600 ohm
headsets in parallel, two microphone inputs with 12 V bias for standard
aviation headsets, two PTT inputs and an intercom key input (Trig 5.6).
Standard GA plugs: PJ-068 microphone (0.206 in), PJ-055 phone (0.25 in).

```mermaid
flowchart LR
    subgraph TY91["Trig TY91 (25-way)"]
        M1["23: Mic 1"]
        M2["21: Mic 2"]
        MG["22: Ground (mic lo, shields)"]
        PH["11: Headphone out"]
        PHG["10: Headphone return"]
        T1["15: PTT1"]
        T2["14: PTT2"]
        IC["17: Intercom key"]
    end

    subgraph PILOT["Pilot jacks (isolated from panel)"]
        MJ1["Mic jack: tip=mic hi, ring=PTT, sleeve=mic lo"]
        PJ1["Phone jack: tip+ring=audio, sleeve=return"]
    end

    subgraph PAX["Passenger jacks (isolated from panel)"]
        MJ2["Mic jack: tip=mic hi, ring=PTT opt., sleeve=mic lo"]
        PJ2["Phone jack: tip+ring=audio, sleeve=return"]
    end

    STICK["Pilot stick PTT"]
    PSTICK["Passenger PTT (optional)"]

    M1 -- "261A: STP 22-24 AWG" --> MJ1
    MG -- "261B mic lo, 261S shield" --> MJ1
    PH -- "262A: STP 22-24 AWG" --> PJ1
    PHG -- "262B return, 262S shield" --> PJ1
    M2 -- "281A: STP 22-24 AWG" --> MJ2
    MG -- "281B mic lo, 281S shield" --> MJ2
    PH -- "282A: STP 22-24 AWG (parallel to 262A)" --> PJ2
    PHG -- "282B return, 282S shield" --> PJ2
    T1 -- "291 A/B/S: STP 22 AWG" --> STICK
    MJ1 -. "261C: jack PTT ring to pin 15" .-> T1
    T2 -- "292 A/B/S: STP 22 AWG" --> PSTICK
    MJ2 -. "281C: jack PTT ring to pin 14 (optional)" .-> T2
    IC -- "293: jumper to ground pin inside D-shell (VOX)" --> MG
```

Conductor assignment:

| Wire | A                    | B                    | C                    | S                      |
| ---- | -------------------- | -------------------- | -------------------- | ---------------------- |
| 261  | Mic 1 hi, pin 23     | Mic lo, pin 22       | PTT ring, pin 15     | Shield, pin 22 (radio end only) |
| 262  | Phone, pin 11        | Return, pin 10       | -                    | Shield, radio end only |
| 281  | Mic 2 hi, pin 21     | Mic lo, pin 22       | PTT ring, pin 14 (opt.) | Shield, pin 22 (radio end only) |
| 282  | Phone, pin 11        | Return, pin 10       | -                    | Shield, radio end only |
| 291  | PTT1, pin 15         | Ground, pin 22/9     | -                    | Shield, radio end only |
| 292  | PTT2, pin 14 (opt.)  | Ground, pin 22/9     | -                    | Shield, radio end only |
| 293  | Intercom key pin 17 to ground (single wire, VOX intercom) | - | - | -     |

Rules:
- Mic and phone lines in screened twisted pair, screen grounded at the radio
  end only (Trig 5.6.10, 5.10.3, diagram 2 note 5). Unscreened audio picks
  up transponder replies as clicks in the headset.
- The TY91 has only five ground pins (1, 9, 10, 19, 22) for about ten ground
  connections; double up with a short ground jumper inside the D-shell
  (Trig 5.6.12).
- Phone output is mono: at each phone jack, connect tip and ring together to
  262A/282A so stereo headsets hear audio in both ears. 262 and 282 join at
  pin 11 / pin 10 at the radio connector.
- PTT1 (pilot) has priority over PTT2 (Trig 5.6.6).
- Intercom: 293 ties pin 17 to ground for voice-activated (VOX) intercom.
  For a switched intercom, replace 293 with a switch to ground and set VOX
  squelch to minimum (Trig 5.6.7).
- Mic lo and phone return are separate wires, joined only at the radio.
  Jacks are mounted with insulating washers, not grounded to the panel.
- The TY91 does not support dynamic microphones without a preamplifier.

### 8. Transponder: Trig TT21/TT22 + TC20, GPS

TT21/TT22 connector: 25-way D-sub (Trig 5.5.1). TC20 connector: 9-way D-sub
(Trig 5.7.1). Crimp contacts accept 20-24 AWG.

```mermaid
flowchart LR
    CBUS["COMMS bus"]
    GND["Panel ground bus"]

    subgraph TT["Trig TT21/TT22 (25-way)"]
        T15["15: 11-33V DC"]
        T1["1, 4: Ground"]
        T2["2, 3: TMAP1 A / B"]
        T11["11: Controller power 6.5V"]
        T10["10: Ground"]
        T13["13: Power ON"]
        T12["12: Ground"]
        T5["5: GPS position in (RS-232)"]
        T6["6: Ground"]
        TRF["TNC antenna"]
    end

    subgraph TC20["Trig TC20 controller + encoder (9-way)"]
        K2["2, 3: TMAP A / B"]
        K8["8: Power"]
        K9["9: Ground"]
        K7["7: Remote ON"]
        K6["6: Ground"]
        STAT["Static port (pneumatic, to aircraft static)"]
    end

    subgraph GPSU["GPS position source (optional, ADS-B Out)"]
        GTX["RS-232 Tx"]
        GG["Ground"]
    end

    XANT["Transponder antenna (bottom, vertical)"]

    CBUS -- "231: CB 3A, 20 AWG to pin 15" --> T15
    T1 -- "232 from pin 1, 233 from pin 4: 20 AWG" --> GND
    T2 -- "241A/B: twisted pair 22 AWG" --> K2
    T11 -- "241C: 22 AWG" --> K8
    T10 -- "241D: 22 AWG" --> K9
    K7 -- "241E: 22 AWG" --> T13
    K6 -- "241F: 22 AWG, to pin 12" --> T12
    GTX -- "246A: shielded 22-24 AWG to pin 5" --> T5
    GG -- "246B: to pin 6, 246S shield at TT end" --> T6
    TRF -- "251: RG-400 max 2.5 m" --> XANT
```

TC20 interconnect 241 (Trig 5.10):

| Cond. | TT21/TT22 pin   | TC20 pin   | Notes                            |
| ----- | --------------- | ---------- | -------------------------------- |
| 241A  | 2 TMAP1 A       | 2 TMAP A   | Twist with 241B, 1 turn / 1-2 in |
| 241B  | 3 TMAP1 B       | 3 TMAP B   |                                  |
| 241C  | 11 Ctrl power   | 8 Power    | 6.5 V; NEVER aircraft power      |
| 241D  | 10 Ground       | 9 Ground   |                                  |
| 241E  | 13 Power ON     | 7 Remote ON| TC20 mode knob turns TT on       |
| 241F  | 12 Ground       | 6 Ground   | Return for 241E                  |

- Max 241 length: 14.2 m at 20 AWG, 7.8 m at 22 AWG, 5.0 m at 24 AWG (TC20
  power line < 0.5 ohm, Trig 5.10).
- GPS: power 245 from the COMMS bus, ground 247, data 246 to TT pin 5/6.
  Set the GPS protocol and line speed in the transponder configuration
  (Trig 6.1.8, 6.1.9). Without GPS the transponder works as Mode S without
  ADS-B Out.
- Unused: pins 7 (TIS out, USA only), 8, 9 (TMAP2), 14 (ground spare),
  17 (external standby, dual transponder only), 18 (mutual suppression,
  only with DME/TCAS), 19 (squat switch: leave open and configure "ignore";
  with ADS-B the TT uses GPS for air/ground), 20 (remote ident, optional:
  add as 234 with a momentary switch to ground), 16, 21-25 reserved.
- TC20 pin 4 (altitude out, RS-232 9600 bps) is optional for GPS
  baro-aiding; add as 242 if used.
- TC20 static port connects to the same static source as the primary
  altimeter (Trig 5.12); this is a pneumatic line, not a wire.
- Antenna 251: 50 ohm, double braid or foil + braid, max 1.5 dB cable loss
  at 1090 MHz. RG-400 (M17/128) max about 2.5 m (8 ft 4 in); longer runs need
  lower-loss cable (Trig 5.11.2 table). Antenna on the bottom surface,
  vertical in level flight, at least 3 ft from the VHF comm antenna, with
  a ground plane of at least 120 mm square (700 mm square ideal) on
  composite or fabric airframes.

### 9. Bundles and routing

| Bundle                | Wires                                       | Keep away from               |
| --------------------- | ------------------------------------------- | ---------------------------- |
| Power feeders         | 101, 111, 201-202, 231, 245, 301-305, 311-314 | Audio, sensor wiring       |
| Grounds               | 102, 112, 203-204, 232-233, 247, 321-323    | -                            |
| Ignition              | 181-184, 152                                | Audio, CAN, coax, panel avionics |
| Engine sensor         | 121-128, 141-142, 151, 161                  | Ignition leads, 303 B-lead   |
| CAN-Bus               | 171-172                                     | 221, 251, ignition           |
| Trig controller loom  | 211, 241 (may share one loom, Trig 5.10.1)  | Audio                        |
| Audio                 | 261-262, 281-282, 291-293                   | 221, 251, ignition, alternator |
| GPS data              | 246                                         | 221                          |
| RF                    | 221, 251 (separately clamped)               | All other bundles            |

### 10. Wire list

| Wire | From                     | To                         | Cable / gauge                      | Protection |
| ---- | ------------------------ | -------------------------- | ---------------------------------- | ---------- |
| 101  | ENGINE/ELEC bus CB       | Engine monitor J2-1        | 22759/16, 20 AWG                   | CB 3A      |
| 102  | Engine monitor J2-2      | Panel ground bus           | 22759/16, 20 AWG                   | -          |
| 111  | ENGINE/ELEC bus CB       | Display +14V               | 22759/16, 20 AWG                   | CB 3A      |
| 112  | Display GND              | Panel ground bus           | 22759/16, 20 AWG                   | -          |
| 121-124 | EGT probe 1-4         | J1-1..4 (+), J1-14..17 (-) | Type K ext., 20 AWG, A=+ B=-       | -          |
| 125-128 | CHT probe 1-4         | J1-5..8 (+), J1-18..21 (-) | Type K ext., 20 AWG, A=+ B=-       | -          |
| 141  | Oil temp sender          | Engine monitor J2-4        | 22759/16, 22 AWG                   | -          |
| 142  | Oil pressure sender      | J2-5 (A), 6 (B), 7 (C), 9 (S) | M27500 3-cond. shielded, 22 AWG    | -          |
| 151  | RPM pickup               | J2-10 (A), 11 (B), 12 (S)  | M27500 STP, 22 AWG                 | -          |
| 152  | P-lead 181A (sealed splice) | Engine monitor J2-15 (isolated) | 22759/16, 22 AWG (alternative to 151) | In monitor input |
| 161  | Engine case ground point | Engine monitor J2-3        | 22759/16, 18-20 AWG                | -          |
| 171  | Engine monitor J4 (7,2,3,5) | CAN node (or display)   | 120 ohm STP + gnd, 22-24 AWG       | -          |
| 172  | CAN node                 | Display CAN                | 120 ohm STP + gnd, 22-24 AWG       | -          |
| 181  | Left magneto P-lead      | MAG L switch               | Shielded 18-20 AWG, S at magneto   | -          |
| 182  | Right magneto P-lead     | MAG R switch               | Shielded 18-20 AWG, S at magneto   | -          |
| 183  | MAG L switch ground      | Engine case ground point   | 22759/16, 18 AWG                   | -          |
| 184  | MAG R switch ground      | Engine case ground point   | 22759/16, 18 AWG                   | -          |
| 201  | COMMS bus CB             | TY91 pin 24                | 22759/16, 20 AWG (Trig)            | CB 5A (Trig) |
| 202  | COMMS bus CB (same CB)   | TY91 pin 25                | 22759/16, 20 AWG (Trig)            | CB 5A      |
| 203  | TY91 pin 19              | Panel ground bus           | 22759/16, 20 AWG                   | -          |
| 204  | TY91 pin 22              | Panel ground bus           | 22759/16, 20 AWG                   | -          |
| 211  | TY91 pins 3,4,12,9,13,9  | TC90 pins 2,3,9,10,8,7     | 6x 22759/16 22 AWG, A/B twisted    | Internal (TY91) |
| 221  | TY91 TNC                 | VHF comm antenna           | RG-400 or RG-142B (Trig)           | -          |
| 231  | COMMS bus CB             | TT21/TT22 pin 15           | 22759/16, 20 AWG                   | CB 3A (Trig) |
| 232  | TT21/TT22 pin 1          | Panel ground bus           | 22759/16, 20 AWG                   | -          |
| 233  | TT21/TT22 pin 4          | Panel ground bus           | 22759/16, 20 AWG                   | -          |
| 241  | TT pins 2,3,11,10,13,12  | TC20 pins 2,3,8,9,7,6      | 6x 22759/16 22 AWG, A/B twisted    | Internal (TT) |
| 245  | COMMS bus CB             | GPS +14V                   | 22759/16, 22 AWG                   | CB 2A      |
| 246  | GPS RS-232 Tx / GND      | TT21/TT22 pin 5 / pin 6    | M27500 shielded pair, 22-24 AWG    | -          |
| 247  | GPS GND                  | Panel ground bus           | 22759/16, 22 AWG                   | -          |
| 251  | TT21/TT22 TNC            | Transponder antenna        | RG-400 max 2.5 m, or lower loss    | -          |
| 261  | TY91 pins 23, 22, 15     | Pilot mic jack             | M27500 3-cond. shielded, 22-24 AWG | -          |
| 262  | TY91 pins 11, 10         | Pilot phone jack           | M27500 STP, 22-24 AWG              | -          |
| 281  | TY91 pins 21, 22, 14     | Passenger mic jack         | M27500 3-cond. shielded, 22-24 AWG | -          |
| 282  | TY91 pins 11, 10         | Passenger phone jack       | M27500 STP, 22-24 AWG              | -          |
| 291  | TY91 pin 15 / ground     | Pilot stick PTT            | M27500 STP, 22 AWG                 | -          |
| 292  | TY91 pin 14 / ground     | Passenger PTT (optional)   | M27500 STP, 22 AWG                 | -          |
| 293  | TY91 pin 17              | TY91 ground pin (in shell) | 22759/16, 22 AWG                   | -          |
| 301  | Battery +                | Master contactor           | 8-10 AWG (no starter)              | -          |
| 302  | Master contactor         | Main bus                   | 8-10 AWG                           | -          |
| 303  | Alternator / regulator   | Main bus                   | Per alternator/regulator manual    | Per manual |
| 304  | Battery + (contactor stud)| MASTER switch             | 22759/16, 20 AWG                   | Fuse 5A    |
| 305  | MASTER switch            | Master contactor coil      | 22759/16, 20 AWG                   | -          |
| 311  | Main bus CB              | COMMS switch               | 22759/16, 14 AWG                   | CB 10A     |
| 312  | COMMS switch             | COMMS bus                  | 22759/16, 14 AWG                   | -          |
| 313  | Main bus CB              | ENGINE/ELEC switch         | 22759/16, 14 AWG                   | CB 10A     |
| 314  | ENGINE/ELEC switch       | ENGINE/ELEC bus            | 22759/16, 14 AWG                   | -          |
| 321  | Panel ground bus         | Engine case ground         | 8-10 AWG                           | -          |
| 322  | Engine case ground       | Battery -                  | Ground strap / 8-10 AWG            | -          |
| 323  | Master contactor coil    | Panel ground bus           | 22759/16, 20 AWG                   | -          |

Lighting and fuel-system wiring are outside this reference setup; they use
the reserved groups 4xx and 6xx when added.

## Consequences

**Positive**
- One reviewed reference for builders and for task 00023 (user
  documentation), with pin-level detail for the Trig TY91/TC90 and
  TT21/TT22/TC20 taken from the manufacturer's installation manuals (linked
  in Context, local copies in the git-ignored `docs/manuals/`).
- Wire numbers link diagram, wire list, physical labels and fault reports;
  the first digit tells a technician which system a wire belongs to.
- Separate COMMS and ENGINE / ELEC switches let either group be isolated
  without losing the other; ignition is independent of all electrical
  switching.
- Makes the interfaces explicit that the engine monitor hardware must
  provide: DC-DC power input with protection, sensor ground pin, protected
  isolated RPM input, selectable CAN termination.

**Negative / trade-offs**
- The numbering scheme is project-specific; it is not the MIL-W-5088 /
  ATA-style alphanumeric wire coding used on certified aircraft and must be
  translated if the installation is documented to such a standard.
- Pin numbers depend on the Trig manual issues used here
  (TY91/TY92 issue AH, TT21/TT22 issue AQ). A newer manual issue must be
  checked against this ADR before wiring.
- Mermaid flowcharts are block diagrams; the pin tables carry the detail.
- The engine monitor pin-out (J1-J4) fixes requirements on the hardware
  design: J1 isothermal with the thermocouple converters, floating
  thermocouple inputs, separate power and sensor grounds, HV clearance and
  isolation for the P-lead input, parallel CAN ports with termination and
  shield jumpers. Changing the pin-out later means rebuilding harnesses, so
  it must be settled before the first PCB revision.
- D-sub connectors are not sealed; the unit is mounted on the cabin side of
  the firewall. Engine-bay connectors (probes, senders) are separate.
- The Arduino variant differs from the Raspberry Pi platform chosen in
  ADR-0001. This ADR only covers wiring, which is the same for both.

**Risks**
- Magneto wiring errors leave a live magneto with the switch OFF; the
  magneto ground check is mandatory after any change to 181-184 or 152.
- TT21/TT22 is destroyed by reversed power; check 231/232/233 before first
  power-up.
- Connecting the TC90 (211C) or TC20 (241C) power input to aircraft power
  damages the controller.

**Follow-up**
- Feed the J1-J4 pin-out and jumpers JP1/JP2 into the engine monitor
  hardware design (ADR-0003 sensor interface, ADR-0004 CAN interface).
- Reference this ADR and ADR-0008 from the installation manual (task 00023).
