#import "../utils/dates.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/styles.typ": *
#import "../utils/layout.typ": *
#import "sidebar.typ": *

#let daily-page(config, year, month, day) = {
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let d-conf = config.generation.pages.day
  let start-h = safe-parse-hour(d-conf.at("startTime", default: "08:00"))
  let end-h = safe-parse-hour(d-conf.at("endTime", default: "20:00"))
  let show-divs = d-conf.at("showHalfHour", default: false)
  let time-format = d-conf.at("timeFormat", default: "24h")
  let sidebar-mod = d-conf.at("sidebarModule", default: "planner")
  let sidebar-pos = d-conf.at("sidebar", default: "right")
  
  let q = get-quarter(month)
  let wk = week-number(year, month, day)
  
  let breadcrumbs = (
    nav-link(config, get-month-name(month), "month", year, month: month, color: dark1),
    nav-link(config, str(year), "year", year, color: dark1),
  )
  if config.generation.pages.quarter.enabled {
    breadcrumbs.push(nav-link(config, "Q" + str(q), "quarter", year, quarter: q, color: dark1))
  }
  if config.generation.pages.week.enabled {
    breadcrumbs.push(nav-link(config, "W" + str(wk.week), "week", wk.year, week: wk.week, color: dark1))
  }
  
  let title = fmt-dd(day) + " " + get-day-name(day-of-week(year, month, day))
  
  let sidebar-content = if d-conf.at("sidebarEnabled", default: true) == false {
    none
  } else if sidebar-mod == "planner" {
    sidebar-planner(config, start-h: start-h, end-h: end-h, show-divs: show-divs, time-format: time-format)
  } else if sidebar-mod == "todo" {
    sidebar-todo(config)
  } else if sidebar-mod == "notes" {
    sidebar-notes(config)
  } else {
    none
  }

  [
    #standard-layout(
      config,
      title: title,
      breadcrumbs: breadcrumbs,
      sidebar-content: sidebar-content,
      body: paper-block(config, show-guides: true),
      is-daily: true
    )
    #page-label("day", year, month: month, day: day)
  ]
}

#let extra-daily-page(config, year, month, day) = {
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let q = get-quarter(month)
  let wk = week-number(year, month, day)
  
  let breadcrumbs = (
    nav-link(config, get-month-name(month), "month", year, month: month, color: dark1),
    nav-link(config, str(year), "year", year, color: dark1),
  )
  if config.generation.pages.quarter.enabled {
    breadcrumbs.push(nav-link(config, "Q" + str(q), "quarter", year, quarter: q, color: dark1))
  }
  if config.generation.pages.week.enabled {
    breadcrumbs.push(nav-link(config, "W" + str(wk.week), "week", wk.year, week: wk.week, color: dark1))
  }
  
  let title = fmt-dd(day) + " " + get-day-name(day-of-week(year, month, day))

  [
    #standard-layout(
      config,
      title: text(size: 0.85em)[#title],  // Smaller title (85% of normal size)
      breadcrumbs: breadcrumbs,
      sidebar-content: none,
      body: paper-block(config, show-guides: true),
      is-daily: true
    )
    #page-label("day-extra", year, month: month, day: day)
  ]
}
