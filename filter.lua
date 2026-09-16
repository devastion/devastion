local function inlines_to_latex(inlines)
  local doc = pandoc.Pandoc({ pandoc.Plain(inlines) })
  return (pandoc.write(doc, 'latex'):gsub('%s+$', ''))
end

local function heading(cmd, title, date)
  if date then
    return pandoc.RawBlock(
      'latex',
      string.format(
        '\\%s*{%s \\hfill \\normalfont\\textit{%s}}',
        cmd,
        title,
        date
      )
    )
  end
  return pandoc.RawBlock('latex', string.format('\\%s*{%s}', cmd, title))
end

function Pandoc(doc)
  local blocks = doc.blocks
  local out = pandoc.Blocks({})
  local i = 1
  while i <= #blocks do
    local b = blocks[i]
    if b.t == 'Header' and b.level == 3 then
      local nextb = blocks[i + 1]
      if
        nextb
        and nextb.t == 'Para'
        and #nextb.content == 1
        and nextb.content[1].t == 'Emph'
      then
        local title = inlines_to_latex(b.content)
        local date = inlines_to_latex(nextb.content[1].content)
        out:insert(heading('subsection', title, date))
        i = i + 2
      else
        out:insert(heading('subsection', inlines_to_latex(b.content)))
        i = i + 1
      end
    elseif b.t == 'Header' and b.level == 2 then
      out:insert(heading('section', inlines_to_latex(b.content)))
      i = i + 1
    elseif b.t == 'Para' then
      local left, right, foundBreak = {}, {}, false
      for _, il in ipairs(b.content) do
        if not foundBreak and il.t == 'LineBreak' then
          foundBreak = true
        elseif foundBreak then
          table.insert(right, il)
        else
          table.insert(left, il)
        end
      end
      if foundBreak then
        out:insert(
          pandoc.RawBlock(
            'latex',
            string.format(
              '%s \\hfill %s',
              inlines_to_latex(left),
              inlines_to_latex(right)
            )
          )
        )
      else
        out:insert(b)
      end
      i = i + 1
    else
      out:insert(b)
      i = i + 1
    end
  end
  doc.blocks = out
  return doc
end
