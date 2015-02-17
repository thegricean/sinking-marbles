
// load in church by (load '/path/to/binomial-score.js)
// call in church by (binomialScore (list p n) observation)
// e.g. (binomialScore (list 0.5 15) 7)

function lnfact(x) {
  if (x < 1) x = 1;
  if (x < 12) return Math.log(fact(Math.round(x)));
  var invx = 1 / x;
  var invx2 = invx * invx;
  var invx3 = invx2 * invx;
  var invx5 = invx3 * invx2;
  var invx7 = invx5 * invx2;
  var sum = ((x + 0.5) * Math.log(x)) - x;
  sum += Math.log(2*Math.PI) / 2;
  sum += (invx / 12) - (invx3 / 360);
  sum += (invx5 / 1260) - (invx7 / 1680);
  return sum;
}

function binomialScore(params, val){
  var p = params[0]; // coin weight
  var n = params[1]; // number of coin tosses
  // val = observed heads
  if (n > 20 && n*p > 5 && n*(1-p) > 5) {
    // large n, reasonable p approximation
    var s = val;
    var inv2 = 1/2;
    var inv3 = 1/3;
    var inv6 = 1/6;
    if (s >= n) return -Infinity;
    var q = 1-p;
    var S = s + inv2;
    var T = n - s - inv2;
    var d1 = s + inv6 - (n + inv3) * p;
    var d2 = q/(s+inv2) - p/(T+inv2) + (q-inv2)/(n+1);
    d2 = d1 + 0.02*d2;
    var num = 1 + q * binomialG(S/(n*p)) + p * binomialG(T/(n*q));
    var den = (n + inv6) * p * q;
    var z = num / den;
    var invsd = Math.sqrt(z);
    z = d2 * invsd;
    return gaussianScore([0, 1], z) + Math.log(invsd);
  } else {
    // exact formula
    return lnfact(n) - lnfact(n-val) - lnfact(val) 
        + val * Math.log(p) + (n-val) * Math.log(1 - p);
  }
}

function fact(x){
  var t=1;
  while(x>1) t*=x--;
  return t;
}