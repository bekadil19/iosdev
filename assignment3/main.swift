// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          value >= 0 || parts.0 == "TEMP"
    else {
        return nil
    }

    return (sensor: parts.0, value: value)
}

print(parseReading("O2:87") as Any)
print(parseReading("RAD:-1") as Any)


// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0

    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }

    return (valid, invalidCount)
}

let parsedLog = parseLog(rawLog)
let A = parsedLog.invalidCount

print("Valid:", parsedLog.valid)
print("Invalid count:", A)


// 2.1
func select(
    _ readings: [Reading],
    where isIncluded: (Reading) -> Bool
) -> [Reading] {
    var result: [Reading] = []

    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }

    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []

    for reading in readings {
        result.append(reading.value)
    }

    return result
}

let o2Readings = select(parsedLog.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)

print("O2 readings:", o2Readings)
print("O2 values:", o2Values)


// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else {
        return nil
    }

    var minimum = first
    var maximum = first
    var sum = 0

    for value in values {
        if value < minimum {
            minimum = value
        }

        if value > maximum {
            maximum = value
        }

        sum += value
    }

    let average = Double(sum) / Double(values.count)

    return (minimum, maximum, average)
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) as Any)
print(stats() as Any)

var B = 0

if let o2Stats = stats(of: o2Values) {
    B = Int(o2Stats.average)
}

print("B:", B)


// 2.3
let sort1 = parsedLog.valid.sorted(
    by: { (a: Reading, b: Reading) -> Bool in
        return a.value > b.value
    }
)

let sort2 = parsedLog.valid.sorted(
    by: { a, b in
        return a.value > b.value
    }
)

let sort3 = parsedLog.valid.sorted(
    by: { a, b in
        a.value > b.value
    }
)

let sort4 = parsedLog.valid.sorted(
    by: { $0.value > $1.value }
)

let sort5 = parsedLog.valid.sorted {
    $0.value > $1.value
}

func sameReadings(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else {
        return false
    }

    for i in 0..<a.count {
        if a[i].sensor != b[i].sensor || a[i].value != b[i].value {
            return false
        }
    }

    return true
}

let allSortsMatch =
    sameReadings(sort1, sort2) &&
    sameReadings(sort2, sort3) &&
    sameReadings(sort3, sort4) &&
    sameReadings(sort4, sort5)

print("All sorts match:", allSortsMatch)


// 3.1
func heatUp(_ t: Int) -> Int {
    t + 5
}

func coolDown(_ t: Int) -> Int {
    t - 3
}

func hold(_ t: Int) -> Int {
    t
}

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

print("Heat:", heatUp(10))
print("Cool:", coolDown(30))
print("Hold:", hold(20))


// 3.2
func runUntilStable(
    from start: Int,
    maxSteps: Int = 10
) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temperature = start
    var steps = 0

    while (temperature < 18 || temperature > 24) && steps < maxSteps {
        let protocolFunction = chooseProtocol(for: temperature)
        temperature = protocolFunction(temperature)
        steps += 1
    }

    let stable = temperature >= 18 && temperature <= 24

    return (temperature, steps, stable)
}

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))

let tempReadings = select(parsedLog.valid) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)

var C = 0

if let tempStats = stats(of: tempValues) {
    C = runUntilStable(from: tempStats.min).steps
}

print("C:", C)


// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print("Timur oxygen:", oxygenLevel(of: crew[0]) as Any)
print("Dana oxygen:", oxygenLevel(of: crew[1]) as Any)


// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }

    if level < 20 {
        return "\(member.name): \(level)% CRITICAL"
    } else {
        return "\(member.name): \(level)% OK"
    }
}

for member in crew {
    print(status(of: member))
}


// 4.3
@discardableResult
func transferOxygen(
    from source: inout Int,
    to target: inout Int,
    amount: Int
) -> Int {
    guard amount > 0 else {
        return 0
    }

    let availableSpace = 100 - target
    let transferred = min(amount, source, availableSpace)

    guard transferred > 0 else {
        return 0
    }

    source -= transferred
    target += transferred

    return transferred
}

if let labTank = lab.oxygenTank,
   let habTank = hab.oxygenTank {
    let transferred = transferOxygen(
        from: &labTank.level,
        to: &habTank.level,
        amount: 30
    )

    print("Transferred:", transferred)
}

let D = hab.oxygenTank?.level ?? 0

print("D:", D)


// 4.4
func evacuationOrder(
    _ names: String...,
    roster: [String: CrewMember]
) -> [String] {
    var found: [CrewMember] = []

    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }

        found.append(member)
    }

    found.sort {
        $0.priority < $1.priority
    }

    var result: [String] = []

    for member in found {
        result.append(member.name)
    }

    return result
}

print(
    evacuationOrder(
        "Dana",
        "Ghost",
        "Aigerim",
        "Timur",
        roster: roster
    )
)


// 5
func reportOxygenFixed(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }

    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else {
            continue
        }

        if level < 20 {
            return member.name
        }
    }

    return nil
}

print(reportOxygenFixed(for: crew[0]))
print(reportOxygenFixed(for: crew[1]))

let testModule1 = Module(
    name: "Test1",
    oxygenTank: Tank(level: 10)
)

let testModule2 = Module(
    name: "Test2",
    oxygenTank: Tank(level: 5)
)

let testCrew = [
    CrewMember(
        name: "First",
        role: "Test",
        priority: 1,
        module: testModule1
    ),
    CrewMember(
        name: "Second",
        role: "Test",
        priority: 2,
        module: testModule2
    )
]

print("First critical:", firstCritical(in: testCrew) ?? "none")


// Finale
let launchCode = "\(A)-\(B)-\(C)-\(D)"

print("LAUNCH CODE: \(launchCode)")


// Bonus
func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var counter = 0

    return { level in
        if level < threshold {
            counter += 1
            print("Alarm #\(counter)")
            return true
        }

        return false
    }
}

let alarm = makeAlarm(threshold: 20)

print(alarm(12))
print(alarm(40))
print(alarm(5))
