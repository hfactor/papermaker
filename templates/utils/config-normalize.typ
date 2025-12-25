// Config normalization - converts old format to new format
// This allows all components to use the new hierarchical structure

#let normalize-config(raw-config) = {
  // If already in new format, return as-is
  if "timeRange" in raw-config and "generation" in raw-config {
    return raw-config
  }
  
  // Convert old format to new format
  let config = (:)
  
  // Time range
  config.timeRange = (
    startYear: raw-config.at("year", default: datetime.today().year()),
    startMonth: raw-config.at("startMonth", default: 1),
    durationMonths: raw-config.at("totalMonths", default: 12)
  )
  
  // Output
  config.output = (
    pageSize: "a4",
    orientation: "landscape",
    exportMode: "pdf"
  )
  
  // Language
  config.language = (
    code: "en",
    direction: "ltr",
    dateFormat: "YYYY-MM-DD",
    timeFormat: "24h"
  )
  
  // Colors - map old style to new 5-color system
  if "style" in raw-config {
    let style = raw-config.style
    config.colors = (
      dark1: style.at("primaryColor", default: "#000000"),
      dark2: style.at("headerColor", default: "#000000"),
      light1: style.at("bgColor", default: "#ffffff"),
      light2: "#f5f5f5",
      accent: style.at("primaryColor", default: "#0066cc"),
      weekendHighlight: "#eef6ff"
    )
    
    // Typography
    config.typography = (
      primaryFont: style.at("font", default: "Lato"),
      secondaryFont: style.at("headingFont", default: "Inter"),
      fontScale: style.at("baseFontSize", default: 10) / 10.0,
      strokeWidth: style.at("strokeWidth", default: 0.5),
      borderRadius: style.at("borderRadius", default: 2)
    )
  } else {
    config.colors = (
      dark1: "#000000",
      dark2: "#000000",
      light1: "#ffffff",
      light2: "#f5f5f5",
      accent: "#0066cc",
      weekendHighlight: "#eef6ff"
    )
    
    config.typography = (
      primaryFont: "Lato",
      secondaryFont: "Inter",
      fontScale: 1.0,
      strokeWidth: 0.5,
      borderRadius: 2
    )
  }
  
  // Week configuration
  config.week = (
    startDay: raw-config.at("weekStartDay", default: "monday"),
    weekendDays: ("saturday", "sunday"),
    isoWeekNumbers: true
  )
  
  // Note area
  config.noteArea = (
    layout: raw-config.at("paperStyle", default: "plain"),
    density: "medium",
    gridSpacing: if "style" in raw-config { raw-config.style.at("gridSpacing", default: 5) } else { 5 }
  )
  
  // Guides - map old string format to new dictionary format
  let raw-guides = raw-config.at("guides", default: "none")
  if type(raw-guides) == str {
    config.guides = (
      pageCenter: raw-guides == "center",
      horizontalThirds: raw-guides == "thirds",
      verticalThirds: raw-guides == "thirds"
    )
  } else {
    config.guides = raw-guides
  }
  
  // Planner
  config.planner = (
    startTime: if "plannerStartHour" in raw-config {
      let h = raw-config.plannerStartHour
      if h < 10 { "0" + str(h) + ":00" } else { str(h) + ":00" }
    } else { "08:00" },
    endTime: if "plannerEndHour" in raw-config {
      let h = raw-config.plannerEndHour
      if h < 10 { "0" + str(h) + ":00" } else { str(h) + ":00" }
    } else { "20:00" },
    slotDuration: 60,
    timeFormat: "24h",
    showDivisions: raw-config.at("showDivisions", default: false)
  )
  
  // Generation - map old pages to new structure
  let pages-config = raw-config.at("pages", default: (:))
  config.generation = (
    order: raw-config.at("pageOrder", default: "sequential"),
    pages: (
      cover: (
        enabled: pages-config.at("cover", default: false),
        title: raw-config.at("firstPageTitle", default: "Calendar"),
        image: raw-config.at("coverImage", default: none)
      ),
      year: (
        enabled: pages-config.at("year", default: false)
      ),
      quarter: (
        enabled: pages-config.at("quarter", default: false)
      ),
      month: (
        enabled: pages-config.at("month", default: false),
        labels: raw-config.at("monthFormat", default: "full")
      ),
      week: (
        enabled: pages-config.at("week", default: false)
      ),
      day: (
        enabled: pages-config.at("daily", default: false),
        extraDaily: pages-config.at("extraDaily", default: false),
        columnSide: raw-config.at("plannerPos", default: "left")
      )
    )
  )
  
  // Linking
  config.linking = (
    enableHyperlinks: true,
    colorLinks: false
  )
  
  // Print
  config.print = (
    margins: 6,
    bleed: 0,
    colorProfile: "RGB"
  )
  
  return config
}
