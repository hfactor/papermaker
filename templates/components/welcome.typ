// Welcome/Guide page component
#import "../utils/dates.typ": *
#import "../utils/styles.typ": *
#import "../utils/layout.typ": *

#let welcome-page(config) = {
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let primary-font = config.typography.at("primaryFont", default: "Inter")
  let primary-weight = config.typography.at("primaryFontWeight", default: 700)
  let secondary-font = config.typography.at("secondaryFont", default: "Inter")
  let secondary-weight = config.typography.at("secondaryFontWeight", default: 400)
  
  [
    #standard-layout(
      config,
      title: [], // No title in standard place
      breadcrumbs: (),
      sidebar-content: none,
      body: align(center + horizon)[
  #block(
    width: 100%,
    inset: 24pt,
    radius: 8pt
  )[
          #set align(left)
          #text(font: primary-font, size: 2em, weight: primary-weight)[About this planner]
          #v(2.5em)
          
          #set text(size: 11pt)
          #set par(leading: 1em)
          #text(font: secondary-font, weight: secondary-weight)[
            This planner was generated using *PaperMaker*, a small open source tool that creates linked PDF planners based on the options you choose.
          ]
          
          #v(1.5em)
          #text(font: secondary-font, weight: secondary-weight)[
            The links inside this file only exist for the views you selected during generation. If you created month, week, or quarter pages, you will see links for them. If something is missing, it was not part of your configuration – you can always generate a new version with the sections you want.
          ]
          
          #v(1.5em)
          #text(font: secondary-font, weight: secondary-weight)[
            Optimized for PDF annotation apps like *GoodNotes*, *Notability*, or *reMarkable*. 
          ]
          
          #v(5em)
          #grid(
            columns: (1fr, 1fr, 1fr, 1fr),
            column-gutter: 1.5em,
            [
              #text(size: 8pt, weight: "bold", fill: dark1.transparentize(50%))[PAPERMAKER] \
              #v(0.4em)
              #text(size: 9pt)[Hiran Venugopalan \
              #link("https://github.com/hiranv/papertools")[Source Page]]
            ],
            [
              #text(size: 8pt, weight: "bold", fill: dark1.transparentize(50%))[ENGINE] \
              #v(0.4em)
              #text(size: 9pt)[Built with Typst \
              #link("https://typst.app")[typst.app]]
            ],
            [
              #text(size: 8pt, weight: "bold", fill: dark1.transparentize(50%))[PRIMARY] \
              #v(0.4em)
              #text(size: 9pt)[#primary-font \
              #link("https://fonts.google.com/?query=" + primary-font.replace(" ", "+"))[Library]]
            ],
            [
               #text(size: 8pt, weight: "bold", fill: dark1.transparentize(50%))[SECONDARY] \
               #v(0.4em)
               #text(size: 9pt)[#secondary-font \
               #link("https://fonts.google.com/?query=" + secondary-font.replace(" ", "+"))[Library]]
            ]
          )
        ]
      ]
    ) <welcome>
  ]
}
