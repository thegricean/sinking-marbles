## Wonky RSA model evaluation


### 1 (shared) speaker optimality 

| Attempt | Speaker optimality | Wonkiness prior | Slider link | Wonkiness link | Posterior on parameters | Posterior  predictive |
|---------|--------------------|-----------------|-------------|----------------|-------------------------|-----------------------|
| 1       | 1                  | 1               | 1 beta      | 0              | wprior: .5, beta: 2, spopt: close to 0,                         | allprob: max too high, comp_state: max too high, wonkiness: only the left side of the U is there                      |
| 2       | 1                  | 1               | 1 beta      | softmax        | wprior: .6, beta: 1.6, spopt: close to 0, softmax: 0                         |                       |
| 3       | 1                  | 1               | 2 beta      | 0              |                         |                       |
| 4       | 1                  | 1               | 2 beta      | softmax        |                         |                       |

### 3 (different) speaker optimalities

| Attempt | Speaker optimality | Wonkiness prior | Slider link | Wonkiness link | Posterior on parameters | Posterior  predictive |
|---------|--------------------|-----------------|-------------|----------------|-------------------------|-----------------------|
| 1       | 3                  | 1               | 1 beta      | 0              | wprior: .4, beta: 2, spopt_allprob: 0, spopt_state: around 1.5, spopt_wonky: 1.5                        | allprob: max too high, comp_state: max too high, wonkiness: good except U isn't asymmetric                       |
| 2       | 3                  | 1               | 1 beta      | softmax        | wprior: .6, beta: 1.5, softmax: 0, spopt_allprob: 0, spopt_state: around 1, spopt_wonky: around 1                        | allprob: good (max slightly too high), comp_state: good, (max slightly too high), wonkiness: probabilities too compressed and U basically flat                      |
| 3       | 3                  | 1               | 2 beta      | 0              |                         |                       |
| 4       | 3                  | 1               | 2 beta      | softmax        | wprior: .7, beta_allprob: 3.5, beta_allprob: 1.6, softmax: 0, spopt_allprob: 0, spopt_state: around 1, spopt_wonky: around 1                        | allprob: good, comp_state: good, wonkiness: probabilities too compressed and U basically flat                      |
