-- Colorscheme "mucha" — rice Art Nouveau, fundo creme transparente (Ghostty).
-- Toda cor de texto tem contraste >= 4.5:1 sobre #F7F1E3 (medido); a
-- distinção vem de matiz + peso, não de tons claros. :colorscheme gruvbox
-- continua disponível para comparar.
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.background = "light"
vim.g.colors_name = "mucha"

local c = {
  bg        = "NONE",      -- deixa o creme translúcido do Ghostty
  creme     = "#F7F1E3",
  papel     = "#FBF7EE",
  pergaminho = "#EFE6D2",
  vinco     = "#E2D7BF",
  borda     = "#D5C7A8",
  salvia_bg = "#DCE3D2",
  cobre_bg  = "#F0DCCB",
  ouro_bg   = "#F1E6C8",

  fg        = "#3A3328",   -- 11.1
  suave     = "#6F6652",   -- 5.0  comentários
  apagado   = "#A39883",   -- só decoração (números de linha, guias)
  keyword   = "#8A4B26",   -- 6.0  cobre escuro
  funcao    = "#3F5A3A",   -- 6.8  sálvia escura
  string    = "#55652A",   -- 5.7  oliva
  tipo      = "#3E5A6A",   -- 6.5  ardósia
  numero    = "#7A3F58",   -- 7.0  ameixa
  operador  = "#5E5546",   -- 6.5
  builtin   = "#7A5A1E",   -- 5.6  ouro velho
  prop      = "#5A4632",   -- 7.9
  erro      = "#A0331F",   -- 6.2
  aviso     = "#7A5A1E",
  info      = "#3E5A6A",
  dica      = "#3F5A3A",
  cobre     = "#B0683A",   -- acentos (bordas, cursor)
  ouro      = "#B8955A",
}

local function hi(g, o) vim.api.nvim_set_hl(0, g, o) end
local function link(g, t) vim.api.nvim_set_hl(0, g, { link = t }) end

-- interface ---------------------------------------------------------------
hi("Normal",        { fg = c.fg, bg = c.bg })
hi("NormalNC",      { fg = c.fg, bg = c.bg })
hi("NormalFloat",   { fg = c.fg, bg = c.pergaminho })
hi("FloatBorder",   { fg = c.cobre, bg = c.pergaminho })
hi("FloatTitle",    { fg = c.keyword, bg = c.pergaminho, bold = true })
hi("SignColumn",    { bg = c.bg })
hi("LineNr",        { fg = c.apagado })
hi("CursorLineNr",  { fg = c.keyword, bold = true })
hi("CursorLine",    { bg = c.pergaminho })
hi("CursorColumn",  { bg = c.pergaminho })
hi("ColorColumn",   { bg = c.pergaminho })
hi("Cursor",        { fg = c.creme, bg = c.cobre })
hi("Visual",        { bg = c.salvia_bg })
hi("VisualNOS",     { bg = c.salvia_bg })
hi("Search",        { fg = c.fg, bg = c.ouro_bg, underline = true, sp = c.ouro })
hi("IncSearch",     { fg = c.creme, bg = c.cobre })
hi("CurSearch",     { fg = c.creme, bg = c.keyword, bold = true })
hi("Substitute",    { fg = c.creme, bg = c.numero })
hi("MatchParen",    { fg = c.keyword, bg = c.cobre_bg, bold = true })
hi("Pmenu",         { fg = c.fg, bg = c.pergaminho })
hi("PmenuSel",      { fg = c.fg, bg = c.salvia_bg, bold = true })
hi("PmenuSbar",     { bg = c.vinco })
hi("PmenuThumb",    { bg = c.ouro })
hi("PmenuKind",     { fg = c.tipo, bg = c.pergaminho })
hi("PmenuExtra",    { fg = c.suave, bg = c.pergaminho })
hi("StatusLine",    { fg = c.fg, bg = c.pergaminho })
hi("StatusLineNC",  { fg = c.suave, bg = c.pergaminho })
hi("TabLine",       { fg = c.suave, bg = c.pergaminho })
hi("TabLineSel",    { fg = c.fg, bg = c.creme, bold = true })
hi("TabLineFill",   { bg = c.pergaminho })
hi("WinSeparator",  { fg = c.borda })
hi("VertSplit",     { fg = c.borda })
hi("Folded",        { fg = c.suave, bg = c.pergaminho, italic = true })
hi("FoldColumn",    { fg = c.apagado })
hi("NonText",       { fg = c.borda })
hi("Whitespace",    { fg = c.borda })
hi("EndOfBuffer",   { fg = c.bg })
hi("SpecialKey",    { fg = c.apagado })
hi("Directory",     { fg = c.funcao, bold = true })
hi("Title",         { fg = c.keyword, bold = true })
hi("Question",      { fg = c.funcao })
hi("MoreMsg",       { fg = c.funcao })
hi("ModeMsg",       { fg = c.fg, bold = true })
hi("ErrorMsg",      { fg = c.erro, bold = true })
hi("WarningMsg",    { fg = c.aviso, bold = true })
hi("WildMenu",      { fg = c.fg, bg = c.salvia_bg })
hi("QuickFixLine",  { bg = c.salvia_bg })
hi("SpellBad",      { undercurl = true, sp = c.erro })
hi("SpellCap",      { undercurl = true, sp = c.aviso })
hi("SpellRare",     { undercurl = true, sp = c.numero })
hi("SpellLocal",    { undercurl = true, sp = c.tipo })
hi("Conceal",       { fg = c.suave })

