// Styling utilities for calendar components
#import "dates.typ": *
#import "hyperlinks.typ": *

// Guide patterns (Centre, Thirds) as content instead of patterns
#let guide-overlay(config, width: 100%, height: 100%) = {
  let guide-conf = config.at("guides", default: (:))
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let color = dark1.transparentize(80%) // Very subtle
  
  box(width: width, height: height)[
    #if guide-conf.at("pageCenter", default: false) {
      // Diamonds at center edges
      place(top + center, dy: -2pt, polygon(fill: color, (0pt, 0pt), (4pt, 4pt), (0pt, 8pt), (-4pt, 4pt)))
      place(bottom + center, dy: 2pt, polygon(fill: color, (0pt, 0pt), (4pt, 4pt), (0pt, 8pt), (-4pt, 4pt)))
      place(horizon + left, dx: -2pt, polygon(fill: color, (0pt, 0pt), (4pt, 4pt), (8pt, 0pt), (4pt, -4pt)))
      place(horizon + right, dx: 2pt, polygon(fill: color, (0pt, 0pt), (4pt, -4pt), (8pt, 0pt), (4pt, 4pt)))
    } 
    
    #if guide-conf.at("horizontalThirds", default: false) {
      // Horizontal markers at thirds
      place(top + left, dy: 33.3%, dx: -2pt, polygon(fill: color, (0pt, 0pt), (6pt, 4pt), (6pt, -4pt)))
      place(top + left, dy: 66.6%, dx: -2pt, polygon(fill: color, (0pt, 0pt), (6pt, 4pt), (6pt, -4pt)))
      place(top + right, dy: 33.3%, dx: 2pt, polygon(fill: color, (0pt, 0pt), (-6pt, 4pt), (-6pt, -4pt)))
      place(top + right, dy: 66.6%, dx: 2pt, polygon(fill: color, (0pt, 0pt), (-6pt, 4pt), (-6pt, -4pt)))
    }

    #if guide-conf.at("verticalThirds", default: false) {
      // Vertical markers at thirds
      place(top + left, dx: 33.3%, dy: -2pt, polygon(fill: color, (0pt, 0pt), (4pt, 6pt), (-4pt, 6pt)))
      place(top + left, dx: 66.6%, dy: -2pt, polygon(fill: color, (0pt, 0pt), (4pt, 6pt), (-4pt, 6pt)))
      place(bottom + left, dx: 33.3%, dy: 2pt, polygon(fill: color, (0pt, 0pt), (4pt, -6pt), (-4pt, -6pt)))
      place(bottom + left, dx: 66.6%, dy: 2pt, polygon(fill: color, (0pt, 0pt), (4pt, -6pt), (-4pt, -6pt)))
    }
  ]
}

// Paper background patterns (Grid/Dot/Line) with proportional spacing
#let paper-pattern(config, width: none, height: none) = {
  let note-conf = config.at("noteArea", default: (:))
  let style = note-conf.at("layout", default: "plain")
  let accent-color = rgb(config.colors.at("accent", default: "#000000"))
  let color = accent-color.transparentize(85%)
  
  // Base spacing from config
  let base-spacing = note-conf.at("gridSpacing", default: 5) * 1mm
  let stroke-w = config.typography.at("strokeWidth", default: 0.3) * 1pt
  
  // Calculate proportional spacing if width/height are provided
  let (sx, sy) = (base-spacing, base-spacing)
  if width != none and height != none {
    let cols = calc.round(width / base-spacing)
    let rows = calc.round(height / base-spacing)
    if cols > 0 { sx = width / cols }
    if rows > 0 { sy = height / rows }
  }

  if style == "grid" {
    tiling(size: (sx, sy))[
      #place(top + left, line(start: (0pt, 0pt), end: (sx, 0pt), stroke: stroke-w + color))
      #place(top + left, line(start: (0pt, 0pt), end: (0pt, sy), stroke: stroke-w + color))
    ]
  } else if style == "dot" {
    tiling(size: (sx, sy))[
      #place(center + horizon, circle(radius: stroke-w, fill: color))
    ]
  } else if style == "line" {
    tiling(size: (sx, sy))[
      #place(top + left, line(start: (0pt, 0pt), end: (sx, 0pt), stroke: stroke-w + color))
    ]
  } else {
    none
  }
}

