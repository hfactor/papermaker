// Quarter spread component - 3-month overview per quarter

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *

#let quarter-spread(config, quarter) = [
  let year = config.year
  let primary-color = rgb(config.primaryColor)
  let weekend-color = rgb(config.weekendColor)
  let months = quarter-months(quarter)
  
  // Set page label
  #page-label("quarter", year, quarter: quarter)
  
  pagebreak(weak: true)
  
  // Header with back link
  nav-header(
    nav-link([← Year], "year", year, color: primary-color),
    [Quarter #str(quarter) - #str(year)],
    color: primary-color
  )
  
  v(1em)
  divider(color: primary-color)
  v(1em)
  
  // 3-month grid
  grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 15pt,
    
    ..months.map(month => {
      let month-name = get-month-name(month, format: config.monthFormat)
      let first-day = first-day-of-month(year, month)
      let num-days = days-in-month(year, month)
      
      // Adjust first day based on start-day config
      let offset = if config.startDay == "sunday" {
        calc.rem(first-day + 1, 7)
      } else {
        first-day
      }
      
      // Month container
      rect(
        width: 100%,
        stroke: 1pt + primary-color,
        inset: 10pt
      )[
        // Month name
        #align(center)[
          #if config.pages.month {
            nav-link(
              text(size: 14pt, weight: "bold")[#month-name],
              "month",
              year,
              month: month,
              color: primary-color
            )
          } else {
            text(size: 14pt, weight: "bold", fill: primary-color)[#month-name]
          }
        ]
        
        #v(6pt)
        
        // Day headers
        #grid(
          columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
          gutter: 3pt,
          ..{
            let headers = if config.startDay == "sunday" {
              ("S", "M", "T", "W", "T", "F", "S")
            } else {
              ("M", "T", "W", "T", "F", "S", "S")
            }
            headers.map(h => align(center)[#text(size: 9pt, weight: "bold", fill: rgb("#666"))[#h]])
          }
        )
        
        #v(4pt)
        
        // Calendar grid
        #grid(
          columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
          gutter: 3pt,
          
          // Empty cells before first day
          ..range(offset).map(_ => []),
          
          // Days of month
          ..range(1, num-days + 1).map(day => {
            let is-wknd = is-weekend(year, month, day, start-day: config.startDay)
            let cell-bg = if is-wknd { weekend-color } else { none }
            
            align(center)[
              #if config.pages.daily {
                rect(
                  width: 100%,
                  height: 100%,
                  fill: cell-bg,
                  inset: 3pt,
                  stroke: 0.3pt + rgb("#d0d0d0")
                )[
                  #nav-link(
                    text(size: 9pt)[#str(day)],
                    "day",
                    year,
                    month: month,
                    day: day,
                    color: primary-color
                  )
                ]
              } else {
                rect(
                  width: 100%,
                  height: 100%,
                  fill: cell-bg,
                  inset: 3pt,
                  stroke: 0.3pt + rgb("#d0d0d0")
                )[
                  #text(size: 9pt)[#str(day)]
                ]
              }
            ]
          })
        )
      ]
    })
  )
]
