// Month spread component - detailed monthly calendar

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *

#let month-spread(config, month) = [
  let year = config.year
  let primary-color = rgb(config.primaryColor)
  let weekend-color = rgb(config.weekendColor)
  let month-name = get-month-name(month, format: "full")
  let first-day = first-day-of-month(year, month)
  let num-days = days-in-month(year, month)
  let quarter = get-quarter(month)
  
  // Adjust first day based on start-day config
  let offset = if config.startDay == "sunday" {
    calc.rem(first-day + 1, 7)
  } else {
    first-day
  }
  
  // Set page label
  #page-label("month", year, month: month)
  
  pagebreak(weak: true)
  
  // Header with back link
  let back-link = if config.pages.quarter {
    nav-link([← Q#str(quarter)], "quarter", year, quarter: quarter, color: primary-color)
  } else {
    nav-link([← Year], "year", year, color: primary-color)
  }
  
  nav-header(
    back-link,
    [#month-name #str(year)],
    color: primary-color
  )
  
  v(1em)
  divider(color: primary-color)
  v(1.5em)
  
  // Day headers
  let headers = if config.startDay == "sunday" {
    ("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
  } else {
    ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
  }
  
  grid(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    gutter: 8pt,
    ..headers.map(h => align(center)[
      #text(size: 11pt, weight: "bold", fill: primary-color)[#h]
    ])
  )
  
  v(8pt)
  
  // Calendar grid
  grid(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    rows: (auto,) * 6,  // Max 6 weeks
    gutter: 8pt,
    
    // Empty cells before first day
    ..range(offset).map(_ => rect(
      width: 100%,
      height: 80pt,
      stroke: 0.5pt + rgb("#e0e0e0"),
      fill: rgb("#fafafa")
    )[]),
    
    // Days of month
    ..range(1, num-days + 1).map(day => {
      let is-wknd = is-weekend(year, month, day, start-day: config.startDay)
      let cell-bg = if is-wknd { weekend-color } else { white }
      let wk-num = week-number(year, month, day)
      
      rect(
        width: 100%,
        height: 80pt,
        fill: cell-bg,
        stroke: 0.5pt + rgb("#d0d0d0"),
        inset: 6pt
      )[
        // Day number
        #if config.pages.daily {
          nav-link(
            text(size: 14pt, weight: "bold")[#str(day)],
            "day",
            year,
            month: month,
            day: day,
            color: primary-color
          )
        } else {
          text(size: 14pt, weight: "bold", fill: primary-color)[#str(day)]
        }
        
        // Week number (small, in corner)
        #if day <= 7 {
          place(
            top + right,
            dx: -2pt,
            dy: -2pt,
            text(size: 7pt, fill: rgb("#999"))[W#str(wk-num)]
          )
        }
      ]
    })
  )
]
