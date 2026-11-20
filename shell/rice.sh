# shell — rice "Mucha" (fzf, zoxide; carregado pelo ~/.bashrc)
# cores do fzf seguem o tema (hypr/scripts/tema.sh grava o modo); vale para terminais novos
if [ "$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/rice/tema" 2>/dev/null)" = escuro ]; then
    _fzf_cores="fg:#E6DAC2,bg:-1,hl:#E0A070,fg+:#E6DAC2,bg+:#34402F,hl+:#E0A070,info:#ADA087,prompt:#CC8550,pointer:#E0A070,marker:#AFC29C,spinner:#B39459,header:#AFC29C,border:#4A4034,gutter:-1,query:#E6DAC2,label:#ADA087"
else
    _fzf_cores="fg:#3A3328,bg:-1,hl:#8A4B26,fg+:#3A3328,bg+:#DCE3D2,hl+:#8A4B26,info:#6E6553,prompt:#B0683A,pointer:#8A4B26,marker:#4F5E45,spinner:#B8955A,header:#4F5E45,border:#D5C7A8,gutter:-1,query:#3A3328,label:#6E6553"
fi
export FZF_DEFAULT_OPTS="--layout=reverse --border=rounded --height=50% --color=$_fzf_cores"
unset _fzf_cores
command -v fzf >/dev/null && eval "$(fzf --bash)"

# zoxide substitui o cd (cd foo pula para o diretório mais usado que casa com "foo"; cdi = interativo com fzf)
command -v zoxide >/dev/null && eval "$(zoxide init bash --cmd cd)"

# mise põe no PATH as versões de node, go, java etc. do projeto atual (ou as globais)
command -v mise >/dev/null && eval "$(mise activate bash)"
