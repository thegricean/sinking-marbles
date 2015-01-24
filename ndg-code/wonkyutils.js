

function makeDelta(x,grid){
  var ind = grid.indexOf(x) //todo: round to grid?
  
  var d = []
  for(var i=0; i<grid.length; i++){
    d.push(i==ind?1:0)
  }
  return d
}

function makeGrid(n){
  var g=[]
  for(var i=0;i<=n;i++){
    g.push(i/n)
  }
  //push endpoints off boundary, st beta is defined:
  g[0] += 0.001
  g[n] -= 0.001
  
  return g
}

//numeric first derivs:
//todo:use tophat method? scale by grid.
function dif(ar) {
  var dar = []
  for(var i=0;i<ar.length-1;i++){
    dar.push(ar[i+1]-ar[i])
  }
  return dar
}

function argmax(ar) {
  var m = -Infinity
  var a
  for(var v in ar){
    if(ar[v]>m){m = ar[v]; a = v}
  }
  return a
}


module.exports = {
  makeDelta : makeDelta,
  makeGrid : makeGrid,
dif:dif,
argmax:argmax
};