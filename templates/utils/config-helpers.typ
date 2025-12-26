// Configuration helper functions for cleaner component code
// These are INTERNAL helpers - JSON format unchanged

#import "dates.typ": *

// Get all colors with proper RGB conversion and derived colors
#let get-colors(config) = {
  let dark1 = rgb(config.colors.at("dark1", default: "#18181b"))
  let dark2 = rgb(config.colors.at("dark2", default: "#71717a"))
  let light1 = rgb(config.colors.at("light1", default: "#ffffff"))
  let light2 = rgb(config.colors.at("light2", default: "#f4f4f5"))
  let accent = rgb(config.colors.at("accent", default: "#3e63dd"))
  
  // Derive weekend fill color
  let weekendFill = if config.colors.at("weekendHighlight", default: none) != none {
    rgb(config.colors.weekendHighlight).transparentize(85%)
  } else {
    light2.transparentize(85%)
  }
  
  (
    dark1: dark1,
    dark2: dark2,
    light1: light1,
    light2: light2,
    accent: accent,
    weekendFill: weekendFill
  )
}

// Get all typography settings
#let get-fonts(config) = (
  primary: config.typography.at("primaryFont", default: "Inter"),
  primaryWeight: config.typography.at("primaryFontWeight", default: 700),
  secondary: config.typography.at("secondaryFont", default: "Inter"),
  secondaryWeight: config.typography.at("secondaryFontWeight", default: 400),
  scale: config.typography.at("fontScale", default: 1.0),
  titleSize: config.typography.at("titleSize", default: 24),
  strokeWidth: config.typography.at("strokeWidth", default: 0.5)
)

// Get density scale multiplier for spacing adjustments
#let get-density-scale(config) = {
  let dens = config.planner.at("density", default: "balanced")
  if dens == "compact" { 0.85 }
  else if dens == "spaced" { 1.15 }
  else { 1.0 }
}

// Get month label format
#let get-month-label-format(config) = {
  config.generation.pages.month.at("labels", default: "full")
}
