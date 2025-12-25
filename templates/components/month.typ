// Month spread component - SINGLE PAGE detailed monthly calendar

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *

#let month-spread(config, month, year: none) = {
  // Config is normalized to new format
  let year = if year == none { config.timeRange.startYear } else { year }
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let dark2 = rgb(config.colors.at("dark2", default: "#000000"))
  let light1 = rgb(config.colors.at("light1", default: "#ffffff"))
  let weekend-color = rgb(config.colors.at("weekendHighlight", default: "#eef6ff"))
  let primary-font = config.typography.at("primaryFont", default: "Lato")
  
  let month-name = get-month-name(month, format: config.generation.pages.month.at("labels", default: "full"))
  let first-day = first-day-of-month(year, month)
  let num-days = days-in-month(year, month)
  let quarter = get-quarter(month)
  
  let start-day-idx = get-start-day-idx(config)
  let offset = calc.rem(first-day - start-day-idx + 7, 7)
  let day-header-format = "full" 
  
  [
    #paper-block(config, force-plain: true, body: [
      #let quarter-enabled = config.generation.pages.quarter.at("enabled", default: false)
      #let title-part = text(font: primary-font, size: 14pt, weight: "bold", fill: dark1)[#month-name #str(year)]
      #let q-part = if quarter-enabled {
        text(font: primary-font, size: 14pt, weight: "bold", fill: dark1)[, Q#str(quarter)]
      } else { [] }

      #v(-10pt) // Move title up
      #align(center)[
        #nav-link(config, title-part, "year", year, color: dark1)
        #if quarter-enabled {
          nav-link(config, q-part, "quarter", year, quarter: quarter, color: dark1)
        }
      ]
      
      #v(0pt) // Tighten vertical space
      
      #let headers = get-day-headers(start-day: start-day-idx, format: "abbreviated")
      #let stroke-w = 0.5pt
      #let grid-stroke = stroke-w + dark2.transparentize(60%)
      
      // Calculate how many rows are actually needed (5 or 6)
      #let num-weeks = calc.ceil((offset + num-days) / 7)
      
      // Constants for colors
      #let dull-color = dark1.transparentize(70%)
      #let header-color = dark1.transparentize(40%)
      #let wknd-fill = dark1.transparentize(60%) // 40% opacity
      
      #grid(
        columns: (30pt, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        rows: (auto,) + (1fr,) * num-weeks,
        column-gutter: 0pt,
        row-gutter: 0pt,
        stroke: (x, y) => {
          let s = grid-stroke
          if y == 0 { return none } // No lines for header row (day names)
          
          let strokes = (:)
          
          // Horizontal lines - only for the date grid (x > 0)
          if x > 0 {
            strokes.top = s
            if y == num-weeks { strokes.bottom = s }
          }
          
          // Vertical lines - from Monday (x=1) onwards
          if x >= 1 {
            strokes.left = s
            if x == 7 { strokes.right = s }
          }
          
          return strokes
        },
        
        [],
        ..headers.map(h => align(center + horizon)[
          #v(2pt)
          #text(font: primary-font, size: 9pt, weight: "bold", fill: header-color)[#h]
          #v(8pt) // Padding-bottom for day names
        ]),
        
        ..{
          let cells = ()
          for w in range(num-weeks) {
            let week-start-day = 1 + w * 7 - offset
            
            // 1. Week number label - No horizontal line
            let actual-day = calc.max(1, calc.min(num-days, week-start-day))
            let wk-num = week-number(year, month, actual-day)
            
            let week-content = block(width: 100%, height: 100%, inset: (top: 5pt, right: 8pt))[
              #align(right + top)[
                #text(size: 8pt, weight: "bold", fill: dull-color)[W#str(wk-num.week)]
              ]
            ]
            
            if config.generation.pages.week.at("enabled", default: false) {
              cells.push(nav-link(config, week-content, "week", wk-num.year, week: wk-num.week, color: dull-color))
            } else {
              cells.push(week-content)
            }
            
            for d in range(7) {
              let day-idx = w * 7 + d - offset + 1
              let d-year = year
              let d-month = month
              let d-day = day-idx
              let is-current = true
              
              if day-idx < 1 {
                is-current = false
                let prev-m = if month == 1 { 12 } else { month - 1 }
                let prev-y = if month == 1 { year - 1 } else { year }
                let p-days = days-in-month(prev-y, prev-m)
                d-year = prev-y
                d-month = prev-m
                d-day = p-days + day-idx
              } else if day-idx > num-days {
                is-current = false
                let next-m = if month == 12 { 1 } else { month + 1 }
                let next-y = if month == 12 { year + 1 } else { year }
                d-year = next-y
                d-month = next-m
                d-day = day-idx - num-days
              }
              
              let is-wknd = is-weekend(d-year, d-month, d-day, config: config)
              let cell-fill = if is-wknd { wknd-fill } else { none }
              let text-color = if is-current { dark1 } else { dull-color }
              
              cells.push(block(width: 100%, height: 100%, fill: cell-fill)[
                #let link-bar = block(width: 100%, height: 15pt, inset: (top: 3pt, left: 5pt))[
                  #text(size: 11pt, weight: "bold", fill: text-color)[#fmt-dd(d-day)]
                ]
                
                #if config.generation.pages.day.at("enabled", default: false) {
                  nav-link(config, link-bar, "day", d-year, month: d-month, day: d-day, color: text-color)
                } else {
                  link-bar
                }
              ])
            }
          }
          cells
        }
      )
    ])
    #page-label("month", year, month: month)
  ]
}
