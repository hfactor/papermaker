// Styling utilities for calendar components

// Paper background styles
#let paper-background(style, color: rgb("#f0f0f0"), spacing: 5mm) = {
  if style == "grid" {
    // Grid pattern
    pattern(size: (spacing, spacing))[
      #place(line(start: (0%, 0%), end: (100%, 0%), stroke: 0.3pt + color))
      #place(line(start: (0%, 0%), end: (0%, 100%), stroke: 0.3pt + color))
    ]
  } else if style == "dot" {
    // Dot pattern
    pattern(size: (spacing, spacing))[
      #place(dx: 0%, dy: 0%, circle(radius: 0.3pt, fill: color))
    ]
  } else if style == "line" {
    // Horizontal lines
    pattern(size: (100%, spacing))[
      #place(line(start: (0%, 0%), end: (100%, 0%), stroke: 0.3pt + color))
    ]
  } else {
    // Plain - no pattern
    none
  }
}

// Apply paper style to a page
#let styled-page(content, style, color: rgb("#e0e0e0")) = {
  if style == "plain" {
    content
  } else {
    place(
      top + left,
      dx: 0pt,
      dy: 0pt,
      rect(
        width: 100%,
        height: 100%,
        fill: paper-background(style, color: color),
        stroke: none
      )
    )
    content
  }
}

// Weekend cell styling
#let weekend-cell(content, is-weekend, weekend-color) = {
  if is-weekend {
    rect(
      width: 100%,
      height: 100%,
      fill: weekend-color,
      inset: 4pt,
      stroke: none
    )[#content]
  } else {
    content
  }
}

// Calendar cell with optional background
#let calendar-cell(content, bg-color: none, text-color: black, size: 12pt) = {
  let cell-content = text(size: size, fill: text-color)[#content]
  
  if bg-color != none {
    rect(
      width: 100%,
      height: 100%,
      fill: bg-color,
      inset: 4pt,
      stroke: 0.5pt + rgb("#d0d0d0")
    )[#cell-content]
  } else {
    rect(
      width: 100%,
      height: 100%,
      inset: 4pt,
      stroke: 0.5pt + rgb("#d0d0d0")
    )[#cell-content]
  }
}

// Header styling
#let section-header(content, color: black, size: 18pt) = {
  text(size: size, weight: "bold", fill: color)[#content]
}

// Minimal divider
#let divider(color: rgb("#d0d0d0")) = {
  line(length: 100%, stroke: 0.5pt + color)
}
