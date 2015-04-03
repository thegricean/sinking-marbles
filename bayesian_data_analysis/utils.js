var fs = require('fs');
// var csvtojson = require('csvtojson');
var babyparse = require('babyparse');

function readCSV(filename){
  return babyparse.parse(fs.readFileSync(filename, 'utf8'));
};

function writeCSV(jsonCSV, filename){
  fs.writeFileSync(filename, babyparse.unparse(jsonCSV) + "\n");
}

function sequence(lowEnd,highEnd, interval){
	var list = [];
	for (var i = 0; i <= ((highEnd-lowEnd)/interval); i++) {
	    list.push(lowEnd+i*interval);
	}
	return list
}


// mathematical transformations for distributions (arrays)

var logit = function(x) {
	return Math.log(x/(1-x))
}

var logistic=function(x, offset, scale) {
    return 1/(1+Math.exp(-scale*(x-offset)))
}


function raiseToPower(dist, power){
	return _.map(dist,function(x){return Math.pow(x,power)})
}

function logitDistribution(dist){
	return _.map(dist, logit)
}

function logisticDistribution(dist, offset, scale){
	return _.map(dist, function(x){return logistic(x, offset, scale)})
}


module.exports = {
  readCSV: readCSV,
  writeCSV: writeCSV,
  sequence: sequence,
  raiseToPower: raiseToPower,
  logitDistribution: logitDistribution,
  logisticDistribution: logisticDistribution
};