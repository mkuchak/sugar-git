if [[ -n "${args[--verbose]}" ]]; then
  # Dashboard view: local branches with relative time, ahead/behind upstream,
  # and the subject of HEAD on each branch.
  git for-each-ref --sort=-committerdate refs/heads/ \
    --format='%(if)%(HEAD)%(then)* %(color:green)%(else)  %(color:yellow)%(end)%(refname:short)%(color:reset)|%(committerdate:relative)|%(upstream:track,nobracket)|%(subject)' |
  while IFS='|' read -r marker_name rel track subject; do
    # Normalize the track field: empty for synced or no-upstream, the bracketed
    # text otherwise. for-each-ref's "nobracket" gives "ahead 2, behind 1" or "gone".
    if [[ -z "$track" ]]; then
      # Either no upstream OR fully synced. Distinguish by re-querying.
      branch=$(echo "$marker_name" | awk '{print $NF}')
      upstream=$(git for-each-ref --format='%(upstream:short)' "refs/heads/$branch" 2>/dev/null)
      if [[ -z "$upstream" ]]; then
        status_str="no upstream"
      else
        status_str="synced"
      fi
    else
      status_str="$track"
    fi
    printf "%s  %-18s  %-25s  %s\n" "$marker_name" "$rel" "$status_str" "$subject"
  done
elif [[ -n "${args[--local]}" ]]; then
  git for-each-ref --sort=-committerdate refs/heads/ \
    --format='%(if)%(HEAD)%(then)* %(color:green)%(else)  %(color:yellow)%(end)%(refname:short)%(color:reset) %(color:green)(%(committerdate:relative))%(color:reset) %(subject)'
elif [[ -n "${args[--remote]}" ]]; then
  git for-each-ref --sort=-committerdate refs/remotes/ \
    --format='  %(color:yellow)%(refname:short)%(color:reset) %(color:green)(%(committerdate:relative))%(color:reset) %(subject)'
else
  git for-each-ref --sort=-committerdate refs/heads/ refs/remotes/ \
    --format='%(if)%(HEAD)%(then)* %(color:green)%(else)  %(color:yellow)%(end)%(refname:short)%(color:reset) %(color:green)(%(committerdate:relative))%(color:reset) %(subject)'
fi
