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

### Shared parameters (across models): Rationality, P(wonky), phi

| All prob link | Wonkiness link | model run  |  Posterior on parameters | Posterior  predictive |
|---------|--------------------|-----------------|---------------------|
|    no link |       no link       |  |             |  |
|    scale, offset   |     no link    |       |               |  |
|    scale, offset, sigma   |     no link     |   hashmh 50000  |      wprior:0.3, spopt: 4.5, phi= 0.1m, allprob_links: offset = 0.6, scale = 1.1, sigma = 1.8  | allprob: good; max val=0.25; comp_state = good; wonkiness: range=(0.1,0.9), some: asymmetric (other way) U  |
|    scale, offset, (sigma)   |         scale  |   hashmh 50000 (didn't mix?)  |    wprior:0.99, spopt = 0.8, phi = 0.05, allprob_links: offse = 0.6, scale = 0.7-1.1, sigma = 1.6; wonkiness_links: scale = ~0           |  allprob: nope (max val = 0.05); comp_state: nope (totally flat); wonkiness: nope (super compressed)|
|    scale, offset, sigma  |   scale, offset  |    hashmh 50000      |     wprior=0.8, spopt=2.25, phi = 0.1, allprob_links: offset = 0.55, scale = 1.2, sigma = 1.8; wonkiness_links: offset = 3, scale = 0.7  |    allprob: good (max val = 0.2); comp_state: shape (range is compressed between 7 - 8); wonkiness: range=(0.1,0.9) some U more or less symmetric, decent  |
|    scale, offset  |   scale, offset  |    hashmh 50000      |    wprior = 0.8, spopt=1, phi = 0.35, allprob_links: offset = 0.5 (wide distribution), scale = 1 (wide distribution); wonkiness_links: offset = 2.25, scale = 2   |   allprob: nope (flat); comp_state: compressed between 7-8; wonkiness: range(0.2,0.8); slight asymmetric U but doesn't go above 0.5   |
|    scale, offset, sigma  |   scale, offset (sigma?) |       |       |      |




Aspects of the empirical data (shown below) that we want to capture:

- comp_allprob: small effect of prior, low max value

- comp_state: small effect of prior, values between 4 and 10

- wonkiness: 

	- all: linear decrease in wonkiness with increase in prior expected value
	
	- none: linear increase in wonkiness with increase in prior expected value	
	
	- some: asymmetric U-shaped wonkiness -- high wonkiness for low-prior items (.8), high-ish wonkiness for high-prior items (.5), low wonkiness in medium range (.3). Exact quantitative fit is less important here than getting the asymmetric U shape and the linear increase/decrease for the exact quantifiers

Further desiderata:

1. one speaker optimality parameter

2. one wonkiness prior

3. if necessary, assume different linking functions for different tasks; basically, try to save 1. and 2. for theoretical reasons

![Empirical data for three different tasks](/bayesian_model_comparison/results/graphs/empirical_curves.png "Empirical means for each task")

**List of selected items:**

stuck to the wall baseballs

fell down shelves

landed flat pancakes

melted ice cubes

![Empirical data for three different tasks for selected items](/bayesian_model_comparison/results/graphs/empirical_curves_selected.png "Empirical means for each task (selected items)")
