// Year calendar component - compact single-page overview

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *
#import "../utils/layout.typ": *
#import "sidebar.typ": *

#let year-calendar(config) = {
  let year = config.timeRange.startYear
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let weekend-color = if config.colors.at("weekendHighlight", default: none) != none {
     rgb(config.colors.weekendHighlight).transparentize(85%)
  } else {
     rgb(config.colors.at("light2", default: "#f4f4f5")).transparentize(85%)
  }
  let primary-font = config.typography.at("primaryFont", default: "Inter")
  let primary-weight = config.typography.at("primaryFontWeight", default: 700)
  let secondary-font = config.typography.at("secondaryFont", default: "Inter")
  let secondary-weight = config.typography.at("secondaryFontWeight", default: 400)
  
  let title = config.generation.pages.cover.at("title", default: str(year))
  let start-day-idx = get-start-day-idx(config)
  
  let grid-content = grid(
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
        
        #align(center)[#nav-link(config, text(font: primary-font, size: 9pt, weight: primary-weight)[#month-name], "month", year, month: month, color: dark1)]
        
        #v(1pt)
        
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
          
          ..headers.map(h => text(font: secondary-font, size: 5pt, weight: secondary-weight, fill: dark1.transparentize(50%))[#h]),
          
          ..range(7 * 6).map(i => {
            let day-idx = i - offset + 1
            if day-idx >= 1 and day-idx <= num-days {
              nav-link(
                config,
                text(font: secondary-font, size: 6.5pt, weight: secondary-weight)[#fmt-dd(day-idx)],
                "day",
                year,
                month: month,
                day: day-idx,
                color: dark1
              )
            } else {
              []
            }
          })
        )
      ]
    })
  )

  [
    #standard-layout(
      config,
      title: str(year),
      breadcrumbs: (),
      body: grid-content
    )
    #page-label("year", year)
  ]
}
