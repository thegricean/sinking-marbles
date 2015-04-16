#!/bin/bash

DIR="/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/22_sinking-marbles-prior-sliders-subset-negation/"

cd $MTURK_CMD_HOME/bin

./approveWork.sh -successfile ${DIR}/sinking_marbles.success
