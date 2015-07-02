var fs = require('fs');
// var csvtojson = require('csvtojson');
var babyparse = require('babyparse');


var erpWriter = function(erp, filename) {
 var supp = erp.support([]);
 var csvFile = fs.openSync(filename, 'w');
 fs.writeSync(csvFile,'Parameter,Item,Quantifier,Value,Probability\n')
 supp.forEach(function(s) {supportWriter(s, Math.exp(erp.score([], s)), csvFile);})
 fs.closeSync(csvFile);
}

var supportWriter = function(s, p, handle) {
 var l = s.length;
 for (var i = 0; i < l-1; i++) {
   fs.writeSync(handle, s[i].join(',')+','+p+'\n');
 }
 var e = s[l-1];
 var k = e.length;
 for (i = 0; i < k; i++) {
   fs.writeSync(handle, e[i].join(',')+','+p+'\n');
 }
}

function readCSV(filename){
  return babyparse.parse(fs.readFileSync(filename, 'utf8'));
};

function writeCSV(jsonCSV, filename){
  fs.writeFileSync(filename, babyparse.unparse(jsonCSV) + "\n");
};

function wpParseFloat(x){
  return parseFloat(x);
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
  // var dfilepath = "./";

  var priorfile = dfilepath+ 'priors.csv'
  var dPriors = readCSV(priorfile).data
  // create assoc. array out of domain name and probabilities
  var priorClean = _.object(_.map(dPriors.slice(1),function(x){
    return [x[0],_.map(x.slice(1),parseFloat)]
  }))

  return priorClean
}

function readData(){

  // var dfilepath = "../writing/_2015/_journal_cognition/data/";
  // var dfilepath = "./";
  var dfilepath = 'data/';
  var priorfile = dfilepath+ 'empirical_binarywonky_nozero.csv'
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


// var erpWriter = function(myERP, names, filename){
//   var supp = myERP.support();

// }

// var supportWriter = function()

// var writePosteriorPredictiveWithParams = function(myERP,paramNames,filename){
//   var s = myERP.support()
//   s.forEach(function(si){

//           return _.flatten([_.map(_.zip(paramNames,si.slice(0,si.length-1)),
//                       function(p){return [p[0], 'na', 'na', p[1], Math.exp(myERP.score([],si))]}),
//                       _.map(si[si.length-1],
//                          function(ppval){
//                                return _.flatten([ppval, Math.exp(myERP.score([],si))])
//                               })
//           ], true)
//   }
//     })


//   return _.flatten(
//         _.map(myERP.support(),
//         function(val){
//           return _.flatten([_.map(_.zip(paramNames,val.slice(0,val.length-1)),
//                       function(p){return [p[0], 'na', 'na', p[1], Math.exp(myERP.score([],val))]}),
//                       _.map(val[val.length-1],
//                          function(ppval){
//                                return _.flatten([ppval, Math.exp(myERP.score([],val))])
//                               })
//           ], true)
//   }),true)
// }


var softmax = function(prob, softmaxparam){
  var dist = [prob, 1-prob]
  var exponentiated = _.map(dist, 
                        function(p){return Math.pow(p,softmaxparam)})
  var sum = _.reduce(exponentiated, function(memo, num){return memo + num;}, 0);
  var renormalized = _.map(exponentiated, function(x){return x/sum})
  return renormalized[0]
}

var logit = function(x) {
  return Math.log(x/(1-x))
}

var logistic=function(x, offset, scale) {
    return 1/(1+Math.exp(-scale*(x-offset)))
}

var logitLogistic = function(p, offset,scale){
    var x = logit(p)
    return 1/(1+Math.exp(-scale*(x-offset)))  
}

var roundToBin = function(x, bins){
    return bins[Math.round(x*10)]
}




module.exports = {
  readCSV: readCSV,
  writeCSV: writeCSV,
  fillArray: fillArray,
  readPriors: readPriors,
  readData: readData,
  writeERP: writeERP,
  writePosteriorPredictive:writePosteriorPredictive,
  // writePosteriorPredictiveWithParams:writePosteriorPredictiveWithParams,
  erpWriter:erpWriter,
  softmax:softmax,
  logit:logit,
  logistic:logistic,
  logitLogistic:logitLogistic,
  wpParseFloat: wpParseFloat,
  roundToBin:roundToBin
};