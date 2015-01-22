#!/usr/bin/env sh
pushd /Users/titlis/aws-mturk-clt-1.3.1/bin
./loadHITs.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 -label /Users/titlis/webprojects/69_sinking-marbles-explanation//sinking_marbles_explanation -input /Users/titlis/webprojects/69_sinking-marbles-explanation//sinking_marbles_explanation.input -question /Users/titlis/webprojects/69_sinking-marbles-explanation//sinking_marbles_explanation.question -properties /Users/titlis/webprojects/69_sinking-marbles-explanation//sinking_marbles_explanation.properties -maxhits 1
popd