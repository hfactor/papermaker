#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *
#import "../utils/layout.typ": *
#import "sidebar.typ": *

#let quarter-spread(config, quarter, year: none) = {
  let year = if year == none { config.timeRange.startYear } else { year }
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let weekend-fill = if config.colors.at("weekendHighlight", default: none) != none {
     rgb(config.colors.weekendHighlight).transparentize(85%)
  } else {
     rgb(config.colors.at("light2", default: "#f4f4f5")).transparentize(85%)
  }
  let primary-font = config.typography.at("primaryFont", default: "Inter")
  let primary-weight = config.typography.at("primaryFontWeight", default: 700)
  let secondary-font = config.typography.at("secondaryFont", default: "Inter")
  let secondary-weight = config.typography.at("secondaryFontWeight", default: 400)
  
  let start-day-idx = get-start-day-idx(config)
  
  let q-type = config.generation.pages.quarter.at("type", default: "calendar")
  let fiscal-offset = if q-type == "fiscal" { 3 } else { 0 } // April is Month 4, so offset is 3
  let months = quarter-months(quarter, fiscal-offset: fiscal-offset)
  
  let breadcrumbs = (
    nav-link(config, str(year), "year", year, color: dark1),
  )
  
  let title = "Quarter " + str(quarter) + " " + str(year)
  
  let grid-content = grid(
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
          rows: (auto, 1fr),
          row-gutter: 10pt,
          block(width: 100%)[
            #align(center)[#nav-link(config, text(font: primary-font, size: 11pt, weight: primary-weight)[#month-name], "month", year, month: month, color: dark1)]
            #v(2pt)
            #table(
              columns: (1fr,) * 7,
              rows: (13pt,) * 7,
              stroke: none,
              fill: (x, y) => {
                let day-idx = (y - 1) * 7 + x - offset + 1
                if day-idx >= 1 and day-idx <= num-days {
                  if is-weekend(year, month, day-idx, config: config) { return weekend-fill }
                }
                return none
              },
              inset: 0pt,
              align: center + horizon,
              ..headers.map(h => text(font: secondary-font, size: 5.5pt, weight: secondary-weight, fill: dark1.transparentize(50%))[#h]),
              ..range(7 * 6).map(i => {
                let day-idx = i - offset + 1
                if day-idx >= 1 and day-idx <= num-days {
                  nav-link(config, text(font: secondary-font, size: 7.5pt, weight: secondary-weight)[#fmt-dd(day-idx)], "day", year, month: month, day: day-idx, color: dark1)
                } else { [] }
              })
            )
          ],
          paper-block(config, show-guides: true)
        )
      ]
    })
  )

  let writing-area = paper-block(config, show-guides: true, override-layout: "line")

  [
    #standard-layout(
      config,
      title: "Q" + str(quarter),
      breadcrumbs: breadcrumbs,
      body: grid(
        columns: (1fr, 1fr, 1fr),
        column-gutter: 20pt,
        ..months.map(month => {
          let month-name = get-month-name(month, format: "full")
          let first-day = first-day-of-month(year, month)
          let num-days = days-in-month(year, month)
          let offset = calc.rem(first-day - start-day-idx + 7, 7)
          let headers = get-day-headers(start-day: start-day-idx, format: "first")

          block(width: 100%, height: 100%)[
            #align(center)[#nav-link(config, text(font: primary-font, size: 10pt, weight: primary-weight)[#month-name], "month", year, month: month, color: dark1)]
            #v(5pt)
            #table(
              columns: (1fr,) * 7,
              rows: (15pt,) * 7,  // Wider rows than year (13.5pt)
              column-gutter: 1.5pt,  // Slightly more gutter
              row-gutter: 1.5pt,
              stroke: none,
              fill: (x, y) => {
                let day-idx = (y - 1) * 7 + x - offset + 1
                if day-idx >= 1 and day-idx <= num-days {
                  if is-weekend(year, month, day-idx, config: config) { return weekend-fill }
                }
                return none
              },
              inset: 0pt,
              align: center + horizon,
              ..headers.map(h => text(font: secondary-font, size: 5pt, weight: secondary-weight, fill: dark1.transparentize(50%))[#h]),
              ..range(7 * 6).map(i => {
                let day-idx = i - offset + 1
                if day-idx >= 1 and day-idx <= num-days {
                  nav-link(config, text(font: secondary-font, size: 7pt, weight: secondary-weight)[#fmt-dd(day-idx)], "day", year, month: month, day: day-idx, color: dark1)
                } else { [] }
              })
            )
            #v(15pt)
            #paper-block(config, show-guides: true)
          ]
        })
      )
    )
    #page-label("quarter", year, quarter: quarter)
  ]
}