-- sintaxe ------------------------------------------------------------------
hi("Comment",       { fg = c.suave, italic = true })
hi("Constant",      { fg = c.numero })
hi("String",        { fg = c.string })
hi("Character",     { fg = c.string })
hi("Number",        { fg = c.numero })
hi("Boolean",       { fg = c.numero, bold = true })
hi("Float",         { fg = c.numero })
hi("Identifier",    { fg = c.fg })
hi("Function",      { fg = c.funcao, bold = true })
hi("Statement",     { fg = c.keyword })
hi("Conditional",   { fg = c.keyword })
hi("Repeat",        { fg = c.keyword })
hi("Label",         { fg = c.keyword })
hi("Operator",      { fg = c.operador })
hi("Keyword",       { fg = c.keyword })
hi("Exception",     { fg = c.keyword })
hi("PreProc",       { fg = c.builtin })
hi("Include",       { fg = c.keyword })
hi("Define",        { fg = c.keyword })
hi("Macro",         { fg = c.builtin })
hi("Type",          { fg = c.tipo })
hi("StorageClass",  { fg = c.keyword })
hi("Structure",     { fg = c.tipo })
hi("Typedef",       { fg = c.tipo })
hi("Special",       { fg = c.builtin })
hi("SpecialChar",   { fg = c.builtin })
hi("Tag",           { fg = c.keyword })
hi("Delimiter",     { fg = c.operador })
hi("SpecialComment",{ fg = c.suave, bold = true })
hi("Debug",         { fg = c.erro })
hi("Underlined",    { fg = c.tipo, underline = true })
hi("Error",         { fg = c.erro, bold = true })
hi("Todo",          { fg = c.creme, bg = c.builtin, bold = true })
hi("Added",         { fg = c.funcao })
hi("Changed",       { fg = c.builtin })
hi("Removed",       { fg = c.erro })

-- treesitter ---------------------------------------------------------------
link("@variable", "Identifier")
hi("@variable.builtin",      { fg = c.builtin, italic = true })
hi("@variable.parameter",    { fg = c.prop, italic = true })
hi("@variable.member",       { fg = c.prop })
hi("@property",              { fg = c.prop })
link("@constant", "Constant")
hi("@constant.builtin",      { fg = c.numero, bold = true })
link("@module", "Type")
link("@string", "String")
hi("@string.escape",         { fg = c.builtin, bold = true })
hi("@string.regexp",         { fg = c.builtin })
hi("@string.special.url",    { fg = c.tipo, underline = true })
link("@number", "Number")
link("@boolean", "Boolean")
link("@function", "Function")
hi("@function.builtin",      { fg = c.builtin, bold = true })
hi("@function.call",         { fg = c.funcao })
hi("@function.method.call",  { fg = c.funcao })
link("@constructor", "Type")
link("@keyword", "Keyword")
hi("@keyword.return",        { fg = c.keyword, bold = true })
hi("@keyword.function",      { fg = c.keyword, italic = true })
link("@keyword.import", "Include")
link("@operator", "Operator")
link("@punctuation", "Delimiter")
hi("@punctuation.special",   { fg = c.builtin })
link("@type", "Type")
hi("@type.builtin",          { fg = c.tipo, italic = true })
link("@attribute", "PreProc")
hi("@tag",                   { fg = c.keyword })
hi("@tag.attribute",         { fg = c.prop, italic = true })
hi("@tag.delimiter",         { fg = c.operador })
link("@comment", "Comment")
hi("@comment.todo",          { fg = c.creme, bg = c.builtin, bold = true })
hi("@comment.note",          { fg = c.creme, bg = c.tipo, bold = true })
hi("@comment.warning",       { fg = c.creme, bg = c.keyword, bold = true })
hi("@comment.error",         { fg = c.creme, bg = c.erro, bold = true })
hi("@markup.heading",        { fg = c.keyword, bold = true })
hi("@markup.strong",         { bold = true })
hi("@markup.italic",         { italic = true })
hi("@markup.link",           { fg = c.tipo, underline = true })
hi("@markup.raw",            { fg = c.string })
hi("@markup.list",           { fg = c.cobre })
hi("@markup.quote",          { fg = c.suave, italic = true })

-- LSP semântico: segue o treesitter
link("@lsp.type.parameter", "@variable.parameter")
link("@lsp.type.property", "@property")
link("@lsp.type.interface", "Type")
link("@lsp.type.enumMember", "Constant")
link("@lsp.type.namespace", "@module")
hi("@lsp.mod.readonly",      { })
hi("@lsp.typemod.variable.defaultLibrary", { fg = c.builtin })

