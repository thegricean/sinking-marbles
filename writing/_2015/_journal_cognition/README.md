# Getting wonkiness out the door -- open issues.

## To Be Done

### Choices for data analysis

The open issues are (MH, where we have preferences, can you add the rationale for those preferences?):

#### Which prior should we use?

Options:

- binomial 
	- inferred on original
	- inferred on 4step
- smoothed histograms
	- original
	- 4step
	
Current preference:	**binomial (inferred on original)**

#### What backoff prior should we use? 

Options:

- uniform
- binomial (.5)

Current preference: **binomial (.5)**

#### What linking function should we use?

Options:

- none + noise	
- expectation + logit noise (comp_state)
- expectation + other type of noise (comp_state)
- none
- mean of a few samples

Current preference: **first three**, explore noise further

#### Model comparison	


### Qualitative data patterns we would expect to see in posterior predictives (given empirical data)

- attenuated effect of prior on both comp_state and all_prob

- "all"/"none" at floor and ceiling in comp_state, but in all_prob data "all" only makes it to .8

- asymmetric U in wonkiness probs

- linear increase/decrease in wonkiness for "none"/"all" (and maybe "all" doesn't get quite as close to floor as "none")

Reminder: we got all of this (except "all" all_prob result) using an expectation + logit noise linking function for comp_state data, conditioning only on that data and then using inferred parameters to predict all_prob data. The problem: the comp_state prediction was no longer borne out for regular RSA. This is presumably due to a) weird noise process and b) weird priors. Because of this, we switched to doing BDA on priors as well (using binomial priors instead of smoothed histograms), and importantly, there needs to be more exploration of different noise processes.

### Other

- expand first and third section of general discussion, update second one (accommodation)

- update the rest of the manuscript in response to data analysis results


# Deprecated

## The big thing: the asymmetric wonkiness U

### MH's perspective

MH thinks the asymmetry is not real. Reason: doing Bayesian data analysis consistently does *not* return an asymmetric U (at least not in the right direction, ie sometimes wonkiness is lower at the lower extreme of the range than at the upper, but it never comes out the way it is in the data). Potential reasons for this:

- There just isn't an asymmetry.

- There *is* an asymmetry but the model can't detect it because we're oversampling the upper and undersampling the lower range of priors (and in the lower range the priors tend to be flatter). Judith doesn't fully understand the implications of this despite MH explaining it multiple times, but we at least agreed that it's worth trying the whole BDA again with the peaky (rather than the four-step, flatter) priors.

### Judith's perspecitve

The asymmetric U comes out in the most basic model that contains no linking functions or additional parameters. It makes intuitive (and formal) sense, which you can see by computing the speaker utterance distribution for each world state,  then re-weight by prior, then marginalize over states and re-normalize to get the global probability for a particular utterance FOR THAT ITEM):  

![](/writing/_2015/_journal_cognition/pics/latex-formula1.png "")

...assuming that T is the set of world states t0, t1, t2, t3, t4 (ie 4 instead of 15 total marbles, for simplification, but it holds for the larger state space as well) and U is the set of utterances "none", "some", "all". Consider a super left-peaked and a super right-peaked prior:

![](/writing/_2015/_journal_cognition/pics/hypothetical-priors.png "")

Plugging into the equation above the priors and speaker probabilities  (obtained using basic RSA, implicitly assuming a lambda of 1), we get the following overall utterance probabilities P(u):

![](/writing/_2015/_journal_cognition/pics/utterance-probabilities.png "")


"some" is a more surprising utterance overall for the left-peaked items (because you only  ever expect to hear "none") than for the right-peaked items (where both "some" and "all" are semantically compatible options with the all-state). A different way of thinking about it: for the right-peaked items, whether you say "some" or "all" in the all-state doesn't matter because the prior will overwhelm interpretation anyway, so "some" is overall not too unexpected. But for the left-peaked items, whether you say "some" or "all" in the all-state really matters, because now you need pragmatic reasoning to figure out what state you're in (ie the prior won't help you distinguish the all-state from a given some-but-not-all state), so "some" is much less expected in this state, which pushes down the overall probability with which it's expected. I think this is what gives rise to the asymmetry in the extreme ends of the range of prior expected values.

...that said, I wouldn't be the least bit surprised if I did something wrong here.

- **MH**: I get a little lost with this "different way of thinking about it" explanation, mostly because of this comparison *within the all-state* since the two priors differ with respect to how likely the all-state is. The explanation would seem to also apply to a right-peaked prior vs. a uniform prior (since for the uniform prior you "need pragmatic reasoning to figure out what state you're in"). Is that correct?


## Adding a null utterance

At the MXPrag workshop, Michael asked what the effect is of adding a null utterance -- ie, why not get wonkiness via the intuition that you could have just said nothing (or something like our fillers) to retrieve the prior? I remember I had done this at some point, but we discarded it as a possibility because it didn't do what we wanted. I recently checked again what the effect of a (cheap) null utterance is: it weakens implicatures, ie it does exactly the opposite of what wonkiness does. Why Because a null utterance also makes "all" and "none" less likely for the items that are peaked on 0 and 15/all -- in the all-state, this has the effect of decreasing the ratio of the probability of "all" vs "some", so overall, "some" becomes more likely and thus implicatures are weaker.




