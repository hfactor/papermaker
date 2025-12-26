// Date utility functions for calendar generation

// Month names in different formats
#let month-names = (
  full: ("January", "February", "March", "April", "May", "June", 
         "July", "August", "September", "October", "November", "December"),
  abbreviated: ("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"),
  first: ("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D")
)

// Get month name in specified format
#let get-month-name(month, format: "full") = {
  month-names.at(format, default: month-names.full).at(month - 1)
}

// Get day name by index (0=Mon, 6=Sun)
#let get-day-name(dow, format: "full") = {
  let names = (
    full: ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"),
    abbreviated: ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
    first: ("M", "T", "W", "T", "F", "S", "S")
  )
  names.at(format, default: names.full).at(dow)
}

// Get day names starting from a specific day index (0-6)
#let get-day-headers(start-day: 0, format: "full") = {
  let rotated = ()
  for i in range(7) {
    rotated.push(calc.rem(start-day + i, 7))
  }
  rotated.map(idx => get-day-name(idx, format: format))
}

// Get start day index from config (supports 0-6 or "monday"-"sunday")
#let get-start-day-idx(config) = {
  let val = config.week.at("startDay", default: "monday")
  if type(val) == int {
    return val
  }
  
  if type(val) != str {
    return 0
  }
  
  let days = (
    "monday": 0, "mon": 0,
    "tuesday": 1, "tue": 1,
    "wednesday": 2, "wed": 2,
    "thursday": 3, "thu": 3,
    "friday": 4, "fri": 4,
    "saturday": 5, "sat": 5,
    "sunday": 6, "sun": 6
  )
  
  days.at(lower(val), default: 0)
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

// Calculate ISO week number and year
#let week-number(year, month, day) = {
  let d = datetime(year: year, month: month, day: day)
  let dow = day-of-week(year, month, day)
  let nearest-thursday = d + duration(days: 3 - dow)
  
  let iso-year = nearest-thursday.year()
  let jan1-of-iso-year = datetime(year: iso-year, month: 1, day: 1)
  
  // Find the Monday of week 1
  let jan4 = datetime(year: iso-year, month: 1, day: 4)
  let jan4-dow = day-of-week(iso-year, 1, 4)
  let week1-monday = jan4 - duration(days: jan4-dow)
  
  let days-diff = (nearest-thursday - week1-monday).days()
  let wk = calc.quo(days-diff, 7) + 1
  
  (year: iso-year, week: wk)
}

// Get the date of a Monday for a given ISO week
#let date-from-iso-week(year, week-num) = {
  // Find Jan 4th of the year (always in week 1)
  let jan4 = datetime(year: year, month: 1, day: 4)
  let jan4-dow = day-of-week(year, 1, 4)
  
  // Find Monday of Week 1
  let week1-monday = jan4 - duration(days: jan4-dow)
  
  week1-monday + duration(days: (week-num - 1) * 7)
}

// Get total ISO weeks in a year (52 or 53)
#let weeks-in-year(year) = {
  // A year has 53 weeks if Dec 28 is in week 53
  week-number(year, 12, 28).week
}

// Get date range for a week (Monday to Sunday)
#let week-range-dates(year, week-num) = {
  let start-date = date-from-iso-week(year, week-num)
  let end-date = start-date + duration(days: 6)
  
  (start: start-date, end: end-date)
}

// Check if a day is a weekend
#let is-weekend(year, month, day, start-day: 0, config: none) = {
  let dow = day-of-week(year, month, day)
  
  if config != none {
    let is-sat = dow == 5
    let is-sun = dow == 6
    let is-fri = dow == 4
    
    let type = config.planner.at("weekendType", default: "sat-sun")
    if type == "sat-sun" { return is-sat or is-sun }
    if type == "fri-sat" { return is-fri or is-sat }
    // Custom case - default to Sat/Sun for now
    return is-sat or is-sun
  }
  
  // Default to Sat/Sun
  dow == 5 or dow == 6
}

// Get list of (year, month) pairs for a given range
#let month-list(start-year, start-month, count) = {
  let result = ()
  for i in range(count) {
    let m = start-month + i
    let y = start-year + calc.quo(m - 1, 12)
    let actual-m = calc.rem(m - 1, 12) + 1
    result.push((year: y, month: actual-m))
  }
  result
}

// Get list of unique ISO weeks that touch a list of months
#let week-list(month-data-list) = {
  let result = ()
  let seen = (:)
  
  for item in month-data-list {
    let year = item.year
    let month = item.month
    let num-days = days-in-month(year, month)
    
    // Check every Monday in the month
    for d in range(1, num-days + 1) {
      let dow = day-of-week(year, month, d)
      if dow == 0 or d == 1 or d == num-days { // Start of week, start of month, or end of month
        let wk-data = week-number(year, month, d)
        let key = str(wk-data.year) + "-" + str(wk-data.week)
        if seen.at(key, default: false) == false {
          result.push(wk-data)
          seen.insert(key, true)
        }
      }
    }
  }
  result
}

// Get quarter for a month (1-4)
#let get-quarter(month, fiscal-offset: 0) = {
  let m = month - fiscal-offset
  if m <= 0 { m += 12 }
  calc.quo(m - 1, 3) + 1
}

// Get months in a quarter
#let quarter-months(quarter, fiscal-offset: 0) = {
  let start = (quarter - 1) * 3 + 1 + fiscal-offset
  let res = ()
  for i in range(3) {
    let m = start + i
    while m > 12 { m -= 12 }
    while m < 1 { m += 12 }
    res.push(m)
  }
  res
}

// Format number as two digits (DD)
#let fmt-dd(num) = {
  if num < 10 { "0" + str(num) } else { str(num) }
}
