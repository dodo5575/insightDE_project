#!/bin/bash
NUM_SPAWNS=$1
SESSION=$2
tmux new-session -s $SESSION -n bash -d
for ID in `seq 1 $NUM_SPAWNS`;
do
    echo $ID
    tmux new-window -t $ID
    tmux send-keys -t $SESSION:$ID 'python3 kafka_producer_1.py '' '"$ID"'' C-m
done
