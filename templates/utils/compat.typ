// Backward compatibility helpers for config access
// These functions check for both old and new config formats

// Get color value - supports both new (config.colors.dark1) and old (config.style.primaryColor) formats
#let get-color(config, color-name) = {
  if "colors" in config {
    // New format
    if color-name == "dark1" {
      rgb(config.colors.at("dark1", default: "#000000"))
    } else if color-name == "dark2" {
      rgb(config.colors.at("dark2", default: "#000000"))
    } else if color-name == "light1" {
      rgb(config.colors.at("light1", default: "#ffffff"))
    } else if color-name == "light2" {
      rgb(config.colors.at("light2", default: "#f5f5f5"))
    } else if color-name == "accent" {
      rgb(config.colors.at("accent", default: "#0066cc"))
    } else if color-name == "weekend" {
      rgb(config.colors.at("weekendHighlight", default: "#eef6ff"))
    } else {
      black
    }
  } else if "style" in config {
    // Old format - map to old color names
    let style = config.style
    if color-name == "dark1" or color-name == "accent" {
      rgb(style.at("primaryColor", default: "#000000"))
    } else if color-name == "dark2" {
      let header-color = rgb(style.at("headerColor", default: "#000000"))
      header-color.transparentize(60%)
    } else if color-name == "light1" {
      rgb(style.at("bgColor", default: "#ffffff"))
    } else if color-name == "weekend" {
      let primary = rgb(style.at("primaryColor", default: "#000000"))
      primary.transparentize(85%)
    } else {
      black
    }
  } else {
    black
  }
}

// Get font name
#let get-font(config, font-type: "primary") = {
  if "typography" in config {
    if font-type == "primary" {
      config.typography.at("primaryFont", default: "Lato")
    } else {
      config.typography.at("secondaryFont", default: "Lato")
    }
  } else if "style" in config {
    if font-type == "primary" {
      config.style.at("font", default: "Lato")
    } else {
      config.style.at("headingFont", default: "Inter")
    }
  } else {
    "Lato"
  }
}

// Get font scale
#let get-font-scale(config) = {
  if "typography" in config {
    config.typography.at("fontScale", default: 1.0)
  } else {
    1.0
  }
}

// Get year
#let get-year(config) = {
  if "timeRange" in config {
    config.timeRange.at("startYear", default: datetime.today().year())
  } else {
    config.at("year", default: datetime.today().year())
  }
}

// Check if page type is enabled
#let is-page-enabled(config, page-type) = {
  if "generation" in config {
    if page-type == "cover" {
      config.generation.pages.cover.at("enabled", default: false)
    } else if page-type == "year" {
      config.generation.pages.year.at("enabled", default: false)
    } else if page-type == "quarter" {
      config.generation.pages.quarter.at("enabled", default: false)
    } else if page-type == "month" {
      config.generation.pages.month.at("enabled", default: false)
    } else if page-type == "week" {
      config.generation.pages.week.at("enabled", default: false)
    } else if page-type == "day" {
      config.generation.pages.day.at("enabled", default: false)
    } else {
      false
    }
  } else if "pages" in config {
    if page-type == "day" {
      config.pages.at("daily", default: false)
    } else {
      config.pages.at(page-type, default: false)
    }
  } else {
    false
  }
}

// Get month label format
#let get-month-format(config) = {
  if "generation" in config {
    config.generation.pages.month.at("labels", default: "full")
  } else {
    config.at("monthFormat", default: "full")
  }
}

// Get title
#let get-title(config) = {
  if "generation" in config {
    config.generation.pages.cover.at("title", default: "Calendar")
  } else {
    if "firstPageTitle" in config and config.firstPageTitle != "" {
      config.firstPageTitle
    } else {
      "Calendar"
    }
  }
}

// Get planner column side
#let get-planner-side(config) = {
  if "generation" in config {
    config.generation.pages.day.at("columnSide", default: "left")
  } else {
    config.at("plannerPos", default: "left")
  }
}

// Get planner start/end times
#let get-planner-hours(config) = {
  if "planner" in config {
    let start-time = config.planner.at("startTime", default: "08:00")
    let end-time = config.planner.at("endTime", default: "20:00")
    (
      start: int(start-time.slice(0, 2)),
      end: int(end-time.slice(0, 2))
    )
  } else {
    (
      start: config.at("plannerStartHour", default: 8),
      end: config.at("plannerEndHour", default: 20)
    )
  }
}
