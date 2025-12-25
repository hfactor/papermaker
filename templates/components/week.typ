// Weekly spread component - SINGLE PAGE 7-day layout

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *

#let week-spread(config, year, week-num) = {
  // Config is normalized to new format
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let dark2 = rgb(config.colors.at("dark2", default: "#000000"))
  let light1 = rgb(config.colors.at("light1", default: "#ffffff"))
  let weekend-color = dark1.transparentize(60%)
  let primary-font = config.typography.at("primaryFont", default: "Lato")
  
  let iso-week-start = date-from-iso-week(year, week-num)
  let start-day-idx = get-start-day-idx(config)
  
  let week-days = ()
  for i in range(7) {
    let d = iso-week-start + duration(days: i)
    week-days.push((
      year: d.year(),
      month: d.month(),
      day: d.day(),
      dow: calc.rem(d.weekday() - 1, 7)
    ))
  }
  
  let start-month-name = get-month-name(week-days.at(0).month, format: "abbreviated")
  let end-month-name = get-month-name(week-days.at(6).month, format: "abbreviated")
  let date-range = if start-month-name == end-month-name {
    [#start-month-name #fmt-dd(week-days.at(0).day) - #fmt-dd(week-days.at(6).day), #str(year)]
  } else {
    [#start-month-name #fmt-dd(week-days.at(0).day) - #end-month-name #fmt-dd(week-days.at(6).day), #str(year)]
  }
  
  let start-h = int(config.planner.at("startTime", default: "08:00").slice(0, 2))
  let end-h = int(config.planner.at("endTime", default: "20:00").slice(0, 2))
  
  let first-day = week-days.at(0)
  let month-name = get-month-name(first-day.month, format: "full")
  
  [
    #paper-block(config, force-plain: true, body: [
      #nav-header(
        config,
        [], // Empty left
        [
          Week #str(week-num) - 
          #nav-link(config, month-name, "month", year, month: first-day.month, color: dark1)
          #nav-link(config, str(year), "year", year, color: dark1)
        ],
        color: dark1
      )
      
      #v(4pt)
      
      #let stroke-w = config.typography.at("strokeWidth", default: 0.5) * 1pt
      #grid(
        columns: (1fr,) * 7,
        rows: (1fr,),
        column-gutter: 15pt,
        
        ..week-days.map(day-info => {
          let is-wknd = is-weekend(day-info.year, day-info.month, day-info.day, config: config)
          let cell-bg = if is-wknd { weekend-color } else { none }
          let day-label = get-day-name(day-info.dow, format: "full")
          let month-abbr = get-month-name(day-info.month, format: "abbreviated")
          
          let header = align(top + left)[
            #(if config.generation.pages.day.at("enabled", default: false) and day-info.year == year {
              nav-link(
                config,
                text(font: primary-font, size: 10pt, weight: "bold")[
                  #fmt-dd(day-info.day) #month-abbr
                ],
                "day",
                day-info.year,
                month: day-info.month,
                day: day-info.day,
                color: dark1
              )
            } else {
              text(font: primary-font, size: 10pt, weight: "bold", fill: dark1)[
                #fmt-dd(day-info.day) #month-abbr
              ]
            })
            #v(-3pt)
            #text(size: 8pt, weight: "bold", fill: dark2.transparentize(40%))[#day-label]
          ]

          planner-column(
            config,
            header,
            start-h: safe-parse-hour(config.planner.at("startTime", default: "08:00")),
            end-h: safe-parse-hour(config.planner.at("endTime", default: "20:00")),
            show-divs: config.planner.at("showDivisions", default: false),
            text-size: 6pt,
            show-border: false,
            gutter: 3pt
          )
        })
      )
    ])
    #page-label("week", year, week: week-num)
  ]
}
