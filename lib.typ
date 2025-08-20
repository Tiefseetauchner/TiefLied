#let authors-state = state("authors", (:))
#let show-annotations-state = state("show-annotations", false)

#let songbook(
  title: none,
  songbook-author: none,
  title-page: false,
  settings: (
    paper: "a4",
    font: "Cormorant Garamond",
    title-font: "Cormorant SC",
    text-size: 14pt,
    show-annotations: false,
  ),
  body,
) = {
  if title-page {
    assert(title != none, message: "Title should really be set.")
    assert(songbook-author != none, message: "Author should be set.")
  }

  if settings.at("paper", default: none) == none {
    settings.paper = "a4"
  }

  if settings.at("font", default: none) == none {
    settings.font = "Cormorant Garamond"
  }

  if settings.at("title-font", default: none) == none {
    settings.title-font = "Cormorant SC"
  }

  if settings.at("text-size", default: none) == none {
    settings.text-size = 14pt
  }

  if settings.at("show-annotations", default: none) == none {
    settings.show-annotations = false
  }

  show-annotations-state.update(settings.show-annotations)

  set page(paper: settings.paper, margin: 2cm)

  set text(font: settings.font, number-type: "lining", size: settings.text-size)

  if title-page {
    context {
      box(width: 70%, [
        #set text(font: "Cormorant SC", size: 36pt)
        *#title*
      ])
    }
    line(length: 80%)
    context {
      set text(size: 24pt)
      songbook-author
    }

    context {
      let authors = authors-state.final()
      if authors.len() != 0 and not (authors.len() == 1 and authors.keys().first() == songbook-author) {
        place(bottom + right)[
          Songs by:\
          #set text(size: 18pt)
          #if authors.len() > 4 {
            [#authors.slice(0, count: 4).join(", ") and more]
          } else {
            authors.keys().join(", ")
          }
        ]
      }
    }

    pagebreak(to: "odd")
  }

  counter(page).update(1)
  set page(footer: [
    #context {
      if calc.rem(counter(page).get().last(), 2) == 0 {
        place(right, counter(page).display("1/1", both: true))
      } else {
        place(left, counter(page).display("1/1", both: true))
      }
    }
  ])

  body
}

#let author(
  name,
  color: none,
) = {
  (
    name: name,
    color: color,
  )
}

#let annotation(annotation-text, body) = {
  context {
    if show-annotations-state.get() {
      set text(size: 11pt)
      place(right, dx: -25pt, [#annotation-text])
    }
  }
  [#body

  ]
}

#let verse(body) = {
  annotation("[Verse]", body)
}

#let bridge(body) = {
  annotation("[Bridge]", body)
}

#let chorus(body) = {
  annotation("[Chorus]", body)
}

#let song(author: none, title: none, body) = {
  if type(author) == type("") {
    author = (
      name: author,
      color: none,
    )
  }

  context authors-state.update(authors => {
    if authors.keys().contains(author) {
      authors.at(author).songs.push(title)
      return authors
    }
    authors.insert(author.name, (songs: (title,)))
    authors
  })

  [
    #context {
      box(
        width: 100%,
        height: 2em,
        [
          #box(height: 100%, width: 100%, fill: color.hsv(0deg, 0%, 90%, 100%), radius: 5pt)

          #place(left + horizon, box(
            width: 80%,
            inset: (left: 20pt, rest: 6pt),
            [= #title],
          ))

          #place(right + horizon, box(
            width: 20%,
            inset: 6pt,
            fill: author.color,
            radius: (right: 5pt),
            height: 100%,
            [
              #set text(size: 10pt, hyphenate: true)
              #author.name
            ],
          ))
        ],
      )
    }

    #body
  ]
}
