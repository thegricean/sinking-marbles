var fs = require('fs');
// var csvtojson = require('csvtojson');
var babyparse = require('babyparse');

function readCSV(filename){
  return babyparse.parse(fs.readFileSync(filename, 'utf8'));
};

function writeCSV(jsonCSV, filename){
  fs.writeFileSync(filename, babyparse.unparse(jsonCSV) + "\n");
};


function fillArray(value, len) {
  var arr = [];
  for (var i = 0; i < len; i++) {
    arr.push(value);
  }
  return arr;
};

function readPriors(){

  var dfilepath = "../writing/_2015/_journal_cognition/data/";
  var priorfile = dfilepath+ 'priors.csv'
  var dPriors = readCSV(priorfile).data
  // create assoc. array out of domain name and probabilities
  var priorClean = _.object(_.map(dPriors.slice(1),function(x){
    return [x[0],_.map(x.slice(1),parseFloat)]
  }))

  return priorClean
}

function readData(){

  var dfilepath = "../writing/_2015/_journal_cognition/data/";
  var priorfile = dfilepath+ 'empirical_nozero.csv'
  var empirical = readCSV(priorfile).data

  var dependentMeasures = _.uniq(_.map(empirical.slice(1), function(x){return x[4]}))
  var itemNames = _.uniq(_.map(empirical.slice(1), function(x){return x[1]}))

  var quantifiers = ["Some","None","All"]

  var empiricalClean = _.object(_.map(itemNames,
                            function(i){return [i, 
                              _.object(_.map(quantifiers,
                                function(q){return [q,
                                _.object(_.map(dependentMeasures,
                                  function(dm){return [dm,
                                  _.map(_.filter(empirical, function(x){return (x[1]==i & x[2]==q & x[4]==dm)}),
                                    function(y){return parseFloat(y[3])}
                                    )
                                  ]
                                }
                                )
                                )
                                ]
                              }
                              )
                              )
                              ]
                            }
                            )
  )

   return empiricalClean

};

var writeERP = function(myERP){
  return _.map(myERP.support(),
    function(val){
      return [val, Math.exp(myERP.score([],val))]
    })
}

// var writePosteriorPredictive = function(myERP){
//   var supp = myERP.support();
//   return _.flatten(supp.map(
//     function(val){
//         return val.map(
//           function(ppval){
//             return [ppval, Math.exp(myERP.score([],val))]
//           })
//       }),true)
// }

var writePosteriorPredictive = function(myERP){
  return _.flatten(
        _.map(myERP.support(),
      function(val){
          return _.map(val,
        function(ppval){
            return [ppval, Math.exp(myERP.score([],val))]
      })
  }),true)
}



var writePosteriorPredictiveWithParams = function(myERP,numOfParams){
  return _.flatten(
        _.map(myERP.support(),
        function(val){
          return _.map(val,
        function(ppval){
            return [ppval, Math.exp(myERP.score([],val))]
      })
  }),true)
}


var softmax = function(prob, softmaxparam){
  var dist = [prob, 1-prob]
  var exponentiated = _.map(dist, 
                        function(p){return Math.pow(p,softmaxparam)})
  var sum = _.reduce(exponentiated, function(memo, num){return memo + num;}, 0);
  var renormalized = _.map(exponentiated, function(x){return x/sum})
  return renormalized[0]
}



module.exports = {
  readCSV: readCSV,
  writeCSV: writeCSV,
  fillArray: fillArray,
  readPriors: readPriors,
  readData: readData,
  writeERP: writeERP,
  writePosteriorPredictive:writePosteriorPredictive,
  softmax:softmax
};