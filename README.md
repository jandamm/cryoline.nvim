# Cryoline

CReate Your Own statusline - The statusline plugin for everyone who doesn't
need a plugin to write their statusline but wants a declarative approach.

Cryoline does not contain any predefined components. You have to write your own
statusline string.

## Why?

Writing a statusline for vim is as easy as

```lua
vim.o.statusline = '%f%=:)%=%y'
```

Now you're seeing `filenname :) [filetype]`.

But then you want some highlighting:

```lua
vim.o.statusline = '%#WarningMsg#%f%*%=:)%=%y'
```

Now the filename is highlighted as a warning message. But this highlighting
applies to inactive windows as well - which is probably not what you want.

So what now? You need to write a function where you check if the current window
is active.

Then you also want to have your own statusline for the quickfix list? You need
to set the statusline in every quickfix list and also need to modify your line
since `%q` shows the title instead of `%f`.

You quickly end up writing many if statements and custom code.

## How?

When you use Cryoline:

```lua
require("cryoline").config {
  force_ft = { "qf", "help" },
  ft = {
    qf = "%q%=:)",
    lua = function(context)
      return (context.active and "%#Error#" or "") .. "%f%=lua is nice!"
    end
  },
  line = function(context)
    local line = "%f%*%=:)%=%y"
    if context.active then
      line = "%#WarningMsg#" .. line
    end
    return line
  end
}
```

The `context` has `{ active, bufnr, ft, winid }` which should be sufficient to
get all the information needed.

`force_ft` (table) will overwrite the default statusline with the one you're providing.
In the example above `qf` will use its own line while help will get the default
line.

`ft` (table) defines filetype specific statuslines with either a `string` for a `function`.

`line` (string|function) the statusline used when there is no filetype specific
line defined.

Every statusline can either be a `string` or a `function` which takes a
`context` and returns a `string`.

You can also provide `resolve_ft` (function) which allows you to use a
different filetype instead. This filetype doesn't need to exist. It can also be
any `string` which is present in `ft`. Afterwards `resolved_ft` is added to the
context.

```lua
require("cryoline").config {
  resolve_ft = function(context)
    local ft = context.ft
    if
      ft == "fugitive"
      or ft == "gitcommit"
      or string.match(vim.api.nvim_buf_get_name(context.bufnr), "^fugitive://")
    then
      return 'git'
    end
  end,
  ft = {
    git = fuction(context) return "git: %f%=:)" end,
  },
  line = "%f%=:)%=%y"
}
```

This example would use the git line for `git`, `fugitive`, `gitcommit` and
every buffer whose name starts with `fugitive://`.

**Note**: In the context given to the `git` statusline the original filetype is
given. `resolve_ft` is only to determine which line is used.

## Help?

`:h 'statusline'` is your friend :)
