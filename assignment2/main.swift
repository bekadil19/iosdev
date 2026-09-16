import Foundation

var fruits = ["Apple", "Banana", "Orange", "Mango", "Cherry"]
print(fruits[2])

var favoriteNumbers: Set<Int> = [7, 10, 17, 25]
favoriteNumbers.insert(30)
print(favoriteNumbers)

var programmingLanguages = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995
]
print(programmingLanguages["Swift"]!)

var colors = ["Red", "Blue", "Green", "Black"]
colors[1] = "Yellow"
print(colors)

let set1: Set<Int> = [1, 2, 3, 4]
let set2: Set<Int> = [3, 4, 5, 6]
let commonNumbers = set1.intersection(set2)
print(commonNumbers)

var studentScores = [
    "Bekadil": 85,
    "Nuradil": 90,
    "Ali": 78
]
studentScores.updateValue(95, forKey: "Bekadil")
print(studentScores)

let array1 = ["apple", "banana"]
let array2 = ["cherry", "date"]
let mergedArray = array1 + array2
print(mergedArray)

var countries = [
    "Kazakhstan": 20_000_000,
    "USA": 340_000_000,
    "Japan": 124_000_000
]
countries["Germany"] = 84_000_000
print(countries)

let animals1: Set<String> = ["cat", "dog"]
let animals2: Set<String> = ["dog", "mouse"]
let unionSet = animals1.union(animals2)
let finalSet = unionSet.subtracting(animals2)
print(finalSet)

let studentGrades = [
    "Bekadil": [85, 90, 95],
    "Nuradil": [88, 92, 97],
    "Ali": [75, 80, 85]
]
print(studentGrades["Bekadil"]![1])