-- diagnósticos -------------------------------------------------------------
for nome, cor in pairs({ Error = c.erro, Warn = c.aviso, Info = c.info, Hint = c.dica, Ok = c.funcao }) do
  hi("Diagnostic" .. nome, { fg = cor })
  hi("DiagnosticVirtualText" .. nome, { fg = cor, italic = true })
  hi("DiagnosticUnderline" .. nome, { undercurl = true, sp = cor })
  hi("DiagnosticSign" .. nome, { fg = cor })
end
hi("LspReferenceText",  { bg = c.vinco })
hi("LspReferenceRead",  { bg = c.vinco })
hi("LspReferenceWrite", { bg = c.vinco, underline = true })
hi("LspInlayHint",      { fg = c.apagado, italic = true })
hi("LspSignatureActiveParameter", { fg = c.keyword, bold = true, underline = true })

-- diff / git ---------------------------------------------------------------
hi("DiffAdd",     { bg = c.salvia_bg })
hi("DiffChange",  { bg = c.ouro_bg })
hi("DiffDelete",  { fg = c.erro, bg = c.cobre_bg })
hi("DiffText",    { bg = "#E6D3A6", bold = true })
hi("GitSignsAdd",    { fg = "#6B7D5E" })
hi("GitSignsChange", { fg = c.ouro })
hi("GitSignsDelete", { fg = c.cobre })

-- plugins do LazyVim -------------------------------------------------------
hi("WhichKey",          { fg = c.keyword })
hi("WhichKeyGroup",     { fg = c.tipo })
hi("WhichKeyDesc",      { fg = c.fg })
hi("WhichKeySeparator", { fg = c.apagado })
hi("SnacksPickerMatch", { fg = c.keyword, bold = true })
hi("SnacksPickerDir",   { fg = c.suave })
hi("SnacksIndent",      { fg = c.vinco })
hi("SnacksIndentScope", { fg = c.ouro })
hi("SnacksDashboardHeader", { fg = c.cobre })
hi("SnacksDashboardKey",    { fg = c.keyword, bold = true })
hi("SnacksDashboardDesc",   { fg = c.fg })
hi("SnacksDashboardIcon",   { fg = c.funcao })
hi("SnacksDashboardFooter", { fg = c.suave, italic = true })
hi("BlinkCmpMenu",          { fg = c.fg, bg = c.pergaminho })
hi("BlinkCmpMenuBorder",    { fg = c.cobre, bg = c.pergaminho })
hi("BlinkCmpMenuSelection", { bg = c.salvia_bg, bold = true })
hi("BlinkCmpLabelMatch",    { fg = c.keyword, bold = true })
hi("BlinkCmpKind",          { fg = c.tipo })
hi("BlinkCmpDoc",           { fg = c.fg, bg = c.papel })
hi("BlinkCmpDocBorder",     { fg = c.borda, bg = c.papel })
hi("NeoTreeNormal",         { fg = c.fg, bg = c.bg })
hi("NeoTreeNormalNC",       { fg = c.fg, bg = c.bg })
hi("NeoTreeDirectoryName",  { fg = c.funcao })
hi("NeoTreeDirectoryIcon",  { fg = c.funcao })
hi("NeoTreeRootName",       { fg = c.keyword, bold = true })
hi("NeoTreeGitModified",    { fg = c.builtin })
hi("NeoTreeGitUntracked",   { fg = c.tipo })
hi("FlashLabel",            { fg = c.creme, bg = c.keyword, bold = true })
hi("FlashMatch",            { fg = c.fg, bg = c.ouro_bg })
hi("NoiceCmdlinePopupBorder", { fg = c.cobre })
hi("NoiceCmdlineIcon",      { fg = c.keyword })
hi("TroubleNormal",         { fg = c.fg, bg = c.bg })
hi("MiniIconsAzure",  { fg = c.tipo })
hi("MiniIconsBlue",   { fg = c.tipo })
hi("MiniIconsCyan",   { fg = "#3E6A66" })
hi("MiniIconsGreen",  { fg = c.funcao })
hi("MiniIconsGrey",   { fg = c.suave })
hi("MiniIconsOrange", { fg = c.cobre })
hi("MiniIconsPurple", { fg = c.numero })
hi("MiniIconsRed",    { fg = c.erro })
hi("MiniIconsYellow", { fg = c.builtin })

-- terminal embutido
local term = { "#3A3328", "#A0331F", "#3F5A3A", "#7A5A1E", "#3E5A6A", "#7A3F58", "#3E6A66", "#E2D7BF",
               "#6F6652", "#B0683A", "#55652A", "#8F6A2C", "#4E6470", "#8C5A70", "#4F7A72", "#F7F1E3" }
for i, cor in ipairs(term) do vim.g["terminal_color_" .. (i - 1)] = cor end
