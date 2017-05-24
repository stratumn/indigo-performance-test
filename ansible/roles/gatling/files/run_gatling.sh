#!/bin/bash
##################################################################################################################
#Gatling scale out/cluster run script:
#Before running this script some assumptions are made:
#1) Public keys were exchange inorder to ssh with no password promot (ssh-copy-id on all remotes)
#2) Check  read/write permissions on all folders declared in this script.
#3) Gatling installation (GATLING_HOME variable) is the same on all hosts
#4) Assuming all hosts has the same user name (if not change in script)
##################################################################################################################

set -o errexit
set -o nounset

cd "${BASH_SOURCE%/*}" || exit

#Assuming same user name for all hosts
REMOTE_USER_NAME='ubuntu'
NETWORK_SIZE=${NETWORK_SIZE:-2}

#Remote hosts list
HOSTS=($(seq -f indigo_tests_%g_on_$NETWORK_SIZE -s " " 0 $(($NETWORK_SIZE-1))))

#Assuming all Gatling installation in same path (with write permissions)
GATLING_HOME=~/gatling
GATLING_REMOTE_RUNNER=$GATLING_HOME/bin/gatling.sh
GATLING_SIMULATION_DIR=$GATLING_HOME/user-files/simulations/
GATLING_RUNNER=$GATLING_HOME/bin/gatling.sh

PRIVATE_KEY=~/.ssh/indigo_tests.pem
SSH_CMD="ssh -q -n -i $PRIVATE_KEY -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
SCP_CMD="scp -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $PRIVATE_KEY"

#Change to your simulation class name
SIMULATION_NAME='indigo.IndigoSimulation'

SIMULATION_WAIT_TIME=1200

#No need to change this
GATLING_REPORT_DIR=$GATLING_HOME/results/
GATHER_REPORTS_DIR=$GATLING_HOME/results/report/
GATLING_SIMULATION_LOG=${GATLING_REPORT_DIR}report/simulation.log

echo "Starting Gatling cluster run for simulation: $SIMULATION_NAME"

echo "Cleaning previous runs from localhost"
rm -rf $GATHER_REPORTS_DIR
rm -rf $GATLING_REPORT_DIR
mkdir --parents $GATHER_REPORTS_DIR

for HOST in "${HOSTS[@]}"
do
  echo "Cleaning previous runs from host: $HOST"
  $SSH_CMD $REMOTE_USER_NAME@$HOST "sh -c 'rm -rf $GATLING_REPORT_DIR'"
done

for HOST in "${HOSTS[@]}"
do
  echo "Copying simulations to host: $HOST"
  $SCP_CMD -r $GATLING_SIMULATION_DIR/* $REMOTE_USER_NAME@$HOST:$GATLING_SIMULATION_DIR
done

for HOST in "${HOSTS[@]}"
do
  echo "Running simulation on host: $HOST"
  $SSH_CMD -f $REMOTE_USER_NAME@$HOST "sh -c 'nohup $GATLING_REMOTE_RUNNER --no-reports --simulation $SIMULATION_NAME > $GATLING_HOME/run.log 2>&1 &'"
done

echo "Waiting for simulations to finish"
$SSH_CMD $REMOTE_USER_NAME@${HOSTS[0]} "sh -c 'inotifywait --timeout $SIMULATION_WAIT_TIME --event create $GATLING_HOME && ls -t $GATLING_REPORT_DIR | head -n 1 | xargs -I {} inotifywait --timeout $SIMULATION_WAIT_TIME --event close $GATLING_REPORT_DIR{}/simulation.log'"

for HOST in "${HOSTS[@]}"
do
  echo "Gathering result file from host: $HOST"
  $SSH_CMD $REMOTE_USER_NAME@$HOST "sh -c 'ls -t $GATLING_REPORT_DIR | head -n 1 | xargs -I {} mv ${GATLING_REPORT_DIR}{} ${GATLING_REPORT_DIR}report'"
  $SCP_CMD $REMOTE_USER_NAME@$HOST:$GATLING_SIMULATION_LOG ${GATHER_REPORTS_DIR}simulation-$HOST.log
done

echo "Aggregating simulations"
$GATLING_RUNNER --reports-only report

#using macOSX
#open ${GATLING_REPORT_DIR}reports/index.html

#using ubuntu
#google-chrome ${GATLING_REPORT_DIR}reports/index.html
