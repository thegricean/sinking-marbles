// Give a number task
data { 
  int<lower=1> subjects_nt;
  int<lower=1> subjects_bh;
  int<lower=0> states;
  int<lower=1> items;
  int<lower=0,upper=99> ntdata[items,subjects_nt];
  vector<lower=0,upper=99>[states] bhdata[items,subjects_bh];
  int d_na_nt[items,subjects_nt];  // locating NAs in ntdata
  int n_na_nt;         // number of NAs in ntdata
  int d_na_bh[items,subjects_bh,states];  // locating NAs in bhdata
  int n_na_bh;         // number of NAs in bhdata
  vector<lower=0>[states] alpha1;
}
parameters {
//  matrix<lower=0,upper=1>[items,states] prits;
  simplex[states] prits[items];
}
transformed parameters {
  vector<lower=0>[states] xform_prits[items];

  for (j in 1:items){
    xform_prits[j] <- 16*prits[j];
  }
}

model {
  // Priors
  for (j in 1:items){
    prits[j] ~ dirichlet(alpha1);
  }

  // Model
  for (j in 1:items){
    for (i in 1:subjects_nt){
      if (d_na_nt[j,i] == 0){     // If ntdata[j,i] is NOT missing
        ntdata[j,i] ~ categorical(prits[j]);
      }
    }

    for (i in 1:subjects_bh){
      if (d_na_bh[j,i,1] == 0){ // if bhdata[j,i] is NOT missing
        bhdata[j,i] ~ dirichlet(xform_prits[j]);
      }
    }
}
}