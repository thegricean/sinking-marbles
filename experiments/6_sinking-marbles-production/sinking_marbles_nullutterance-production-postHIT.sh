#!/usr/bin/env sh
pushd /Users/titlis/aws-mturk-clt-1.3.1/bin
./loadHITs.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 -label /Users/titlis/webprojects/65_sinking-marbles-production//sinking_marbles_nullutterance-production -input /Users/titlis/webprojects/65_sinking-marbles-production//sinking_marbles_nullutterance-production.input -question /Users/titlis/webprojects/65_sinking-marbles-production//sinking_marbles_nullutterance-production.question -properties /Users/titlis/webprojects/65_sinking-marbles-production//sinking_marbles_nullutterance-production.properties -maxhits 1
popd