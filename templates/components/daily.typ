// Daily page component - single day per page with paper style variations

#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *

#let daily-page(config, year, month, day) = {
  // Config is normalized to new format
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let dark2 = rgb(config.colors.at("dark2", default: "#000000"))
  let primary-font = config.typography.at("primaryFont", default: "Lato")
  
  let month-name = get-month-name(month, format: "full")
  let dow = day-of-week(year, month, day)
  let day-name = get-day-name(dow, format: "full")

  let start-h = safe-parse-hour(config.planner.at("startTime", default: "08:00"))
  let end-h = safe-parse-hour(config.planner.at("endTime", default: "20:00"))
  let planner-pos = config.generation.pages.day.at("columnSide", default: "right")
  let show-divs = config.planner.at("showDivisions", default: false)
  
  let planner-col = planner-column(
    config, 
    date-header(config, year, month, day, size: "small", show-divider: false),
    start-h: start-h, 
    end-h: end-h, 
    show-divs: show-divs,
    text-size: 7pt,
    show-border: false
  )
  
  let q = calc.floor((month - 1) / 3) + 1
  let note-col = block(width: 100%, height: 100%)[
    #align(right)[
      #nav-link(config, text(size: 10pt, weight: "bold")[Q#str(q)], "quarter", year, quarter: q, color: dark2.transparentize(40%))
    ]
    #v(2pt)
    #paper-block(config, force-plain: false, show-guides: true)
  ]
  
  [
    #paper-block(config, force-plain: true, show-guides: false, body: [
      #let cols = if planner-pos == "left" { (24%, 2.5%, 73.5%) } else { (73.5%, 2.5%, 24%) }
      #grid(
        columns: cols,
        rows: (1fr,),
        column-gutter: 0pt,
        
        if planner-pos == "left" { planner-col } else { note-col },
        [],
        if planner-pos == "left" { note-col } else { planner-col }
      )
    ])
    #page-label("day", year, month: month, day: day)
  ]
}

#let extra-daily-page(config, year, month, day) = {
  let planner-pos = config.generation.pages.day.at("columnSide", default: "left")
  
  [
    #paper-block(config, force-plain: false, show-guides: true, body: [
      #place(
        if planner-pos == "left" { top + left } else { top + right },
        box(
          inset: 15pt,
          fill: none, // Removed background
          radius: 0pt,
          stroke: none,
          date-header(config, year, month, day, size: "small", show-divider: false)
        )
      )
    ])
    #page-label("extra", year, month: month, day: day)
  ]
}
