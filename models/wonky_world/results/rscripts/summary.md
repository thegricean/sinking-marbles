Steps
=====

1. Get the correct smoothed prior distributions 
-----------------------------------------------
	
	for 15 marbles

	for 100 marbles
	
	Are there any substantial differences? Which one to use?
	
2. Run models (requires first figuring out exact empirical prior to use, unless you make up a few test cases)
-----------------------------------------------
	
	1. wonkyworld? --> uniform prior
	
	2. wonkyworld? --> dirichlet prior
	
	3. "empirical" dirichlet prior without wonkyworld? (--> instead of exact empirical prior, add noise with concentration parameter such that with decreasing concentration parameter, there's more noise)
	
	
3. Pros/cons of each of the model types before having run anything	
-----------------------------------------------------------------
	
	- there's a nice simplicity to the idea that we back off to having maximally uncertain beliefs, but is that plausible, if we assume that people are still generally trying to be informative about the world? ie doesn't the utterance itself tell us sth about what we think the speaker's prior beliefs are like? also, the wonky world parameter has a nice interpretation/clear mapping onto data.
	- this nicely captures the aspect that even if the world is wonky, we still want people to say informative things, so it'll infer non-uniform priors that make the actual utterance informative wrt it; also has a nicely interpretable wonky world parameter.
	- this gets rid of the wonky world parameter and directly assumes that people will be using the empirical prior with some noise added to it -- the noise increases (ie the inferred prior differs from the empirical prior) as the utterance becomes more surprising --> tradeoff between truthfulness and informativity; will require computing some measure of distance between the inferred and the actual prior to map to the empirical wonkyworld plot
	 
