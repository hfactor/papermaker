// Welcome/Guide page component
#import "../utils/dates.typ": *
#import "../utils/styles.typ": *
#import "../utils/layout.typ": *
#import "../utils/config-helpers.typ": get-colors, get-fonts

#let welcome-page(config) = {
  let colors = get-colors(config)
  let fonts = get-fonts(config)
  
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
          #text(font: fonts.primary, size: 1.8em, weight: fonts.primaryWeight)[About this planner]
          #v(1.5em)
          
          #set text(size: 10.5pt)
          #set par(leading: 0.85em, justify: false)
          #text(font: fonts.secondary, weight: fonts.secondaryWeight)[
            PaperMaker lets you pick the pages you need and customize them, and then it creates a planner like this one for you. You choose the structure, the sections, and the look, and it turns that into a single PDF.
          ]
          
          #v(1.2em)
          #text(font: fonts.secondary, weight: fonts.secondaryWeight)[
            Based on what was generated, the pages are connected with links so you can move around by tapping instead of scrolling. This makes it easier to move between days, weeks, months, or any other sections that are present in this file.
          ]
          
          #v(1.2em)
          #text(font: fonts.secondary, weight: fonts.secondaryWeight)[
            If you ever want a different setup, you can always generate another version from PaperMaker and keep the one that feels right for you.
          ]
          
          #v(3em)
          
          // Credits section
          #text(font: fonts.primary, size: 0.9em, weight: fonts.primaryWeight)[Credits]
          #v(0.8em)
          
          #grid(
            columns: (1fr, 1fr, 1fr, 1fr, 1fr),
            column-gutter: 10pt,
            row-gutter: 5pt,
            [
              #text(size: 8pt, weight: "bold", fill: colors.dark1.transparentize(40%))[Created by] \
              #link("https://hiran.in")[#underline(text(size: 8pt, fill: colors.accent)[Hiran Venugopalan])]
            ],
            [
              #text(size: 8pt, weight: "bold", fill: colors.dark1.transparentize(40%))[License] \
              #link("https://www.gnu.org/licenses/agpl-3.0.en.html")[#underline(text(size: 8pt, fill: colors.accent)[AGPL V3.0])]
            ],
            [
              #text(size: 8pt, weight: "bold", fill: colors.dark1.transparentize(40%))[Build using] \
              #link("https://typst.app")[#underline(text(size: 8pt, fill: colors.accent)[Typst])]
            ],
            [
              #text(size: 8pt, weight: "bold", fill: colors.dark1.transparentize(40%))[Primary font] \
              #link("https://fonts.google.com/specimen/" + config.typography.primaryFont.replace(" ", "+"))[#underline(text(size: 8pt, fill: colors.accent)[#config.typography.primaryFont])]
            ],
            [
              #text(size: 8pt, weight: "bold", fill: colors.dark1.transparentize(40%))[Secondary font] \
              #link("https://fonts.google.com/specimen/" + config.typography.secondaryFont.replace(" ", "+"))[#underline(text(size: 8pt, fill: colors.accent)[#config.typography.secondaryFont])]
            ]
          )
        ]
      ]
    ) <welcome>
  ]
}
