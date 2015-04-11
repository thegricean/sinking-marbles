#!/bin/bash

DIR="/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/21_sinking-marbles-prior-sliders/"

cd $MTURK_CMD_HOME/bin

./approveWork.sh -successfile ${DIR}/sinking_marbles.success
