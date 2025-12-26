// Modular Sidebar Content Components
#import "../utils/dates.typ": *
#import "../utils/styles.typ": *
#import "../utils/hyperlinks.typ": *
#import "../utils/config-helpers.typ": get-colors, get-fonts

// 1. Planner Module
#let sidebar-planner(config, start-h: 8, end-h: 20, show-divs: false, time-format: "24h") = {
  planner-grid(config, start-h: start-h, end-h: end-h, show-divs: show-divs, time-format: time-format)
}

// 2. To-Do Module
#let sidebar-todo(config, title: "To-Do List") = {
  let colors = get-colors(config)
  let fonts = get-fonts(config)
  
  // Map density to count
  let dens = config.planner.at("density", default: "balanced")
  let count = if dens == "compact" { 24 } else if dens == "spaced" { 16 } else { 20 }

  let item = grid(
    columns: (20pt, 1fr),
    rows: (28pt,),
    align: horizon,
    // Checkbox
    rect(width: 10pt, height: 10pt, stroke: fonts.strokeWidth * 1pt + colors.dark2.transparentize(60%), radius: 2pt),
    // Line
    line(length: 100%, stroke: fonts.strokeWidth * 1pt + colors.dark2.transparentize(85%))
  )

  stack(
    dir: ttb,
    spacing: 0pt,
    ..range(count).map(i => item)
  )
}

// 3. Notes Module
#let sidebar-notes(config, title: "Notes") = {
  paper-block(config, width: 100%, height: 100%)
}

// 4. Sidebar Wrapper
#let sidebar-wrapper(config, content, position: "left") = {
  let colors = get-colors(config)
  let fonts = get-fonts(config)
  let sw = fonts.strokeWidth * 1pt
  
  let border-stroke = sw + colors.dark2.transparentize(80%)
  
  let border = if position == "left" { (right: border-stroke) } 
               else if position == "right" { (left: border-stroke) }
               else { none }

  block(
    width: 100%,
    height: 100%,
    fill: none,  // Remove background fill
    stroke: border,
    inset: (x: 10pt, y: 0pt)
  )[#content]
}
