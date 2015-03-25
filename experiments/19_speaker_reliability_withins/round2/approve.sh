#!/bin/bash

DIR="/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/19_speaker_reliability_withins/round2/"

cd $MTURK_CMD_HOME/bin

./approveWork.sh -successfile ${DIR}/sinking_marbles.success
