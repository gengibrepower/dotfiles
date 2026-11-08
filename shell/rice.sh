# shell — rice "Mucha" (fzf, zoxide; carregado pelo ~/.bashrc)
export FZF_DEFAULT_OPTS="--layout=reverse --border=rounded --height=50% \
  --color=fg:#3A3328,bg:-1,hl:#8A4B26,fg+:#3A3328,bg+:#DCE3D2,hl+:#8A4B26 \
  --color=info:#6E6553,prompt:#B0683A,pointer:#8A4B26,marker:#4F5E45,spinner:#B8955A \
  --color=header:#4F5E45,border:#D5C7A8,gutter:-1,query:#3A3328,label:#6E6553"
command -v fzf >/dev/null && eval "$(fzf --bash)"

# zoxide substitui o cd (cd foo pula para o diretório mais usado que casa com "foo"; cdi = interativo com fzf)
command -v zoxide >/dev/null && eval "$(zoxide init bash --cmd cd)"
