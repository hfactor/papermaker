// Cover page component
#import "../utils/dates.typ": *
#import "../utils/config-helpers.typ": get-colors, get-fonts

#let cover-page(config) = {
  let cover-conf = config.generation.pages.cover
  let colors = get-colors(config)
  let fonts = get-fonts(config)
  let title-sz = 24pt * config.typography.at("fontScale", default: 1.0)
  
  let title = cover-conf.at("title", default: "")
  let year = config.timeRange.startYear
  let cover-image = cover-conf.at("imageUrl", default: "")
  
  page(margin: 40pt, fill: colors.light1)[
    #set text(fill: colors.dark1)
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
        #text(font: fonts.primary, size: title-sz * 2, weight: fonts.primaryWeight)[#title]
      ] else [
        #text(font: fonts.primary, size: title-sz * 3, weight: fonts.primaryWeight)[#str(year)]
      ]
    ]
  ]
}
