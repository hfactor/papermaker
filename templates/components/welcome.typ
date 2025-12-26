// Welcome/Guide page component
#import "../utils/dates.typ": *
#import "../utils/styles.typ": *
#import "../utils/layout.typ": *

#let welcome-page(config) = {
  let dark1 = rgb(config.colors.at("dark1", default: "#000000"))
  let accent = rgb(config.colors.at("accent", default: "#3e63dd"))
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
        #v(15%) // Add top padding
        #block(
          width: 60%, // 40% padding (20% on each side)
          inset: 0pt
        )[
          #set align(left)
          #text(font: primary-font, size: 1.8em, weight: primary-weight)[About this planner]
          #v(1.5em)
          
          #set text(size: 10.5pt)
          #set par(leading: 0.85em, justify: false)
          #text(font: secondary-font, weight: secondary-weight)[
            PaperMaker lets you pick the pages you need and customize them, and then it creates a planner like this one for you. You choose the structure, the sections, and the look, and it turns that into a single PDF.
          ]
          
          #v(1.2em)
          #text(font: secondary-font, weight: secondary-weight)[
            Based on what was generated, the pages are connected with links so you can move around by tapping instead of scrolling. This makes it easier to move between days, weeks, months, or any other sections that are present in this file.
          ]
          
          #v(1.2em)
          #text(font: secondary-font, weight: secondary-weight)[
            If you ever want a different setup, you can always generate another version from PaperMaker and keep the one that feels right for you.
          ]
          
          #v(3em)
          
          // Credits section
          #text(font: primary-font, size: 0.9em, weight: primary-weight)[Credits]
          #v(0.8em)
          
          #grid(
            columns: (1fr, 1fr, 1fr, 1fr, 1fr),
            column-gutter: 10pt,
            row-gutter: 5pt,
            [
              #text(size: 8pt, weight: "bold", fill: dark1.transparentize(40%))[Created by] \
              #link("https://hiran.in")[#underline(text(size: 8pt, fill: accent)[Hiran Venugopalan])]
            ],
            [
              #text(size: 8pt, weight: "bold", fill: dark1.transparentize(40%))[License] \
              #link("https://www.gnu.org/licenses/agpl-3.0.en.html")[#underline(text(size: 8pt, fill: accent)[AGPL V3.0])]
            ],
            [
              #text(size: 8pt, weight: "bold", fill: dark1.transparentize(40%))[Build using] \
              #link("https://typst.app")[#underline(text(size: 8pt, fill: accent)[Typst])]
            ],
            [
              #text(size: 8pt, weight: "bold", fill: dark1.transparentize(40%))[Primary font] \
              #link("https://fonts.google.com/specimen/" + config.typography.primaryFont.replace(" ", "+"))[#underline(text(size: 8pt, fill: accent)[#config.typography.primaryFont])]
            ],
            [
              #text(size: 8pt, weight: "bold", fill: dark1.transparentize(40%))[Secondary font] \
              #link("https://fonts.google.com/specimen/" + config.typography.secondaryFont.replace(" ", "+"))[#underline(text(size: 8pt, fill: accent)[#config.typography.secondaryFont])]
            ]
          )
        ]
      ]
    ) <welcome>
  ]
}
