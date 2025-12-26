#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *
#import "../utils/layout.typ": *
#import "../utils/config-helpers.typ": get-colors, get-fonts, get-month-label-format
#import "sidebar.typ": *

#let month-spread(config, month, year: none) = {
  let year = if year == none { config.timeRange.startYear } else { year }
  let colors = get-colors(config)
  let fonts = get-fonts(config)
  
  let month-name = get-month-name(month, format: get-month-label-format(config))
  let first-day = first-day-of-month(year, month)
  let num-days = days-in-month(year, month)
  
  let start-day-idx = get-start-day-idx(config)
  let offset = calc.rem(first-day - start-day-idx + 7, 7)
  let num-weeks = calc.ceil((offset + num-days) / 7)
  
  let breadcrumbs = build-breadcrumbs(config, year, month: month, color: colors.dark1)
  
  let weekend-fill = colors.weekendFill

  
  let grid-content = grid(
    columns: (30pt, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    rows: (auto,) + (1fr,) * num-weeks,
    stroke: (x, y) => {
      let s = 0.5pt + colors.dark2.transparentize(60%)
      if y == 0 { return none }
      let strokes = (:)
      if x > 0 { strokes.top = s; if y == num-weeks { strokes.bottom = s } }
      if x >= 1 { strokes.left = s; if x == 7 { strokes.right = s } }
      return strokes
    },
    [],
    ..get-day-headers(start-day: start-day-idx, format: "abbreviated").map(h => align(center + horizon)[
      #v(2pt)
      #text(font: fonts.secondary, size: 9pt, weight: fonts.secondaryWeight, fill: colors.dark1.transparentize(40%))[#h]
      #v(8pt)
    ]),
    ..{
      let cells = ()
      for w in range(num-weeks) {
        let week-start-day = 1 + w * 7 - offset
        let actual-day = calc.max(1, calc.min(num-days, week-start-day))
        let wk-num = week-number(year, month, actual-day)
        
        // Week number label
        let week-content = block(width: 100%, height: 100%, inset: (top: 5pt, right: 8pt))[
          #align(right + top)[
            #text(font: fonts.secondary, size: 8pt, weight: fonts.secondaryWeight, fill: colors.dark1.transparentize(70%))[W#str(wk-num.week)]
          ]
        ]
        cells.push(nav-link(config, week-content, "week", wk-num.year, week: wk-num.week, color: colors.dark1.transparentize(70%)))
        
        for d in range(7) {
          let day-idx = w * 7 + d - offset + 1
          let d-year = year; let d-month = month; let d-day = day-idx; let is-current = true
          
          if day-idx < 1 {
            is-current = false
            let prev-m = if month == 1 { 12 } else { month - 1 }
            let prev-y = if month == 1 { year - 1 } else { year }
            d-year = prev-y; d-month = prev-m; d-day = days-in-month(prev-y, prev-m) + day-idx
          } else if day-idx > num-days {
            is-current = false
            let next-m = if month == 12 { 1 } else { month + 1 }
            let next-y = if month == 12 { year + 1 } else { year }
            d-year = next-y; d-month = next-m; d-day = day-idx - num-days
          }
          
          let color = if is-current { colors.dark1 } else { colors.dark1.transparentize(70%) }
          cells.push(block(width: 100%, height: 100%, fill: if is-weekend(d-year, d-month, d-day, config: config) { weekend-fill } else { none })[
            #let link-bar = block(width: 100%, height: 15pt, inset: (top: 3pt, left: 5pt))[
              #text(font: fonts.secondary, size: 11pt, weight: fonts.secondaryWeight, fill: color)[#fmt-dd(d-day)]
            ]
            #nav-link(config, link-bar, "day", d-year, month: d-month, day: d-day, color: color)
          ])
        }
      }
      cells
    }
  )

  [
    #standard-layout(
      config,
      title: text(fill: colors.dark1)[#month-name #str(year)],
      breadcrumbs: breadcrumbs,
      body: grid-content
    )
    #page-label("month", year, month: month)
  ]
}
