if [ -n "$TMUX" ] || [ $TERM = 'dumb' ] || [ "$GTK_IM_MODULE" = "cros" ]; then return; fi

TMX='tmux'
command -v tmx2 > /dev/null && TMX='tmx2'

# Remote connection
SESSIONNAME=`cat /etc/hostname | cut -f1 -d"."`

if [ -n "$SSH_CONNECTION" ]; then
  $TMX new-session -AD -s $SESSIONNAME
  exit
fi

# Local connection
if $($TMX has-session); then
  SESSION=$($TMX list-sessions | grep -v attached | head -1 | cut -f1 -d:)
  # Attach to first unattached session
  if [ -n "$SESSION" ]; then
    exec $TMX attach -t $SESSION
  fi
fi
exec $TMX new
