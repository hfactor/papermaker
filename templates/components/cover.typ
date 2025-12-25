// Cover page component

#import "../utils/dates.typ": *

#let cover-page(config) = {
  // Config is normalized
  let cover-conf = config.generation.pages.cover
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let primary-font = config.typography.at("primaryFont", default: "Lato")
  let title-sz = 48pt * 1.5 * config.typography.at("fontScale", default: 1.0)
  
  // Get title and image
  let title = cover-conf.at("title", default: "Calendar")
  let year = config.timeRange.startYear
  let cover-image = cover-conf.at("image", default: none)
  
  page(margin: 0pt, fill: dark1)[
    #align(center + horizon)[
      #if cover-image != none and cover-image != "" [
        #image(cover-image, width: 80%)
        #v(2em)
      ] else [
        #v(4em)
        #text(font: primary-font, size: title-sz * 2, weight: "bold", fill: white)[#str(year)]
        #v(2em)
      ]
      #text(font: primary-font, size: title-sz, weight: "bold", fill: white)[#title]
    ]
  ]
}
