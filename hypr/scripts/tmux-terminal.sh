#!/usr/bin/env bash
# Super+Enter: Ghostty com tmux. Reaproveita a sessão "main" se estiver livre;
# se ela já estiver aberta em outra janela, cria uma sessão nova.
if ! tmux has-session -t main 2>/dev/null; then
    exec ghostty -e tmux new-session -s main
elif [ "$(tmux display-message -p -t main '#{session_attached}')" = "0" ]; then
    exec ghostty -e tmux attach-session -t main
else
    exec ghostty -e tmux new-session
fi
