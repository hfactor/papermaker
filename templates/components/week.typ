#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *
#import "../utils/layout.typ": *
#import "../utils/config-helpers.typ": get-colors, get-fonts
#import "sidebar.typ": *

#let week-spread(config, year, week-num) = {
  let colors = get-colors(config)
  let fonts = get-fonts(config)
  
  let iso-week-start = date-from-iso-week(year, week-num)
  let week-days = ()
  for i in range(7) {
    let d = iso-week-start + duration(days: i)
    week-days.push((year: d.year(), month: d.month(), day: d.day(), dow: calc.rem(d.weekday() - 1, 7)))
  }
  
  let m-name = get-month-name(week-days.at(0).month)
  
  let breadcrumbs = build-breadcrumbs(config, year, month: week-days.at(0).month, week: week-num, color: colors.dark1)
  
  let title = "Week " + str(week-num)
  
  let grid-content = grid(
    columns: (1fr,) * 7,
    rows: (1fr,),
    column-gutter: 15pt,
    ..week-days.map(day-info => {
      let header = align(top + left)[
        #nav-link(
          config,
          text(font: fonts.primary, size: 10pt, weight: fonts.primaryWeight)[#fmt-dd(day-info.day) #get-month-name(day-info.month, format: "abbreviated")],
          "day",
          day-info.year,
          month: day-info.month,
          day: day-info.day,
          color: colors.dark1
        )
        #v(-3pt)
        #text(font: fonts.secondary, size: 8pt, weight: fonts.secondaryWeight, fill: colors.dark1.transparentize(50%))[#get-day-name(day-info.dow, format: "full")]
      ]
      
      // Add weekend background color
      let is-weekend-day = is-weekend(day-info.year, day-info.month, day-info.day, config: config)
      
      block(
        width: 100%,
        height: 100%,
        fill: if is-weekend-day { colors.weekendFill } else { none },
        inset: 0pt
      )[
        #planner-column(
          config,
          header,
          start-h: safe-parse-hour(config.generation.pages.day.at("startTime", default: "08:00")),
          end-h: safe-parse-hour(config.generation.pages.day.at("endTime", default: "20:00")),
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
