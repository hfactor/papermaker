// Weekly spread component - 7-day layout

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *

#let week-spread(config, year, month, start-day-num) = [
  let primary-color = rgb(config.primaryColor)
  let weekend-color = rgb(config.weekendColor)
  let month-name = get-month-name(month, format: "abbreviated")
  let num-days = days-in-month(year, month)
  let wk-num = week-number(year, month, start-day-num)
  
  // Calculate the 7 days in this week
  let week-days = ()
  let current-month = month
  let current-year = year
  
  for i in range(7) {
    let day = start-day-num + i
    
    // Handle month overflow
    if day > num-days {
      current-month = if month == 12 { 1 } else { month + 1 }
      current-year = if month == 12 { year + 1 } else { year }
      day = day - num-days
    }
    
    week-days.push((
      year: current-year,
      month: current-month,
      day: day,
      is-current-month: current-month == month
    ))
  }
  
  // Set page label
  #page-label("week", year, week: wk-num)
  
  pagebreak(weak: true)
  
  // Header
  nav-header(
    nav-link([← #month-name], "month", year, month: month, color: primary-color),
    [Week #str(wk-num) - #str(year)],
    color: primary-color
  )
  
  v(1em)
  divider(color: primary-color)
  v(1.5em)
  
  // Vertical week layout
  for day-info in week-days {
    if day-info.is-current-month {
      let day = day-info.day
      let is-wknd = is-weekend(year, month, day, start-day: config.startDay)
      let cell-bg = if is-wknd { weekend-color } else { white }
      let dow = day-of-week(year, month, day)
      
      let day-names = if config.startDay == "sunday" {
        ("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
      } else {
        ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
      }
      
      rect(
        width: 100%,
        height: 100pt,
        fill: cell-bg,
        stroke: 1pt + rgb("#d0d0d0"),
        inset: 10pt
      )[
        #grid(
          columns: (auto, 1fr),
          gutter: 15pt,
          
          // Date header
          align(horizon)[
            #if config.pages.daily {
              nav-link(
                text(size: 18pt, weight: "bold")[
                  #day-names.at(dow) #str(day)
                ],
                "day",
                year,
                month: month,
                day: day,
                color: primary-color
              )
            } else {
              text(size: 18pt, weight: "bold", fill: primary-color)[
                #day-names.at(dow) #str(day)
              ]
            }
          ],
          
          // Space for notes (with paper style)
          align(horizon)[
            #if config.paperStyle != "plain" {
              rect(
                width: 100%,
                height: 80pt,
                stroke: 0.5pt + rgb("#e0e0e0"),
                inset: 5pt
              )[
                // Paper background would go here
              ]
            }
          ]
        )
      ]
      
      v(8pt)
    }
  }
]
