// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine

    var evacuationPriority: Int {
        switch self {
        case .bridge:
            return 1
        case .medbay:
            return 2
        case .lab:
            return 3
        case .engine:
            return 4
        case .cargo:
            return 5
        }
    }
}

for deck in Deck.allCases {
    print("\(deck.rawValue): \(deck.evacuationPriority)")
}

enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let raw = min(mass / 500, AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: raw) ?? .green
    }
}

print(AlarmLevel.level(forTotalMass: 0))
print(AlarmLevel.level(forTotalMass: 940))
print(AlarmLevel.level(forTotalMass: 4000))


// MARK: Level 2 · The Manifest

enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)

    if parts.count == 3 && parts[0] == "crate" {
        if let id = Int(parts[1]), let massKg = Int(parts[2]) {
            return .crate(id: id, massKg: massKg)
        }
        return .unknown(raw: line)
    }

    if parts.count == 3 && parts[0] == "container" {
        if let massKg = Int(parts[2]) {
            return .container(code: parts[1], massKg: massKg)
        }
        return .unknown(raw: line)
    }

    if parts.count == 4 && parts[0] == "livestock" {
        if let count = Int(parts[2]), let massPerUnitKg = Int(parts[3]) {
            return .livestock(
                species: parts[1],
                count: count,
                massPerUnitKg: massPerUnitKg
            )
        }
        return .unknown(raw: line)
    }

    return .unknown(raw: line)
}

func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var totalMass = 0
var unknownCount = 0

for line in rawManifest {
    let entry = parseEntry(line)
    totalMass += mass(of: entry)

    if case .unknown = entry {
        unknownCount += 1
    }
}

let A = totalMass

print("Manifest total mass: \(A)")
print("Unknown manifest lines: \(unknownCount)")


// MARK: Level 3 · Crew Snapshots

struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen -= amount
        if oxygen < 0 {
            oxygen = 0
        }
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var rosterBuilder: [CrewSnapshot] = []

for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        rosterBuilder.append(
            CrewSnapshot(
                name: record.name,
                deck: deck,
                oxygen: record.oxygen
            )
        )
    } else {
        print("Warning: invalid deck '\(record.deck)' for \(record.name)")
    }
}

let crewRoster: [CrewSnapshot] = rosterBuilder

for member in crewRoster {
    print("Crew: \(member.name), \(member.deck.rawValue), oxygen \(member.oxygen)")
}

var rookie = CrewSnapshot.rookie(named: "Mira")
print("Rookie before revive: \(rookie.deck.rawValue), \(rookie.oxygen)")
rookie.reviveInMedbay()
print("Rookie after revive: \(rookie.deck.rawValue), \(rookie.oxygen)")

if !crewRoster.isEmpty {
    let original = crewRoster[0]
    var copied = original

    print("Copy demo before: original \(original.oxygen), copy \(copied.oxygen)")
    copied.breathe(10)
    print("Copy demo after: original \(original.oxygen), copy \(copied.oxygen)")
}

func changePlain(_ snapshot: CrewSnapshot) {
    var local = snapshot
    print("Plain function before: \(local.oxygen)")
    local.breathe(10)
    print("Plain function after: \(local.oxygen)")
}

if !crewRoster.isEmpty {
    let original = crewRoster[0]
    print("Original before plain function: \(original.oxygen)")
    changePlain(original)
    print("Original after plain function: \(original.oxygen)")
}

func changeInout(_ snapshot: inout CrewSnapshot) {
    print("Inout function before: \(snapshot.oxygen)")
    snapshot.breathe(10)
    print("Inout function after: \(snapshot.oxygen)")
}

if !crewRoster.isEmpty {
    var original = crewRoster[0]
    print("Original before inout: \(original.oxygen)")
    changeInout(&original)
    print("Original after inout: \(original.oxygen)")
}


// MARK: Level 4 · The Teleport Pod

final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant != nil || chargeLevel < 20 {
            return false
        }

        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let currentOccupant = occupant else {
            return nil
        }

        chargeLevel -= 20
        occupant = nil
        return currentOccupant
    }
}

func crew(named name: String) -> CrewSnapshot? {
    for member in crewRoster {
        if member.name == name {
            return member
        }
    }
    return nil
}

let pod = TeleportPod(id: "P-1", chargeLevel: 100)

if let timur = crew(named: "Timur") {
    print("Charge before Timur load: \(pod.chargeLevel)")
    print("Timur loaded: \(pod.load(timur))")
    print("Charge after Timur load: \(pod.chargeLevel)")
    let fired = pod.fire()
    print("Timur fire result: \(fired?.name ?? "nil")")
    print("Charge after Timur fire: \(pod.chargeLevel)")
}

