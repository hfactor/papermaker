// Hyperlink utilities for calendar navigation

// Generate unique page label for a date component
#let page-label(type, year, month: none, week: none, day: none, quarter: none) = {
  if type == "year" {
    label("year-" + str(year))
  } else if type == "quarter" {
    label("quarter-" + str(year) + "-" + str(quarter))
  } else if type == "month" {
    label("month-" + str(year) + "-" + str(month))
  } else if type == "week" {
    label("week-" + str(year) + "-" + str(week))
  } else if type == "day" {
    label("day-" + str(year) + "-" + str(month) + "-" + str(day))
  }
}

// Create a clickable link to a page
#let nav-link(content, type, year, month: none, week: none, day: none, quarter: none, color: black) = {
  let target = if type == "year" {
    label("year-" + str(year))
  } else if type == "quarter" {
    label("quarter-" + str(year) + "-" + str(quarter))
  } else if type == "month" {
    label("month-" + str(year) + "-" + str(month))
  } else if type == "week" {
    label("week-" + str(year) + "-" + str(week))
  } else if type == "day" {
    label("day-" + str(year) + "-" + str(month) + "-" + str(day))
  }
  
  link(target)[#text(fill: color)[#content]]
}

// Create breadcrumb navigation
#let breadcrumb(items, color: black) = {
  let parts = ()
  
  for (i, item) in items.enumerate() {
    if i > 0 {
      parts.push(text(fill: color)[ → ])
    }
    parts.push(item)
  }
  
  parts.join()
}

// Navigation header with back link
#let nav-header(back-link, title, color: black) = {
  grid(
    columns: (1fr, 2fr, 1fr),
    align: (left, center, right),
    back-link,
    text(size: 14pt, weight: "bold", fill: color)[#title],
    []
  )
}
