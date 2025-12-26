#let normalize-config(raw-config) = {
  let config = if type(raw-config) == dictionary { raw-config } else { (:) }
  
  // Helper for safe nested access
  let safe-get(dict, key, default) = {
    if type(dict) != dictionary { return default }
    let val = dict.at(key, default: default)
    if val == none { return default }
    return val
  }
  
  // Helper for safe dictionary extraction
  let safe-dict(dict, key) = {
    let val = safe-get(dict, key, (:))
    if type(val) != dictionary { return (:) }
    return val
  }

  // Deep Sanitation Helpers
  let sanitize-timeRange(d) = (
    startYear: safe-get(d, "startYear", 2025),
    startMonth: safe-get(d, "startMonth", 1),
    durationMonths: safe-get(d, "durationMonths", 12)
  )
  
  let sanitize-output(d) = (
    pageSize: safe-get(d, "pageSize", "a4"),
    orientation: safe-get(d, "orientation", "landscape")
  )
  
  let sanitize-typography(d) = (
    primaryFont: safe-get(d, "primaryFont", "Inter"),
    primaryFontWeight: safe-get(d, "primaryFontWeight", 700),
    secondaryFont: safe-get(d, "secondaryFont", "Inter"),
    secondaryFontWeight: safe-get(d, "secondaryFontWeight", 400),
    fontScale: safe-get(d, "fontScale", 1.0),
    titleSize: safe-get(d, "titleSize", 24)
  )
  
  let sanitize-planner(d) = (
    paperStyle: safe-get(d, "paperStyle", "line"),
    density: safe-get(d, "density", "balanced"),
    weekStart: safe-get(d, "weekStart", 1),
    weekendType: safe-get(d, "weekendType", "sat-sun"),
    weekendDays: safe-get(d, "weekendDays", (0, 6))
  )
  
  let sanitize-print(d) = (
    margins: safe-get(d, "margins", 6),
    bleed: safe-get(d, "bleed", 0)
  )

  // 1. Sanitize Top-Level Categories
  config = (
    ..config,
    timeRange: sanitize-timeRange(safe-dict(config, "timeRange")),
    output: sanitize-output(safe-dict(config, "output")),
    typography: sanitize-typography(safe-dict(config, "typography")),
    planner: sanitize-planner(safe-dict(config, "planner")),
    print: sanitize-print(safe-dict(config, "print"))
  )
  
  // 2. Week derived settings - convert from web format to Typst format
  if safe-get(config, "week", none) == none { 
    let ws = config.planner.weekStart
    // Convert from web format (0=Sun, 1=Mon, ..., 6=Sat) to Typst format (0=Mon, ..., 6=Sun)
    let typst-start-day = if ws == 0 { 6 } else { ws - 1 }
    config += (week: (startDay: typst-start-day)) 
  }
  if safe-get(config, "generation", none) == none { config += (generation: (order: "sequential", pages: (:))) }

  // 3. Normalize Page Settings
  let p = safe-dict(config.generation, "pages")
  let gen-pages = (
    cover: (
      enabled: safe-get(safe-dict(p, "cover"), "enabled", false),
      title: safe-get(safe-dict(p, "cover"), "title", ""),
      imageUrl: safe-get(safe-dict(p, "cover"), "imageUrl", "")
    ),
    year: (
      enabled: safe-get(safe-dict(p, "year"), "enabled", true)
    ),
    quarter: (
      enabled: safe-get(safe-dict(p, "quarter"), "enabled", true),
      type: safe-get(safe-dict(p, "quarter"), "type", "calendar")
    ),
    month: (
      enabled: safe-get(safe-dict(p, "month"), "enabled", true)
    ),
    week: (
      enabled: safe-get(safe-dict(p, "week"), "enabled", true)
    ),
    day: (
      enabled: safe-get(safe-dict(p, "day"), "enabled", true),
      extraDaily: safe-get(safe-dict(p, "day"), "extraDaily", false),
      sidebar: safe-get(safe-dict(p, "day"), "sidebar", "right"),
      sidebarEnabled: safe-get(safe-dict(p, "day"), "sidebarEnabled", true),
      sidebarModule: safe-get(safe-dict(p, "day"), "sidebarModule", "planner"),
      startTime: safe-get(safe-dict(p, "day"), "startTime", "08:00"),
      endTime: safe-get(safe-dict(p, "day"), "endTime", "20:00"),
      timeFormat: safe-get(safe-dict(p, "day"), "timeFormat", "24h"),
      showHalfHour: safe-get(safe-get(p, "day", (:)), "showHalfHour", false)
    )
  )
  
  config = (
    ..config,
    generation: (
      ..config.generation,
      pages: gen-pages
    )
  )

  // 4. Final Color Sanitation & Derivation
  let base-dark1-hex = safe-get(config.colors, "dark1", "#18181b")
  let base-light1-hex = safe-get(config.colors, "light1", "#ffffff")
  let base-accent-hex = safe-get(config.colors, "accent", "#3e63dd")
  
  let current-colors = (
    dark1: base-dark1-hex,
    light1: base-light1-hex,
    accent: base-accent-hex
  )
  
  let base-dark1 = rgb(base-dark1-hex)
  let base-light1 = rgb(base-light1-hex)
  let base-accent = rgb(base-accent-hex)
  
  current-colors += (dark2: base-dark1.transparentize(50%).to-hex())
  current-colors += (light2: base-accent.mix((base-light1, 70%)).to-hex())
  
  config = (..config, colors: current-colors)

  return config
}
