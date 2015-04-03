// I/O helpers

var fs = require('fs');
var babyparse = require('babyparse');

function readCSV(filename){
  return babyparse.parse(fs.readFileSync(filename, 'utf8'));
};

function writeCSV(jsonCSV, filename){
  fs.writeFileSync(filename, babyparse.unparse(jsonCSV) + "\n");
}

function readinNumberTask(){
	var ntData = readCSV('fake_numerTaskdata.csv')
//	var ntData = readCSV('inferpriorinsky_number.txt')

	var dataBySubjByItem = _.object(
		_.map(ntData.data.slice(1),
				function(lst){
					return ['s'+lst[0], 
								_.object(_.zip(
									_.map(sequence(1,lst.slice(1).length,1),
										function(n){return 'i'+n})
									,_.map(lst.slice(1), parseFloat))
									)]
				}
		))
	return dataBySubjByItem
}



// general helpers

function sequence(lowEnd,highEnd, interval){
	var list = [];
	for (var i = 0; i <= ((highEnd-lowEnd)/interval); i++) {
	    list.push(lowEnd+i*interval);
	}
	return list
}

var mapObject = function(fn, obj){  
  return _.object(
    _.map(
    	_.pairs(obj),
      function(kv){
        return [kv[0], fn(kv[0], kv[1])]
      })
  );
}
//
// var mapObject = function(fn, obj){
// 	return _.mapObject(obj, fn)
// }

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

function sum(lst){
	return lst.reduce(function(a,b){return a+b})
}

function normalize(dist){
	return _.map(dist, function(x){return x/sum(dist)})
}


module.exports = {
  readinNumberTask: readinNumberTask,
  writeCSV: writeCSV,
  sequence: sequence,
  mapObject: mapObject,
  raiseToPower: raiseToPower,
  logitDistribution: logitDistribution,
  logisticDistribution: logisticDistribution,
  normalize: normalize
};