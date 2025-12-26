// Cover page component
#import "../utils/dates.typ": *

#let cover-page(config) = {
  let cover-conf = config.generation.pages.cover
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let primary-font = config.typography.at("primaryFont", default: "Inter")
  let primary-weight = config.typography.at("primaryFontWeight", default: 700)
  let title-sz = 24pt * config.typography.at("fontScale", default: 1.0)
  
  let title = cover-conf.at("title", default: "")
  let year = config.timeRange.startYear
  let cover-image = cover-conf.at("imageUrl", default: "")
  
  page(margin: 40pt, fill: rgb(config.colors.at("light1", default: "#ffffff")))[
    #set text(fill: dark1)
    #align(center + horizon)[
      #if cover-conf.at("imageUrl", default: "") != "" [
        #rect(width: 70%, height: 40%, stroke: none, fill: none)[
           #image(cover-conf.imageUrl, width: 100%, height: 100%, fit: "contain")
        ]
        #v(2.5em)
      ] else [
        #v(3em)
      ]
      
      #if title != "" [
        #text(font: primary-font, size: title-sz * 2, weight: primary-weight)[#title]
      ] else [
        #text(font: primary-font, size: title-sz * 3, weight: primary-weight)[#str(year)]
      ]
    ]
  ]
}
