// Year calendar component - full year overview

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *

#let year-calendar(config) = [
  #let year = config.year
  #let primary-color = rgb(config.primaryColor)
  #let weekend-color = rgb(config.weekendColor)
  #let title = if config.firstPageTitle != "" { config.firstPageTitle } else { str(year) }
  
  // Set page label for navigation
  #page-label("year", year)
  
  #pagebreak(weak: true)
  
  // Title
  #align(center)[
    #text(size: 24pt, weight: "bold", fill: primary-color)[#title]
    #v(1em)
  ]
  
  // 12-month grid (4 rows x 3 columns)
  #grid(
    columns: (1fr, 1fr, 1fr),
    rows: (auto, auto, auto, auto),
    gutter: 15pt,
    
    ..for month in range(1, 13) {
      (
        {
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
            stroke: 0.5pt + rgb("#d0d0d0"),
            inset: 8pt
          )[
            // Month name (clickable if month pages enabled)
            #align(center)[
              #if config.pages.month {
                nav-link(
                  text(size: 11pt, weight: "bold")[#month-name],
                  "month",
                  year,
                  month: month,
                  color: primary-color
                )
              } else {
                text(size: 11pt, weight: "bold", fill: primary-color)[#month-name]
              }
            ]
            
            #v(4pt)
            
            // Day headers
            #grid(
              columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
              gutter: 2pt,
              ..{
                let headers = if config.startDay == "sunday" {
                  ("S", "M", "T", "W", "T", "F", "S")
                } else {
                  ("M", "T", "W", "T", "F", "S", "S")
                }
                headers.map(h => align(center)[#text(size: 7pt, fill: rgb("#666"))[#h]])
              }
            )
            
            #v(2pt)
            
            // Calendar grid
            #grid(
              columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
              gutter: 2pt,
              
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
                      inset: 2pt,
                      stroke: none
                    )[
                      #nav-link(
                        text(size: 7pt)[#str(day)],
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
                      inset: 2pt,
                      stroke: none
                    )[
                      #text(size: 7pt)[#str(day)]
                    ]
                  }
                ]
              })
            )
          ]
        },
      )
    }
  )
  
  // Quarter links (if enabled)
  #if config.pages.quarter [
    #v(2em)
    #align(center)[
      #text(size: 12pt, weight: "bold", fill: primary-color)[Quarters]
      #v(0.5em)
      #grid(
        columns: (1fr, 1fr, 1fr, 1fr),
        gutter: 10pt,
        ..range(1, 5).map(q => {
          align(center)[
            #nav-link(
              text(size: 10pt)[Q#str(q)],
              "quarter",
              year,
              quarter: q,
              color: primary-color
            )
          ]
        })
      )
    ]
  ]
]

