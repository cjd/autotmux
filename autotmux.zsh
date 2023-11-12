takeover() {
  # create a temporary session that displays the "how to go back" message
  tmp='takeover temp session'
  if ! $TMX has-session -t "$tmp"; then
    $TMX new-session -d -s "$tmp"
    $TMX set-option -t "$tmp" remain-on-exit on
    $TMX new-window -kt "$tmp":0 \
      'echo "Use ^A L to return to session.";while (true);do read;done'
  fi
  # switch any clients attached to the target session to the temp session
  for client in $($TMX list-clients -t $SESSIONNAME| cut -f 1 -d :); do
    $TMX switch-client -c "$client" -t "$tmp"
  done
}

# Remote connection
SESSIONNAME=`cat /etc/hostname | cut -f1 -d"."`

if [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ] && [ $TERM != 'dumb' ]; then
  TMX='tmux'
  command -v tmx2 > /dev/null && TMX='tmx2'
  if $($TMX ls | grep -q $SESSIONNAME); then takeover; exec $TMX attach -t $SESSIONNAME; else exec $TMX new -s $SESSIONNAME;fi
fi

# Local connection
if [ -z "$TMUX" ]; then
  if `tmux has-session`; then
    SESSION=`tmux list-sessions | grep -v attached | head -1 | cut -f1 -d:`
    if [ -n "$SESSION" ]; then
      exec tmux attach -t $SESSION
    else exec tmux
    fi
  else exec tmux
  fi
fi
