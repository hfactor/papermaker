// Date utility functions for calendar generation

// Month names in different formats
#let month-names = (
  full: ("January", "February", "March", "April", "May", "June", 
         "July", "August", "September", "October", "November", "December"),
  abbreviated: ("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"),
  single: ("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D")
)

// Get month name in specified format
#let get-month-name(month, format: "full") = {
  month-names.at(format).at(month - 1)
}

// Check if a year is a leap year
#let is-leap-year(year) = {
  (calc.rem(year, 4) == 0 and calc.rem(year, 100) != 0) or calc.rem(year, 400) == 0
}

// Get number of days in a month
#let days-in-month(year, month) = {
  let days = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  if month == 2 and is-leap-year(year) {
    29
  } else {
    days.at(month - 1)
  }
}

// Calculate day of week (0 = Monday, 6 = Sunday)
// Using Zeller's congruence algorithm
#let day-of-week(year, month, day) = {
  let y = year
  let m = month
  
  // Adjust for January and February
  if m < 3 {
    m = m + 12
    y = y - 1
  }
  
  let k = calc.rem(y, 100)
  let j = calc.quo(y, 100)
  
  let h = calc.rem(
    day + calc.quo(13 * (m + 1), 5) + k + calc.quo(k, 4) + calc.quo(j, 4) - 2 * j,
    7
  )
  
  // Convert to Monday = 0, Sunday = 6
  calc.rem((h + 5), 7)
}

// Get first day of month (0 = Monday, 6 = Sunday)
#let first-day-of-month(year, month) = {
  day-of-week(year, month, 1)
}

// Calculate ISO week number
#let week-number(year, month, day) = {
  // Simplified week number calculation
  let jan1 = day-of-week(year, 1, 1)
  let days-since-jan1 = 0
  
  // Count days from January 1st
  for m in range(1, month) {
    days-since-jan1 = days-since-jan1 + days-in-month(year, m)
  }
  days-since-jan1 = days-since-jan1 + day
  
  // Calculate week number
  calc.quo(days-since-jan1 + jan1 - 1, 7) + 1
}

// Get all weeks in a month
#let weeks-in-month(year, month) = {
  let first-day = first-day-of-month(year, month)
  let num-days = days-in-month(year, month)
  
  // Calculate number of weeks needed
  calc.quo(first-day + num-days - 1, 7) + 1
}

// Get date range for a week
#let week-dates(year, week-num) = {
  // Simplified: returns approximate dates for a week
  // This would need more complex logic for exact ISO week dates
  (year: year, week: week-num)
}

// Check if a day is a weekend (Saturday or Sunday)
#let is-weekend(year, month, day, start-day: "monday") = {
  let dow = day-of-week(year, month, day)
  
  if start-day == "monday" {
    dow == 5 or dow == 6  // Saturday or Sunday
  } else {
    dow == 6 or dow == 0  // Sunday or Monday (if week starts Sunday)
  }
}

// Get quarter for a month (1-4)
#let get-quarter(month) = {
  calc.quo(month - 1, 3) + 1
}

// Get months in a quarter
#let quarter-months(quarter) = {
  let start = (quarter - 1) * 3 + 1
  (start, start + 1, start + 2)
}
