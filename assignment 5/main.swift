// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Completed.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// A class is used because the same PowerCell object can be shared and its charge must change through reference semantics.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        return charge
    }

    func spend(_ amount: Int) -> Bool {
        if amount <= 0 || charge < amount {
            return false
        }

        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        if amount <= 0 {
            return
        }

        charge = min(charge + amount, 100)
    }
}

let cell = PowerCell(charge: 40)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int {
        return 10
    }

    var statusLine: String {
        let level = cell.level()
        return "\(id): \(level)% \(level.powerBar)"
    }

    func performTask() -> Int {
        return 0
    }

    // final prevents subclasses from changing the common shift sequence: spend power first, then perform the task.
    final func runOnce() -> Int {
        guard cell.spend(powerCost) else {
            return 0
        }

        return performTask()
    }
}

final class WelderDrone: Drone {
    override var powerCost: Int {
        return 25
    }

    override func performTask() -> Int {
        return 40
    }

    func weldSeam() -> String {
        return "\(id) welded a hull seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int {
        return 10
    }

    override var statusLine: String {
        return super.statusLine + " [scanner]"
    }

    override func performTask() -> Int {
        return 15
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int {
        return 20
    }

    override func performTask() -> Int {
        return 25
    }
}

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let powerCell = PowerCell(charge: charge)

    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: powerCell)
    case "scanner":
        return ScannerDrone(id: id, cell: powerCell)
    case "cargo":
        return CargoDrone(id: id, cell: powerCell)
    default:
        return nil
    }
}

var fleet: [Drone] = []

for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: skipped unknown drone kind '\(record.kind)' with id \(record.id).")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    if rounds <= 0 {
        return 0
    }

    var totalWork = 0

    for _ in 0..<rounds {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }

    return totalWork
}

let A = runShift(fleet, rounds: 3)

print("\nAfter 3-round shift:")
for drone in fleet {
    print(drone.statusLine)
}

var B = 0
var C = 0

for drone in fleet {
    B += drone.cell.level()

    if drone.cell.level() >= drone.powerCost {
        C += 1
    }
}

print("Total work units: \(A)")
print("Remaining drone charge total: \(B)")
print("Drones able to run one more task: \(C)")


// MARK: Level 4 · Diagnostics

protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// A class does not need the `mutating` keyword because class instances have reference semantics.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String {
        return id
    }

    var statusCode: Int {
        return healthStatus(for: cell.level())
    }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    var chargeLevel: Int

    var statusCode: Int {
        return healthStatus(for: chargeLevel)
    }

    mutating func recharge(by amount: Int) {
        if amount <= 0 {
            return
        }

        chargeLevel = min(chargeLevel + amount, 100)
    }
}

func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = ""

    for component in components {
        if !report.isEmpty {
            report += "\n"
        }
        report += component.diagnose()
    }

    return report
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(componentID: record.id, chargeLevel: record.charge))
}

// [Drone] cannot hold SensorModule values because sensors are structs and are not subclasses of Drone; [Diagnosable] can hold both.
var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}

print("\nDiagnostics before adding beacon:")
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

extension Diagnosable {
    // The Health Rule exists only here.
    func healthStatus(for charge: Int) -> Int {
        if charge < 20 {
            return 2
        } else if charge < 50 {
            return 1
        } else {
            return 0
        }
    }

    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }
}

extension LegacyBeacon: Diagnosable {
    var componentID: String {
        return name
    }

    var statusCode: Int {
        return healthStatus(for: signalStrength)
    }

    func diagnose() -> String {
        return "LEGACY BEACON \(componentID): code \(statusCode)"
    }
}

components.append(beacon)

print("\nDiagnostics including beacon:")
print(diagnosticsReport(components))

var D = 0
for component in components {
    D += component.statusCode
}

