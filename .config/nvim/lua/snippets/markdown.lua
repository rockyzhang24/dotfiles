require("plugin_config.luasnip.shorthands").setup_shorthands()

local snippets = {

  -- Color text using <span>
  -- <span style="color:red">this is blue text</span>.
  s("spancol", fmt([[
    <span style="color:{}">{}</span>{}
    ]], {
      i(1, "red"),
      i(2, "text here"),
      i(0),
    })
  ),

  -- Color entire paragraph using <p>
  -- <p style="color:red">This is a paragraph.</p>
  s("pcol", fmt([[
    <p style="color:{}">{}</p>
    {}
    ]], {
      i(1, "red"),
      i(2, "paragraph here"),
      i(0),
    })
  ),

  -- Resize image
  -- <img src="URL" width="800">
  s("imgr", fmt([[
    <img src="{}" width="{}">
    {}
    ]], {
      i(1, "URL"),
      i(2, "800"),
      i(0),
    })
  ),

  -- Center paragraph
  s("pcen", fmt([[
    <p align="center">
    {}
    </p>
    {}
    ]], {
      i(1, "Content goes here"),
      i(0),
    })
  ),

  -- Collapsible content
  s("coll", fmt([[
    <details>
    <summary><font size="{}" color="{}">{}</font></summary>

    {}

    </details>
    {}
    ]], {
      i(1, "2"),
      i(2, "red"),
      i(3, "Click to expand."),
      i(4, "Content goes here"),
      i(0),
    })
  ),

}

return snippets