// Minimal divider
#let divider(config, color: none) = {
  let c = if color != none { color } else { rgb(config.colors.at("dark2", default: "#000000")) }
  let sw = config.typography.at("strokeWidth", default: 0.5) * 1pt
  line(length: 100%, stroke: sw + c)
}

// Section header with custom font
#let section-header(config, content, color: none, size: none) = {
  let c = if color != none { color } else { rgb(config.colors.at("dark1", default: "#000000")) }
  let base-sz = 12pt * config.typography.at("fontScale", default: 1.0)
  let sz = if size != none { size } else { base-sz }
  let f = config.typography.at("primaryFont", default: "Lato")
  
  text(font: f, size: sz, weight: "bold", fill: c)[#content]
}

// Breadcrumb with config
#let breadcrumb(config, items, color: none) = {
  let c = if color != none { color } else { rgb(config.colors.at("accent", default: "#000000")) }
  let parts = ()
  
  for (i, item) in items.enumerate() {
    if i > 0 {
      parts.push(text(fill: c)[ → ])
    }
    parts.push(item)
  }
  
  parts.join()
}

// Navigation header
#let nav-header(config, back-link, title, color: none) = {
  let c = if color != none { color } else { rgb(config.colors.at("dark1", default: "#000000")) }
  let f = config.typography.at("primaryFont", default: "Lato")
  let base-sz = 14pt * config.typography.at("fontScale", default: 1.0)
  let sz = base-sz

  grid(
    columns: (1fr, 2fr, 1fr),
    align: (left, center, right),
    back-link,
    text(font: f, size: sz, weight: "bold", fill: c)[#title],
    []
  )
}

// Apply paper style and guides to a block
#let paper-block(config, width: 100%, height: 100%, body: none, force-plain: false, show-guides: true, override-layout: none) = {
  block(
    width: width, 
    height: height, 
    stroke: none,
    inset: 0pt
  )[
    #layout(size => {
      let bg-pattern = if force-plain { none } else { 
        if override-layout != none {
           // Create a modified config for paper-pattern
           let mod-note = config.at("noteArea", default: (:))
           mod-note.insert("layout", override-layout)
           let mod-config = config
           mod-config.insert("noteArea", mod-note)
           paper-pattern(mod-config, width: size.width, height: size.height)
        } else {
           paper-pattern(config, width: size.width, height: size.height) 
        }
      }
      if bg-pattern != none {
        place(top + left, rect(width: 100%, height: 100%, fill: bg-pattern, stroke: none))
      }
      
      // 2. Guides
      if show-guides {
         place(top + left, guide-overlay(config, width: size.width, height: size.height))
      }

      // 3. Body
      if body != none { body }
    })
  ]
}