extension Int {
    var powerBar: String {
        let clamped = Swift.min(Swift.max(self, 0), 100)
        let filled = clamped / 10
        var bar = ""

        for position in 0..<10 {
            if position < filled {
                bar += "#"
            } else {
                bar += "."
            }
        }

        return bar
    }
}


// MARK: Level 6 · Incident Reports

/*
 Report 1
 --------
 Expected:
 PatchDrone should replace Drone.performTask() and return 30 work units.

 Actual:
 It does not compile because performTask() already exists in Drone and the subclass implementation is missing `override`.

 Rule:
 A subclass must mark a method with `override` when it replaces an inherited method.

 Fix:
 class PatchDrone: Drone {
     override func performTask() -> Int {
         return 30
     }
 }


 Report 2
 --------
 Expected:
 HeavyWelder should inherit from WelderDrone and replace runOnce() so it returns 999.

 Actual:
 It does not compile. WelderDrone is final, so it cannot be subclassed. Also, Drone.runOnce() is final, so it cannot be overridden.

 Rule:
 `final` on a class prevents subclassing. `final` on a method prevents overriding that method.

 Fix:
 Do not override runOnce(). Create another Drone subclass and override only powerCost and performTask(), while keeping the final runOnce() ritual unchanged.


 Report 3
 --------
 Expected:
 Because the object inside the array is a WelderDrone, first.weldSeam() should work.

 Actual:
 It does not compile because `first` has the static type Drone, and Drone does not declare weldSeam().

 Rule:
 The compiler only allows members known by the variable's static type. A subclass-specific member requires a cast.

 Fix:
 if let welder = first as? WelderDrone {
     print(welder.weldSeam())
 }

 `as?` returns an optional because the runtime cast can fail if the object is not actually a WelderDrone.


 Report 4
 --------
 Expected:
 The author expects "thruster T-1".

 Actual:
 It compiles but prints "generic component" when the value is used as Labelled.

 Rule:
 label() is not a protocol requirement; it exists only in the protocol extension. Therefore the extension implementation is selected for a value whose static type is the protocol existential.

 Fix:
 Add the method requirement to the protocol:

 protocol Labelled {
     var componentID: String { get }
     func label() -> String
 }

 Then Thruster.label() becomes the protocol witness and "thruster T-1" is used through [Labelled].
*/


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("\nMISSION CODE: \(missionCode)")


// MARK: Bonus

/*
 Bonus idea 1 — runtime failure:
 Give Drone an implementation such as fatalError("Drone is abstract; use a subclass") in a method that every real drone must override.
 This makes direct use of Drone fail at runtime.

 Bonus idea 1 — compile-time prevention:
 Replace the Drone base class with a protocol. Then there is no concrete Drone type that can be instantiated directly.

 Bonus comparison:
 The class design is useful when all drones should share implementation and reference-type state such as the same mutable PowerCell object.
 A protocol-based design is more flexible because structs and classes can conform, but shared mutable state needs to be modeled explicitly rather than inherited from one base class.
*/


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the keyword, while a struct must write it?

    Classes have reference semantics. Changing a class instance's stored state does not replace the variable holding the reference,
    so class methods do not use `mutating`. Structs have value semantics, so a method that changes stored properties must be marked `mutating`.

 2. One thing inheritance does that protocols cannot, and one thing protocols do that inheritance cannot:

    Inheritance lets a subclass reuse stored properties and implemented behavior from one superclass.
    A protocol can create one common interface for unrelated types, including both classes and structs.

 3. What does `final` prevent, and what did it protect in runOnce()?

    `final` prevents further subclassing of a class or overriding of a method/property.
    Making runOnce() final protects the required shift sequence so subclasses cannot skip the battery check or change the order of the ritual.

 4. In Report 4, why did the protocol extension's method win?

    Because label() was not declared as a requirement in Labelled. It existed only in the protocol extension,
    so when the value was stored as Labelled, Swift selected the extension implementation instead of dynamically dispatching to Thruster.label().
*/
