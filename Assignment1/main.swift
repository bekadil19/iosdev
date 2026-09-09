import Foundation

let firstName: String = "Bekadil"
let lastName: String = "Mustafa"
let birthYear: Int = 2005
let currentYear: Int = 2026
let age: Int = currentYear - birthYear
let isStudent: Bool = true
let height: Double = 1.82

let hobby: String = "fishing"
let secondHobby: String = "football"
let thirdHobby: String = "tennis"
let numberOfHobbies: Int = 3
let favoriteNumber: Int = 17
let isHobbyCreative: Bool = false

let futureGoals: String = "Become a strong specialist and get a high salary job"

let lifeStory = """
My name is \(firstName) \(lastName). I am \(age) years old and I was born in \(birthYear).
I am currently a student and my height is \(height) meters.
My hobbies are \(hobby), \(secondHobby), and \(thirdHobby).
I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber).
In the future, I want to \(futureGoals.lowercased()).
"""
print(lifeStory)