// Shared Date Header Component
#let date-header(config, year, month, day, size: "large", show-divider: true) = {
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let dark2 = rgb(config.colors.at("dark2", default: "#000000"))
  let primary-font = config.typography.at("primaryFont", default: "Lato")
  
  let month-name = get-month-name(month, format: "full")
  let dow = day-of-week(year, month, day)
  let day-name = get-day-name(dow, format: "full")
  
  let (year-sz, date-sz, sub-sz) = if size == "large" {
    (14pt, 54pt, 14pt)
  } else {
    (10pt, 32pt, 10pt)
  }
  
  let stroke-w = config.typography.at("strokeWidth", default: 0.5) * 1pt
  let line-h = if size == "large" { 24pt } else { 14pt }
  
  block(width: 100%)[
    #nav-link(config, text(font: primary-font, size: year-sz, weight: "bold", fill: dark1)[#str(year)], "year", year, color: dark1)
    #v(if size == "large" { 2pt } else { 0pt })
    #grid(
      columns: (auto, auto, auto),
      column-gutter: 12pt,
      align: horizon,
      text(font: primary-font, size: date-sz, weight: "bold", fill: dark1)[#fmt-dd(day)],
      if show-divider {
        line(start: (0pt, -line-h), end: (0pt, line-h), stroke: stroke-w + dark2.transparentize(80%))
      },
      stack(
        dir: ttb,
        spacing: 6pt, // Increased spacing
        nav-link(config, text(font: primary-font, size: sub-sz, weight: "bold", fill: dark2.transparentize(40%))[#month-name], "month", year, month: month, color: dark2.transparentize(40%)),
        text(font: primary-font, size: sub-sz - 2pt, weight: "bold", fill: dark2.transparentize(40%))[#day-name] // Smaller day
      )
    )
  ]
}
// Safe hour parsing from string or int
#let safe-parse-hour(t, default: 8) = {
  if type(t) == int { return t }
  if type(t) != str { return default }
  let parts = t.split(":")
  if parts.len() > 0 {
    let h-str = parts.at(0)
    if h-str.len() > 0 {
      // Handle cases like "08" or "8"
      return int(h-str)
    }
  }
  return default
}

// Shared Planner Grid Component
#let planner-grid(config, start-h: 6, end-h: 22, show-divs: false, text-size: 8pt, gutter: 8pt) = {
  let dark2 = rgb(config.colors.at("dark2", default: "#000000"))
  let stroke-w = config.typography.at("strokeWidth", default: 0.5) * 1pt
  
  // Ensure we have numbers even if parsing failed partially
  let sh = if type(start-h) == int { start-h } else { 8 }
  let eh = if type(end-h) == int { end-h } else { 20 }
  
  let hours = range(sh, eh + 1)
  let row-count = if show-divs { 
    if eh > sh { hours.len() * 2 - 1 } else { 1 }
  } else { hours.len() }
  
  grid(
    columns: (auto, 1fr),
    rows: (1fr,) * row-count, 
    row-gutter: 0pt,
    column-gutter: gutter,
    ..{
      let items = ()
      for i in range(hours.len()) {
        let h = hours.at(i)
        let t = if h < 10 { "0" + str(h) + ":00" } else { str(h) + ":00" }
        
        // Row 1: Time + Line
        items.push(align(right + horizon)[
          #text(size: text-size, weight: "bold", fill: dark2.transparentize(40%))[#t]
        ])
        items.push(align(horizon)[#line(length: 100%, stroke: stroke-w + dark2.transparentize(80%))])
        
        // Row 2: Empty + Half-hour Line (Conditional)
        if show-divs and h < eh {
          items.push([])
          items.push(align(horizon)[#line(length: 100%, stroke: (thickness: stroke-w, paint: dark2.transparentize(90%), dash: "dotted"))])
        }
      }
      items
    }
  )
}

// Unified Planner Column Component
#let planner-column(config, header, start-h: 8, end-h: 20, show-divs: false, text-size: 8pt, show-border: true, gutter: 8pt) = {
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let dark2 = rgb(config.colors.at("dark2", default: "#000000"))
  let sw = config.typography.at("strokeWidth", default: 0.5) * 1pt
  
  let st = if show-border { sw + dark2.transparentize(80%) } else { none }
  
  rect(
    width: 100%,
    height: 100%,
    fill: none,
    stroke: st,
    inset: (x: if show-border { 6pt } else { 0pt }, y: if show-border { 10pt } else { 0pt }),
    radius: 0pt
  )[
    #grid(
      rows: (auto, 1fr),
      row-gutter: if header != [] { 8pt } else { 0pt },
      header,
      planner-grid(config, start-h: start-h, end-h: end-h, show-divs: show-divs, text-size: text-size, gutter: gutter)
    )
  ]
}
