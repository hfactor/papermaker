// Main template orchestrator for PDF calendar generation
// This file coordinates all components based on configuration

#import "utils/dates.typ": *
#import "utils/hyperlinks.typ": *
#import "utils/styles.typ": *
#import "components/year.typ": year-calendar
#import "components/quarter.typ": quarter-spread
#import "components/month.typ": month-spread
#import "components/week.typ": week-spread
#import "components/daily.typ": daily-page

// Load configuration from JSON
// In practice, this will be passed via CLI: --input config=path/to/config.json
#let config = json("../examples/full-calendar.json")

// Set document metadata
#set document(
  title: if config.firstPageTitle != "" { config.firstPageTitle } else { "Calendar " + str(config.year) },
  author: "PDF Calendar Generator",
  date: datetime.today()
)

// Set page configuration
#set page(
  paper: "a4",
  margin: (x: 1.5cm, y: 2cm),
  numbering: "1",
)

// Set text defaults
#set text(
  font: config.font,
  size: 10pt,
  fill: rgb(config.primaryColor)
)

// Set paragraph spacing
#set par(justify: false, leading: 0.65em)

// Year Calendar (always first if enabled)
if config.pages.year [
  #year-calendar(config)
]

// Quarter Spreads (if enabled)
if config.pages.quarter [
  #for quarter in range(1, 5) [
    #quarter-spread(config, quarter)
  ]
]

// Month Spreads (if enabled)
if config.pages.month [
  #for month in range(1, 13) [
    #month-spread(config, month)
  ]
]

// Weekly Spreads (if enabled)
if config.pages.week [
  #for month in range(1, 13) [
    #let num-days = days-in-month(config.year, month)
    #let first-day = first-day-of-month(config.year, month)
    
    // Adjust based on start day
    #let offset = if config.startDay == "sunday" {
      calc.rem(first-day + 1, 7)
    } else {
      first-day
    }
    
    // Generate weeks for this month - use for loop with step
    #for week-start in range(1, num-days + 1, step: 7) [
      #week-spread(config, config.year, month, week-start)
    ]
  ]
]

// Daily Pages (if enabled)
if config.pages.daily [
  #for month in range(1, 13) [
    #let num-days = days-in-month(config.year, month)
    #for day in range(1, num-days + 1) [
      #daily-page(config, config.year, month, day)
    ]
  ]
]
