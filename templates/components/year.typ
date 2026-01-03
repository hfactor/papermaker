// Year calendar component - compact single-page overview

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *
#import "../utils/layout.typ": *
#import "../utils/config-helpers.typ": get-colors, get-fonts, get-month-label-format
#import "sidebar.typ": *

#let year-calendar(config) = {
  let year = config.timeRange.startYear
  let colors = get-colors(config)
  let fonts = get-fonts(config)
  
  let title = config.generation.pages.cover.at("title", default: str(year))
  let start-day-idx = get-start-day-idx(config)
  
  // Use 3 columns for portrait (3x4 layout), 4 columns for landscape (4x3 layout)
  let num-columns = if config.output.orientation == "portrait" { 3 } else { 4 }
  
  let grid-content = grid(
    columns: (1fr,) * num-columns,
    column-gutter: 12pt,
    row-gutter: 50pt,
    align: top,
    ..range(1, 13).map(month => {
      block(width: 100%, breakable: false)[
        #let month-name = get-month-name(month, format: get-month-label-format(config))
        #let first-day = first-day-of-month(year, month)
        #let num-days = days-in-month(year, month)
        #let offset = calc.rem(first-day - start-day-idx + 7, 7)
        #let headers = get-day-headers(start-day: start-day-idx, format: "first")
        
        #align(center)[#nav-link(config, text(font: fonts.primary, size: 9pt, weight: fonts.primaryWeight)[#month-name], "month", year, month: month, color: colors.dark1)]
        
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
                return colors.weekendFill
              }
            }
            return none
          },
          inset: 0pt,
          align: center + horizon,
          
          ..headers.map(h => text(font: fonts.secondary, size: 5pt, weight: fonts.secondaryWeight, fill: colors.dark1.transparentize(50%))[#h]),
          
          ..range(7 * 6).map(i => {
            let day-idx = i - offset + 1
            if day-idx >= 1 and day-idx <= num-days {
              nav-link(
                config,
                text(font: fonts.secondary, size: 6.5pt, weight: fonts.secondaryWeight)[#fmt-dd(day-idx)],
                "day",
                year,
                month: month,
                day: day-idx,
                color: colors.dark1
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