if let dana = crew(named: "Dana") {
    print("Charge before Dana load: \(pod.chargeLevel)")
    print("Dana loaded: \(pod.load(dana))")
    print("Charge after Dana load: \(pod.chargeLevel)")
    let fired = pod.fire()
    print("Dana fire result: \(fired?.name ?? "nil")")
    print("Charge after Dana fire: \(pod.chargeLevel)")
}

if let nurlan = crew(named: "Nurlan") {
    print("Charge before Nurlan load: \(pod.chargeLevel)")
    print("Nurlan loaded: \(pod.load(nurlan))")
    print("Charge after Nurlan load: \(pod.chargeLevel)")
    let fired = pod.fire()
    print("Nurlan fire result: \(fired?.name ?? "nil")")
    print("Charge after Nurlan fire: \(pod.chargeLevel)")
}

print("Charge before empty fire: \(pod.chargeLevel)")
let emptyFire = pod.fire()
print("Empty fire result: \(emptyFire?.name ?? "nil")")
print("Charge after empty fire: \(pod.chargeLevel)")

let C = pod.chargeLevel

let secondPodReference = pod
print("Class before change: pod \(pod.chargeLevel), second reference \(secondPodReference.chargeLevel)")
secondPodReference.chargeLevel = 35
print("Class after change: pod \(pod.chargeLevel), second reference \(secondPodReference.chargeLevel)")

if !crewRoster.isEmpty {
    var firstSnapshot = crewRoster[0]
    var secondSnapshot = firstSnapshot

    print("Struct before change: first \(firstSnapshot.oxygen), second \(secondSnapshot.oxygen)")
    secondSnapshot.oxygen = 5
    print("Struct after change: first \(firstSnapshot.oxygen), second \(secondSnapshot.oxygen)")

    firstSnapshot.breathe(1)
    print("Struct extra print: first \(firstSnapshot.oxygen)")
}

// A struct copy creates a separate value, while class variables can point to the same object.


// MARK: Level 5 · Station Systems

final class Station {
    let callSign: String

    var hullIntegrity: Int {
        willSet {
            print("Hull integrity changing: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity < 0 {
                hullIntegrity = 0
            } else if hullIntegrity > 100 {
                hullIntegrity = 100
            }
        }
    }

    var oxygenByDeck: [Deck: Int]

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "Station \(callSign): hull \(hullIntegrity), total oxygen \(totalOxygen)"
    }()

    var totalOxygen: Int {
        var total = 0
        for (_, oxygen) in oxygenByDeck {
            total += oxygen
        }
        return total
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.isEmpty {
                return 0
            }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        self.oxygenByDeck = [:]

        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                oxygenByDeck[deck] = reading.oxygen
            } else {
                print("Skipping invalid deck reading: \(reading.deck)")
            }
        }
    }
}

let station = Station(callSign: "ALMA-7", hullIntegrity: 85)

let B = station.averageOxygen

print("Starting total oxygen: \(station.totalOxygen)")
print("Starting average oxygen: \(B)")

print(station.fullDiagnostics)
print(station.fullDiagnostics)

let untouchedStation = Station(callSign: "ALMA-8", hullIntegrity: 90)
print("Untouched station: \(untouchedStation.callSign)")
print("Untouched station hull: \(untouchedStation.hullIntegrity)")

station.averageOxygen = 60
print("Average oxygen after setter: \(station.averageOxygen)")
print("Total oxygen after setter: \(station.totalOxygen)")

station.hullIntegrity = 130
print("Hull after 130: \(station.hullIntegrity)")

station.hullIntegrity = -40
print("Hull after -40: \(station.hullIntegrity)")

station.hullIntegrity = 55
print("Hull after 55: \(station.hullIntegrity)")

// Assigning to the property inside didSet does not call the observers again, so the clamp does not loop.


// MARK: Level 6 · Incident Reports

/*
Report 1
Expected: every member in roster loses 10 oxygen.
Actual: roster does not change because member is a copy.
Rule: structs use value semantics and the for-in variable is a separate value.
Fix: modify the array element by index.
*/

var report1Roster = crewRoster
for index in report1Roster.indices {
    report1Roster[index].oxygen -= 10
}
print("Report 1 fixed oxygen: \(report1Roster[0].oxygen)")

/*
Report 2
Expected: changing podB does not change podA.
Actual: podA also changes because both variables reference the same class instance.
Rule: classes have reference semantics.
Fix: create a separate TeleportPod object instead of copying the reference.
*/

