#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *
#import "../utils/layout.typ": *
#import "sidebar.typ": *

#let week-spread(config, year, week-num) = {
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
  
  let iso-week-start = date-from-iso-week(year, week-num)
  let week-days = ()
  for i in range(7) {
    let d = iso-week-start + duration(days: i)
    week-days.push((year: d.year(), month: d.month(), day: d.day(), dow: calc.rem(d.weekday() - 1, 7)))
  }
  
  let m-name = get-month-name(week-days.at(0).month)
  let q = get-quarter(week-days.at(0).month)
  
  let breadcrumbs = (
    nav-link(config, m-name, "month", year, month: week-days.at(0).month, color: dark1),
    nav-link(config, str(year), "year", year, color: dark1),
  )
  if config.generation.pages.quarter.enabled {
    breadcrumbs.push(nav-link(config, "Q" + str(q), "quarter", year, quarter: q, color: dark1))
  }
  if config.generation.pages.week.enabled {
    breadcrumbs.push(nav-link(config, "W" + str(week-num), "week", year, week: week-num, color: dark1))
  }
  
  let title = "Week " + str(week-num)
  
  let grid-content = grid(
    columns: (1fr,) * 7,
    rows: (1fr,),
    column-gutter: 15pt,
    ..week-days.map(day-info => {
      let header = align(top + left)[
        #nav-link(
          config,
          text(font: primary-font, size: 10pt, weight: primary-weight)[#fmt-dd(day-info.day) #get-month-name(day-info.month, format: "abbreviated")],
          "day",
          day-info.year,
          month: day-info.month,
          day: day-info.day,
          color: dark1
        )
        #v(-3pt)
        #text(font: secondary-font, size: 8pt, weight: secondary-weight, fill: dark1.transparentize(50%))[#get-day-name(day-info.dow, format: "full")]
      ]
      
      // Add weekend background color
      let is-weekend-day = is-weekend(day-info.year, day-info.month, day-info.day, config: config)
      
      block(
        width: 100%,
        height: 100%,
        fill: if is-weekend-day { weekend-fill } else { none },
        inset: 0pt
      )[
        #planner-column(
          config,
          header,
          start-h: safe-parse-hour(config.planner.at("startTime", default: "08:00")),
          end-h: safe-parse-hour(config.planner.at("endTime", default: "20:00")),
          show-divs: config.planner.at("showDivisions", default: false),
          text-size: 6pt,
          show-border: false,
          gutter: 3pt
        )
      ]
    })
  )

  [
    #standard-layout(
      config,
      title: title,
      breadcrumbs: breadcrumbs,
      body: grid-content
    )
    #page-label("week", year, week: week-num)
  ]
}
