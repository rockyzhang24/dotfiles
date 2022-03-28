-- Here are the snippets for ALL filetypes
local snippets = {

  -- date -> Tue 16 Nov 2021 09:43:49 AM EST
  s({ trig = "date" }, {
    f(function()
      return string.format(string.gsub(vim.bo.commentstring, "%%s", " %%s"), os.date())
    end, {}),
  }),

}

return snippets
