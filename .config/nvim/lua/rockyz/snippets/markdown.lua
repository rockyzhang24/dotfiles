local snippets = {

  -- Color text using <span>
  -- <span style="color:red">this is blue text</span>.
  s(
    "colortext",
    fmt([[
    <span style="color:{}">{}</span>{}
    ]],
    {
      i(1, "red"),
      i(2, "text here"),
      i(0),
    })
  ),

  -- Color entire paragraph using <p>
  -- <p style="color:red">This is a paragraph.</p>
  s(
    "colorpara",
    fmt([[
    <p style="color:{}">{}</p>
    {}
    ]],
    {
      i(1, "red"),
      i(2, "paragraph here"),
      i(0),
    })
  ),

  -- Aligned image using HTML tag
  -- <img src="URL" width="800">
  s(
    "centerimg",
    fmt([[
    <p align = "center">
    <img src="{}" width="{}">
    </p>
    {}
    ]],
    {
      i(1, "URL"),
      i(2, "800"),
      i(0),
    })
  ),

  -- Markdown link
  -- [text](URL)
  s(
    "link",
    fmt([[
    [{}]({}){}
    ]],
    {
      i(1, "text"),
      i(2, "URL"),
      i(0),
    })
  ),

  -- Markdown image
  -- ![alt](URL)
  s(
    "img",
    fmt([[
    ![{}]({}){}
    ]],
    {
      i(1, "alt"),
      i(2, "URL"),
      i(0),
    })
  ),

  -- Center paragraph
  s(
    "centerpara",
    fmt([[
    <p align="center">
    {}
    </p>
    {}
    ]],
    {
      i(1, "Content goes here"),
      i(0),
    })
  ),

  -- Collapsible details
  s(
    "detail",
    fmt([[
    <details>
    <summary><font size="{}" color="{}">{}</font></summary>

    {}

    </details>
    {}
    ]],
    {
      i(1, "2"),
      i(2, "red"),
      i(3, "Click to show the content."),
      i(4, "Content goes here"),
      i(0),
    })
  ),

  -- Chinese quotation marks
  s(
    "quote",
    fmt([[
    「{}」{}
    ]],
    {
      i(1),
      i(0),
    })
  ),

}

return snippets
