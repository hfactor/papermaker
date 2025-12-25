// Main template orchestrator for PDF calendar generation
// This file coordinates all components based on configuration

#import "utils/dates.typ": *
#import "utils/hyperlinks.typ": *
#import "utils/styles.typ": *
#import "components/cover.typ": cover-page
#import "components/year.typ": year-calendar
#import "components/quarter.typ": quarter-spread
#import "components/month.typ": month-spread
#import "components/week.typ": week-spread
#import "components/daily.typ": daily-page, extra-daily-page

// Load configuration from JSON
#import "utils/config-normalize.typ": normalize-config
#let raw-config = json("../examples/new-config.json")
#let config = normalize-config(raw-config)


// Pre-calculate date ranges (config is now normalized to new format)
#let start-month = config.timeRange.at("startMonth", default: 1)
#let total-months = config.timeRange.at("durationMonths", default: 12)
#let start-year = config.timeRange.at("startYear", default: datetime.today().year())
#let months-to-gen = month-list(start-year, start-month, total-months)
#let page-order = config.generation.at("order", default: "sequential")

// Create unique list of quarters to generate
#let quarters-to-gen = ()
#let seen-quarters = (:)
#for m in months-to-gen {
  let q = get-quarter(m.month)
  let key = str(m.year) + "-" + str(q)
  if seen-quarters.at(key, default: false) == false {
    quarters-to-gen.push((year: m.year, quarter: q))
    seen-quarters.insert(key, true)
  }
}

// Create list of weeks to generate
#let weeks-to-gen = week-list(months-to-gen)

// Set document metadata
#set document(
  title: config.generation.pages.cover.at("title", default: "Calendar"),
  author: "PDF Calendar Generator",
  date: datetime.today()
)

// Set page configuration
#set page(
  paper: config.output.at("pageSize", default: "a4"),
  margin: config.print.at("margins", default: 6) * 1mm,
  flipped: config.output.at("orientation", default: "portrait") == "landscape",
  fill: rgb(config.colors.at("light1", default: "#ffffff"))
)

// Set text defaults
#set text(
  font: config.typography.at("primaryFont", default: "Lato"),
  size: (config.typography.at("fontScale", default: 1.0) * 10) * 1pt,
  fill: rgb(config.colors.at("dark1", default: "#000000"))
)

// Set paragraph spacing
#set par(justify: false, leading: 0.65em)

// 1. Cover Page
#if config.generation.pages.cover.at("enabled", default: false) {
  pagebreak(weak: true)
  cover-page(config)
}

// 2. Year Calendar
#if config.generation.pages.year.at("enabled", default: false) {
  pagebreak(weak: true)
  year-calendar(config)
}

// 3. Page Ordering Logic
#let quarter-enabled = config.generation.pages.at("quarter", default: (:)).at("enabled", default: false)
#let month-enabled = config.generation.pages.at("month", default: (:)).at("enabled", default: false)
#let week-enabled = config.generation.pages.at("week", default: (:)).at("enabled", default: false)
#let day-enabled = config.generation.pages.at("day", default: (:)).at("enabled", default: false)
#let extra-enabled = config.generation.pages.day.at("extraDaily", default: false)

#let extra-page(year, month, day) = {
  pagebreak(weak: true)
  extra-daily-page(config, year, month, day)
}

#if page-order == "sequential" {
  // Quarters
  if quarter-enabled {
    for q in quarters-to-gen {
      pagebreak(weak: true)
      quarter-spread(config, q.quarter, year: q.year)
    }
  }
  
  // Months
  if month-enabled {
    for m in months-to-gen {
      pagebreak(weak: true)
      month-spread(config, m.month, year: m.year)
    }
  }
  
  // Weeks
  if week-enabled {
    for w in weeks-to-gen {
      pagebreak(weak: true)
      week-spread(config, w.year, w.week)
    }
  }
  
  // Days
  if day-enabled {
    for m in months-to-gen {
      let num-days = days-in-month(m.year, m.month)
      for day in range(1, num-days + 1) {
        pagebreak(weak: true)
        daily-page(config, m.year, m.month, day)
        if extra-enabled { extra-page(m.year, m.month, day) }
      }
    }
  }
} else if page-order == "interleaved-month" {
  if quarter-enabled {
    for q in quarters-to-gen {
      pagebreak(weak: true)
      quarter-spread(config, q.quarter, year: q.year)
    }
  }
  
  for m in months-to-gen {
    if month-enabled {
      pagebreak(weak: true)
      month-spread(config, m.month, year: m.year)
    }
    
    if day-enabled {
      let num-days = days-in-month(m.year, m.month)
      for day in range(1, num-days + 1) {
        pagebreak(weak: true)
        daily-page(config, m.year, m.month, day)
        if extra-enabled { extra-page(m.year, m.month, day) }
      }
    }
  }
} else if page-order == "interleaved-week" {
  if quarter-enabled {
    for q in quarters-to-gen {
      pagebreak(weak: true)
      quarter-spread(config, q.quarter, year: q.year)
    }
  }
  
  if month-enabled {
    for m in months-to-gen {
      pagebreak(weak: true)
      month-spread(config, m.month, year: m.year)
    }
  }
  
  for w in weeks-to-gen {
    if week-enabled {
      pagebreak(weak: true)
      week-spread(config, w.year, w.week)
    }
    
    if day-enabled {
      let start-date = date-from-iso-week(w.year, w.week)
      for i in range(7) {
        let d = start-date + duration(days: i)
        pagebreak(weak: true)
        daily-page(config, d.year(), d.month(), d.day())
        if extra-enabled { extra-page(d.year(), d.month(), d.day()) }
      }
    }
  }
}
