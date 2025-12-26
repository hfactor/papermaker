// Modular Sidebar Content Components
#import "../utils/dates.typ": *
#import "../utils/styles.typ": *
#import "../utils/hyperlinks.typ": *

// 1. Planner Module
#let sidebar-planner(config, start-h: 8, end-h: 20, show-divs: false, time-format: "24h") = {
  planner-grid(config, start-h: start-h, end-h: end-h, show-divs: show-divs, time-format: time-format)
}

// 2. To-Do Module
#let sidebar-todo(config, title: "To-Do List") = {
  let dark2 = rgb(config.colors.at("dark2", default: "#000000"))
  let stroke-w = config.typography.at("strokeWidth", default: 0.5) * 1pt
  
  // Map density to count
  let dens = config.planner.at("density", default: "balanced")
  let count = if dens == "compact" { 24 } else if dens == "spaced" { 16 } else { 20 }

  let item = grid(
    columns: (20pt, 1fr),
    rows: (28pt,),
    align: horizon,
    // Checkbox
    rect(width: 10pt, height: 10pt, stroke: stroke-w + dark2.transparentize(60%), radius: 2pt),
    // Line
    line(length: 100%, stroke: stroke-w + dark2.transparentize(85%))
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
  let dark2 = rgb(config.colors.at("dark2", default: "#000000"))
  let sw = config.typography.at("strokeWidth", default: 0.5) * 1pt
  
  let light2 = rgb(config.colors.at("light2", default: "#f4f4f5"))
  let border-stroke = sw + dark2.transparentize(80%)
  
  let border = if position == "left" { (right: border-stroke) } 
               else if position == "right" { (left: border-stroke) }
               else { none }

  block(
    width: 100%,
    height: 100%,
    fill: light2,
    stroke: border,
    inset: (x: 10pt, y: 0pt)
  )[#content]
}
