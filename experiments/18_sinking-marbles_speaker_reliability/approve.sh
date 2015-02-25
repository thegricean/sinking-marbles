#!/bin/bash

DIR="/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/18_sinking-marbles_speaker_reliability"

cd $MTURK_CMD_HOME/bin

./approveWork.sh -successfile ${DIR}/sinking_marbles.success
