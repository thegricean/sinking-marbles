#!/usr/bin/env sh
pushd /Users/titlis/aws-mturk-clt-1.3.1/bin
./loadHITs.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 -label /Users/titlis/webprojects/73_sinking-marbles-normal//sinking_marbles -input /Users/titlis/webprojects/73_sinking-marbles-normal//sinking_marbles.input -question /Users/titlis/webprojects/73_sinking-marbles-normal//sinking_marbles.question -properties /Users/titlis/webprojects/73_sinking-marbles-normal//sinking_marbles.properties -maxhits 1
popd