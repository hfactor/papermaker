// Unified Layout Utility
#import "dates.typ": *
#import "styles.typ": *
#import "hyperlinks.typ": *
#import "config-helpers.typ": get-colors, get-fonts
#import "../components/sidebar.typ": *

#let breadcrumb(config, items) = items.join(" / ")

#let standard-layout(
  config, 
  title: [], 
  breadcrumbs: (), 
  sidebar-content: none, 
  body: none,
  is-daily: false
) = {
  let colors = get-colors(config)
  let fonts = get-fonts(config)
  
  // Clean breadcrumbs: Only show sections that are actually enabled in the PDF
  let q-enabled = config.generation.pages.quarter.enabled
  let w-enabled = config.generation.pages.week.enabled
  
  let filtered-breadcrumbs = ()
  for b in breadcrumbs {
    let b-str = if type(b) == content { repr(b) } else { str(b) }
    // Very simple check: if it looks like a Q link or W link and that section is disabled, skip it
    // Actually, breadcrumbs are passed as content from components. 
    // It's better to filter them IN the components, but I can do a safety check here if they are strings.
    // However, they are usually nav-links (content).
    filtered-breadcrumbs.push(b)
  }

  let sidebar-pos = config.generation.pages.day.at("sidebar", default: "right")
  
  block(width: 100%, height: 100%)[
    #grid(
      rows: (auto, 1fr),
      row-gutter: 20pt,
      
      grid(
        columns: (1fr, auto),
        align: horizon,
        stack(
          dir: ttb,
          spacing: 8pt,
          if breadcrumbs.len() > 0 {
            text(font: fonts.secondary, size: 11pt, weight: fonts.secondaryWeight, fill: colors.dark1)[
              #breadcrumb(config, breadcrumbs)
            ]
          },
          text(font: fonts.primary, size: fonts.titleSize * 1pt, weight: fonts.primaryWeight, fill: colors.dark1)[#title]
        ),
        // Right side: navigation?
        []
      ),
      
      // 2. Content Area with Sidebar (Restricted to Daily)
      if is-daily and sidebar-content != none and sidebar-pos != "none" {
        let is-landscape = config.output.at("orientation", default: "landscape") == "landscape"
        let cols = if is-landscape { (1fr, 3fr) } else { (1.2fr, 2fr) }
        
        if sidebar-pos == "left" {
          grid(
            columns: cols,
            column-gutter: 0pt,
            sidebar-wrapper(config, sidebar-content, position: "left"),
            block(width: 100%, inset: (left: 15pt))[#body]
          )
        } else {
          grid(
            columns: (cols.at(1), cols.at(0)),
            column-gutter: 0pt,
            block(width: 100%, inset: (right: 15pt))[#body],
            sidebar-wrapper(config, sidebar-content, position: "right")
          )
        }
      } else {
        // Full width body
        block(width: 100%)[#body]
      }
    )
  ]
}
