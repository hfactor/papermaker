// Year calendar component - compact single-page overview

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *

#let year-calendar(config) = {
  // Config is normalized to new format
  let year = config.timeRange.startYear
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let dark2 = rgb(config.colors.at("dark2", default: "#000000"))
  let weekend-color = dark1.transparentize(60%)
  let primary-font = config.typography.at("primaryFont", default: "Lato")
  let title-sz = 24pt * config.typography.at("fontScale", default: 1.0)
  
  let title = config.generation.pages.cover.at("title", default: str(year))
  let start-day-idx = get-start-day-idx(config)
  
  [
    #paper-block(config, force-plain: true, body: [
      #align(center)[
        #text(font: primary-font, size: title-sz, weight: "bold", fill: dark1)[#title]
      ]
      #v(0.4em)
      
      #grid(
        columns: (1fr, 1fr, 1fr, 1fr),
        column-gutter: 12pt,
        row-gutter: 50pt,
        align: top,
        
        ..range(1, 13).map(month => {
          block(width: 100%, breakable: false)[
            #let month-name = get-month-name(month, format: config.generation.pages.month.at("labels", default: "full"))
            #let first-day = first-day-of-month(year, month)
            #let num-days = days-in-month(year, month)
            #let offset = calc.rem(first-day - start-day-idx + 7, 7)
            #let headers = get-day-headers(start-day: start-day-idx, format: "first")
            
            #align(center)[
              #if config.generation.pages.month.at("enabled", default: false) {
                nav-link(
                  config,
                  text(font: primary-font, size: 9pt, weight: "bold")[#month-name],
                  "month",
                  year,
                  month: month,
                  color: dark1
                )
              } else {
                text(font: primary-font, size: 9pt, weight: "bold", fill: dark1)[#month-name]
              }
            ]
            
            #v(1pt)
            
            #let sw = config.typography.at("strokeWidth", default: 0.5) * 1pt
            #table(
              columns: (1fr,) * 7,
              rows: (13.5pt,) * 7,
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
              
              ..headers.map(h => text(size: 5pt, weight: "bold", fill: dark1.transparentize(50%))[#h]),
              
              ..range(7 * 6).map(i => {
                let day-idx = i - offset + 1
                if day-idx >= 1 and day-idx <= num-days {
                  if config.generation.pages.day.at("enabled", default: false) {
                    nav-link(
                      config,
                      text(size: 6.5pt, weight: "medium")[#fmt-dd(day-idx)],
                      "day",
                      year,
                      month: month,
                      day: day-idx,
                      color: dark1
                    )
                  } else {
                    text(size: 6.5pt, fill: dark1)[#fmt-dd(day-idx)]
                  }
                } else {
                  []
                }
              })
            )
          ]
        })
      )
    ])
    #page-label("year", year)
  ]
}
