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

function raiseToPower(dist, pow){
	return _.map(dist,function(x){return Math.pow(x,pow)})
}

module.exports = {
  readCSV: readCSV,
  writeCSV: writeCSV,
  sequence: sequence,
  raiseToPower: raiseToPower
};