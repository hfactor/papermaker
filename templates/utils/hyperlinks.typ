// Hyperlink utilities for calendar navigation
#import "dates.typ": *

// Helper to check if a month/year is in the generated range
#let is-in-range(year, month, config) = {
  let start-year = config.timeRange.startYear
  let start-month = config.timeRange.startMonth
  let total-months = config.timeRange.durationMonths
  
  // Calculate absolute month index (Year 0 Month 1 = 1)
  let target-abs-month = (year - start-year) * 12 + month
  
  target-abs-month >= start-month and target-abs-month < start-month + total-months
}

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
#let nav-link(config, content, type, year, month: none, week: none, day: none, quarter: none, color: black) = {
  // 1. Check if page type is enabled in sanitized config
  let enabled = if type == "year" {
    config.generation.pages.year.enabled
  } else if type == "quarter" {
    config.generation.pages.quarter.enabled
  } else if type == "month" {
    config.generation.pages.month.enabled
  } else if type == "week" {
    config.generation.pages.week.enabled
  } else if type == "day" {
    config.generation.pages.day.enabled
  } else {
    true
  }
  
  if not enabled {
    return text(fill: color)[#content]
  }
  
  // 2. Range validation
  let in-range = true
  let start-year = config.timeRange.startYear
  if type == "year" {
    in-range = (year == start-year) // We currently only generate one year overview
  } else if type == "month" {
    in-range = is-in-range(year, month, config)
  } else if type == "day" {
    in-range = is-in-range(year, month, config)
  } else if type == "week" {
    // For weeks, check if the Monday of the week is in range
    let monday = date-from-iso-week(year, week)
    in-range = is-in-range(monday.year(), monday.month(), config)
  } else if type == "quarter" {
    // Check if any month in quarter is in range
    let qs = (quarter - 1) * 3 + 1
    in-range = is-in-range(year, qs, config) or is-in-range(year, qs+1, config) or is-in-range(year, qs+2, config)
  }
  
  if not in-range {
    return text(fill: color)[#content]
  }
  
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
  
  link(target, text(fill: color)[#content])
}

// Build breadcrumbs for navigation
#let build-breadcrumbs(config, year, month: none, day: none, week: none, color: black) = {
  let crumbs = ()
  
  // Add month breadcrumb if provided
  if month != none {
    crumbs.push(nav-link(config, get-month-name(month), "month", year, month: month, color: color))
  }
  
  // Always add year breadcrumb
  crumbs.push(nav-link(config, str(year), "year", year, color: color))
  
  // Add quarter breadcrumb if month provided and quarters enabled
  if month != none and config.generation.pages.quarter.enabled {
    let q = get-quarter(month)
    crumbs.push(nav-link(config, "Q" + str(q), "quarter", year, quarter: q, color: color))
  }
  
  // Add week breadcrumb if provided and weeks enabled
  if week != none and config.generation.pages.week.enabled {
    crumbs.push(nav-link(config, "W" + str(week), "week", year, week: week, color: color))
  }
  
  crumbs
}
