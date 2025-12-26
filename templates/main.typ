// Main template orchestrator for PDF calendar generation
#import "utils/dates.typ": *
#import "utils/hyperlinks.typ": *
#import "utils/styles.typ": *
#import "components/cover.typ": cover-page
#import "components/welcome.typ": welcome-page
#import "components/year.typ": year-calendar
#import "components/quarter.typ": quarter-spread
#import "components/month.typ": month-spread
#import "components/week.typ": week-spread
#import "components/daily.typ": daily-page, extra-daily-page

// Load configuration from sys.inputs or fallback
#import "utils/config-normalize.typ": normalize-config
#import "utils/config-helpers.typ": get-colors, get-fonts
#let raw-config = if sys.inputs.at("config", default: none) != none {
  json(sys.inputs.config)
} else {
  json("../examples/new-config.json")
}
#let config = normalize-config(raw-config)
#let colors = get-colors(config)
#let fonts = get-fonts(config)

// Pre-calculate date ranges
#let start-month = config.timeRange.startMonth
#let total-months = config.timeRange.durationMonths
#let start-year = config.timeRange.startYear
#let months-to-gen = month-list(start-year, start-month, total-months)
#let page-order = config.generation.order

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
  title: config.generation.pages.cover.title,
  author: "PaperTools",
  date: datetime.today()
)

// Set global page background (Light 1)
#set page(
  paper: config.output.pageSize,
  flipped: config.output.orientation == "landscape",
  margin: config.print.margins * 1mm,
  fill: colors.light1
)

// Set text defaults (Secondary / Body Font)
#set text(
  font: config.typography.secondaryFont,
  weight: config.typography.secondaryFontWeight,
  size: (config.typography.fontScale * 10) * 1pt,
  fill: colors.dark1
)

// Set paragraph spacing
#set par(justify: false, leading: 0.65em)

// 1. Cover Page
#if config.generation.pages.cover.enabled {
  pagebreak(weak: true)
  cover-page(config)
}

// 2. Welcome Page (UDS V1)
#pagebreak(weak: true)
#welcome-page(config)

// 3. Year Calendar
#if config.generation.pages.year.enabled {
  pagebreak(weak: true)
  year-calendar(config)
}

// 4. Helper Functions for Page Generation
#let generate-quarters(config, quarters) = {
  if config.generation.pages.quarter.enabled {
    for q in quarters { 
      pagebreak(weak: true)
      quarter-spread(config, q.quarter, year: q.year) 
    }
  }
}

#let generate-months(config, months) = {
  if config.generation.pages.month.enabled {
    for m in months { 
      pagebreak(weak: true)
      month-spread(config, m.month, year: m.year) 
    }
  }
}

#let generate-weeks(config, weeks) = {
  if config.generation.pages.week.enabled {
    for w in weeks { 
      pagebreak(weak: true)
      week-spread(config, w.year, w.week) 
    }
  }
}

#let generate-days-for-month(config, year, month) = {
  for day in range(1, days-in-month(year, month) + 1) {
    pagebreak(weak: true)
    daily-page(config, year, month, day)
    if config.generation.pages.day.extraDaily { 
      pagebreak(weak: true)
      extra-daily-page(config, year, month, day) 
    }
  }
}

#let generate-days-for-week(config, week-year, week-num) = {
  let start-date = date-from-iso-week(week-year, week-num)
  for i in range(7) {
    let d = start-date + duration(days: i)
    if is-in-range(d.year(), d.month(), config) {
      pagebreak(weak: true)
      daily-page(config, d.year(), d.month(), d.day())
      if config.generation.pages.day.extraDaily { 
        pagebreak(weak: true)
        extra-daily-page(config, d.year(), d.month(), d.day()) 
      }
    }
  }
}

// 5. Page Ordering Logic
#let quarter-enabled = config.generation.pages.quarter.enabled
#let month-enabled = config.generation.pages.month.enabled
#let week-enabled = config.generation.pages.week.enabled
#let day-enabled = config.generation.pages.day.enabled

#if page-order == "sequential" {
  generate-quarters(config, quarters-to-gen)
  generate-months(config, months-to-gen)
  generate-weeks(config, weeks-to-gen)
  if day-enabled {
    for m in months-to-gen {
      generate-days-for-month(config, m.year, m.month)
    }
  }
} else if page-order == "month-days" {
  generate-quarters(config, quarters-to-gen)
  for m in months-to-gen {
    if month-enabled { 
      pagebreak(weak: true)
      month-spread(config, m.month, year: m.year) 
    }
    if day-enabled {
      generate-days-for-month(config, m.year, m.month)
    }
  }
  generate-weeks(config, weeks-to-gen)
} else if page-order == "week-days" {
  generate-quarters(config, quarters-to-gen)
  generate-months(config, months-to-gen)
  for w in weeks-to-gen {
    if week-enabled { 
      pagebreak(weak: true)
      week-spread(config, w.year, w.week) 
    }
    if day-enabled {
      generate-days-for-week(config, w.year, w.week)
    }
  }
}
