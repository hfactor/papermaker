// Daily page component - single day per page

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *

#let daily-page(config, year, month, day) = [
  let primary-color = rgb(config.primaryColor)
  let month-name = get-month-name(month, format: "full")
  let dow = day-of-week(year, month, day)
  
  let day-names = if config.startDay == "sunday" {
    ("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
  } else {
    ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
  }
  
  let day-name = day-names.at(dow)
  let is-wknd = is-weekend(year, month, day, start-day: config.startDay)
  let wk-num = week-number(year, month, day)
  
  // Set page label
  #page-label("day", year, month: month, day: day)
  
  pagebreak(weak: true)
  
  // Header with breadcrumb navigation
  let nav-items = (
    nav-link([Year], "year", year, color: primary-color),
  )
  
  if config.pages.month {
    nav-items.push(
      nav-link([#month-name], "month", year, month: month, color: primary-color)
    )
  }
  
  if config.pages.week {
    // Calculate week start day (simplified)
    let week-start = calc.max(1, day - dow)
    nav-items.push(
      nav-link([Week #str(wk-num)], "week", year, week: wk-num, color: primary-color)
    )
  }
  
  align(center)[
    #breadcrumb(nav-items, color: primary-color)
  ]
  
  v(1em)
  divider(color: primary-color)
  v(1em)
  
  // Date header
  align(center)[
    #text(size: 20pt, weight: "bold", fill: primary-color)[
      #day-name, #month-name #str(day), #str(year)
    ]
    #if is-wknd {
      v(0.3em)
      text(size: 10pt, fill: rgb("#999"))[Weekend]
    }
  ]
  
  v(1.5em)
  divider(color: rgb("#e0e0e0"))
  v(1.5em)
  
  // Main content area with paper style
  let paper-color = rgb("#e8e8e8")
  
  if config.paperStyle == "grid" {
    // Grid pattern
    let grid-size = 5mm
    for row in range(25) {
      grid(
        columns: (grid-size,) * 35,
        gutter: 0pt,
        ..range(35).map(_ => {
          rect(
            width: grid-size,
            height: grid-size,
            stroke: 0.3pt + paper-color,
            fill: none
          )
        })
      )
    }
  } else if config.paperStyle == "dot" {
    // Dot pattern
    let dot-spacing = 5mm
    for row in range(25) {
      v(dot-spacing)
      grid(
        columns: (dot-spacing,) * 35,
        gutter: 0pt,
        ..range(35).map(_ => {
          align(center + horizon)[
            #circle(radius: 0.5pt, fill: paper-color)
          ]
        })
      )
    }
  } else if config.paperStyle == "line" {
    // Horizontal lines
    for row in range(30) {
      v(6mm)
      line(length: 100%, stroke: 0.3pt + paper-color)
    }
  } else {
    // Plain - just empty space
    v(1fr)
  }
]
