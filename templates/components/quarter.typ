// Quarter spread component - SINGLE PAGE: 3-month calendar + Top 5 items

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *

#let quarter-spread(config, quarter, year: none) = {
  // Config is normalized to new format
  let year = if year == none { config.timeRange.startYear } else { year }
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let dark2 = rgb(config.colors.at("dark2", default: "#000000"))
  let weekend-color = dark1.transparentize(60%)
  let primary-font = config.typography.at("primaryFont", default: "Lato")
  
  let start-day-idx = get-start-day-idx(config)
  let months = quarter-months(quarter)
  
  [
    #paper-block(config, force-plain: true, body: [
      #nav-header(
        config,
        nav-link(config, [← Year], "year", year, color: dark1),
        [Q#str(quarter) - #str(year)],
        color: dark1
      )
      
      #v(8pt)
      
      #grid(
        columns: (1fr, 1fr, 1fr),
        column-gutter: 15pt,
        rows: (1fr,),
        align: top,
        
        ..months.map(month => {
          let month-name = get-month-name(month, format: config.generation.pages.month.at("labels", default: "full"))
          let first-day = first-day-of-month(year, month)
          let num-days = days-in-month(year, month)
          let offset = calc.rem(first-day - start-day-idx + 7, 7)
          let headers = get-day-headers(start-day: start-day-idx, format: "first")

          block(width: 100%, height: 100%)[
            #grid(
              rows: (25%, 75%),
              row-gutter: 0pt,
              
              // 1. Minimal Calendar (Top 25%)
              block(width: 100%)[
                #align(center)[
                  #if config.generation.pages.month.at("enabled", default: false) {
                    nav-link(
                      config,
                      text(font: primary-font, size: 11pt, weight: "bold")[#month-name],
                      "month",
                      year,
                      month: month,
                      color: dark1
                    )
                  } else {
                    text(font: primary-font, size: 11pt, weight: "bold", fill: dark1)[#month-name]
                  }
                ]
                
                #v(2pt)
                
                #let sw = config.typography.at("strokeWidth", default: 0.5) * 1pt
                #table(
                  columns: (1fr,) * 7,
                  rows: (13pt,) * 7,
                  column-gutter: 1pt,
                  row-gutter: 1pt,
                  stroke: none,
                  fill: (x, y) => {
                    let day-idx = (y - 1) * 7 + x - offset + 1
                    if day-idx >= 1 and day-idx <= num-days {
                      if is-weekend(year, month, day-idx, config: config) {
                        return weekend-color
                      }
                    }
                    return none
                  },
                  inset: 0pt,
                  align: center + horizon,
                  
                  ..headers.map(h => text(size: 5.5pt, weight: "bold", fill: dark1.transparentize(50%))[#h]),
                  
                  ..range(7 * 6).map(i => {
                    let day-idx = i - offset + 1
                    if day-idx >= 1 and day-idx <= num-days {
                      if config.generation.pages.day.at("enabled", default: false) {
                        nav-link(
                          config,
                          text(size: 7.5pt, weight: "medium")[#fmt-dd(day-idx)],
                          "day",
                          year,
                          month: month,
                          day: day-idx,
                          color: dark1
                        )
                      } else {
                        text(size: 7.5pt, fill: dark1)[#fmt-dd(day-idx)]
                      }
                    } else {
                      []
                    }
                  })
                )
              ],
              
              // 2. Writing Area (Bottom 75%)
              paper-block(config, show-guides: true, override-layout: "line")
            )
          ]
        })
      )
    ])
    #page-label("quarter", year, quarter: quarter)
  ]
}