let report2PodA = TeleportPod(id: "A", chargeLevel: 100)
let report2PodB = TeleportPod(id: "B", chargeLevel: report2PodA.chargeLevel)
report2PodB.chargeLevel = 0
print("Report 2 fixed podA: \(report2PodA.chargeLevel)")
print("Report 2 fixed podB: \(report2PodB.chargeLevel)")

/*
Report 3
Expected: add() appends to entries.
Actual: it does not compile because a struct method cannot change stored properties unless the method is mutating.
Rule: value-type instance methods that modify self or its stored properties must be marked mutating.
Fix: add mutating before func.
*/

struct Logbook {
    var entries: [String] = []

    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

var logbook = Logbook()
logbook.add("Teleport started")
logbook.add("Teleport finished")
print("Report 3 fixed entries: \(logbook.entries)")

/*
Report 4
Expected: both assignments work because both variables were created with let.
Actual: snapshot.oxygen = 40 does not compile, but pod.chargeLevel = 10 does compile.
Rule: let on a struct freezes the whole value. let on a class freezes the reference, but mutable var properties of the object can still change.
Fix: use var for the CrewSnapshot when its properties must change.
*/

var report4Snapshot = CrewSnapshot.rookie(named: "Dana")
report4Snapshot.oxygen = 40

let report4Pod = TeleportPod(id: "B", chargeLevel: 50)
report4Pod.chargeLevel = 10

print("Report 4 snapshot oxygen: \(report4Snapshot.oxygen)")
print("Report 4 pod charge: \(report4Pod.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {

    // private blocks direct access to the stored entries from outside FlightRecorder.
    private var entries: [String] = []

    // private(set) blocks outside code from changing isSealed while still allowing it to be read.
    private(set) var isSealed = false

    // internal keeps this readable inside the module without exposing the stored array itself.
    internal var entryCount: Int {
        entries.count
    }

    // internal exposes only a formatted read-only view of the entries.
    internal var transcript: String {
        var result = ""

        for entry in entries {
            if result.isEmpty {
                result = entry
            } else {
                result += "\n\(entry)"
            }
        }

        return result
    }

    // internal allows outside code in this module to request a new entry, but the method controls whether it is accepted.
    internal func add(_ entry: String) {
        if isSealed {
            return
        }

        entries.append(entry)
    }

    // internal allows sealing from outside the type, but there is no method to unseal it.
    internal func seal() {
        isSealed = true
    }

    // fileprivate allows the free audit function in this file to use this helper, but blocks access from other files.
    fileprivate func auditText() -> String {
        return transcript
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    return recorder.auditText()
}

let recorder = FlightRecorder()

recorder.add("System started")
recorder.add("Teleport online")

print("Recorder entry count: \(recorder.entryCount)")
print("Recorder transcript:\n\(recorder.transcript)")

recorder.seal()
recorder.add("This must not be added")

print("Recorder sealed: \(recorder.isSealed)")
print("Recorder entry count after seal: \(recorder.entryCount)")
print("Audit transcript:\n\(auditTranscript(of: recorder))")

// recorder.entries.removeAll()
// Error: 'entries' is inaccessible due to 'private' protection level.

// recorder.isSealed = false
// Error: Cannot assign to property: 'isSealed' setter is inaccessible.


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"

print("INTEGRITY CODE: \(integrityCode)")


// MARK: - ================= DEFENSE QUESTIONS =================

/*
1. Why did CrewSnapshot get an initializer for free while TeleportPod did not?

CrewSnapshot is a struct with stored properties, so Swift automatically gives it a memberwise initializer.
TeleportPod is a class, so I wrote its initializer myself.

2. What does mutating do to self, and why do classes never need it?

mutating allows a struct method to change its properties or replace self with a new value.
Classes do not need mutating because class instances use reference semantics and their var properties can be changed directly.

3. In Report 4 both values are let. What exactly does let freeze for a struct, and what does it freeze for a class?

For a struct, let freezes the whole value, so its var properties cannot be changed.
For a class, let freezes only the reference, so the variable cannot point to another object, but var properties of that object can still change.

4. Why must a lazy property be var? When does lazy change behaviour, not just performance?

A lazy property must be var because its value is not created during initialization. It is assigned later on first access.
Lazy changes behaviour when creating the value has a side effect. For example, fullDiagnostics prints "Running full scan..." only when the property is accessed.

5. private vs fileprivate: where in your FlightRecorder would private be too strict?

The auditText() helper is used by the free function auditTranscript in the same file.
If auditText() were private, that free function could not call it. fileprivate allows access from anywhere in the same file.
*/
