#!/usr/bin/env bash

# resize focused window to aspect ratio
# arguments: aspectX aspectY (default 16 9)
# dependencies: bc, jq

x=16
y=9
if [ $# -eq 2 ]; then
  x=$1
  y=$2
fi

node=($(bspc query -T -n | jq -r .client.tiledRectangle.width,.client.tiledRectangle.height,.id))
parent=($(bspc query -T -n @parent | jq -r .splitType,.firstChild.id))

# vertical split: adjust width
if [ "${parent[0]}" = "vertical" ]; then
  width=$(printf "%.0f" $(echo "scale=4;${node[1]}*$x/$y" | bc))
  # left window
  if [ "${node[2]}" = "${parent[1]}" ]; then
    bspc node -z right $((width-node[0])) 0
  # right window
  else
    bspc node -z left $((node[0]-width)) 0
  fi

# horizontal split: adjust height
else
  height=$(printf "%.0f\n" $(echo "scale=4;${node[0]}*$y/$x" | bc))
  # top window
  if [ "${node[2]}" = "${parent[1]}" ]; then
    bspc node -z bottom 0 $((height-node[1]))
  # bottom window
  else
    bspc node -z top 0 $((node[1]-height))
  fi
fi

