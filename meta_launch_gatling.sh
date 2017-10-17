#!/bin/sh

dirname=`dirname $0`

ratio=10
duration=2
nodes=4

$dirname/launch_gatling.sh -GK -s $nodes
for ratio in `seq 75 5 90`; do
    $dirname/launch_gatling.sh -AIK -r $ratio -d $duration -s $nodes
    # -l "--delay ${delay}ms"
done
$dirname/launch_gatling.sh -AIG -s $nodes
