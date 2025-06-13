#import "/src/3rd_party/mathyml/lib.typ": *

#let main(
  title: "Untitled",
  desc: [This is a blog post.],
  date: "2025-06-08",
  tags: (),
  show-outline: true,
  body,
  author: "Xiaotian Han",
) = {

  show: it => {
    

    // Generate metadata for Astro content collections
    [
      #metadata((
        title: title,
        author: author,
        description: desc,
        date: date,
        tags: tags,
      )) <frontmatter>
    ]

    // set basic document metadata
    set document(
      author: author,
      title: title,
    )



    // math rules
    show math.equation: set text(weight: 500)
    // show math.equation: to-mathml
    show math.equation: try-to-mathml
    
    show image: it => {
      // inline
      html.frame(it)
      // or outline
      html.elem("center",
        html.elem("img", attrs: (src: it.source))
      )
    }

    set heading(numbering: "1.")
    show outline.entry: it => link(
      it.element.location(),
      // Keep just the body, dropping
      // the fill and the page.
      it.indented(it.prefix(), it.body()),
    )

    

    // Footnotes
    show: it => {
      show footnote: it => context {
        let num = counter(footnote).get().at(0)
        link(label("footnote-" + str(num)), super(str(num)))
      }
      it
    }

    // Main body.
    // outline(title:"", indent: auto)
    set par(justify: true)
    it

  }


  body
  

  context{
    query(footnote)
      .enumerate()
      .map(((idx, it)) => {
        enum.item[
          #html.elem(
            "div",
            attrs: ("data-typst-label": "footnote-" + str(idx + 1)),
            it.body,
          )
        ]
      })
      .join()
  }

}