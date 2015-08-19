# Getting wonkiness out the door -- open issues.

The current version of the manuscript is ready for feedback in terms of framing. Still missing: the exact numbers. MH's task is to add a detailed description of the BDA / model comparison procedure to an appendix and insert short references to it within the manuscript in appropriate places.

But there are still some open issues:

## The big thing: the asymmetric wonkiness U

### MH's perspective

MH thinks the asymmetry is not real. Reason: doing Bayesian data analysis consistently does *not* return an asymmetric U (at least not in the right direction, ie sometimes wonkiness is lower at the lower extreme of the range than at the upper, but it never comes out the way it is in the data). Potential reasons for this:

- There just isn't an asymmetry.

- There *is* an asymmetry but the model can't detect it because we're oversampling the upper and undersampling the lower range of priors (and in the lower range the priors tend to be flatter). Judith doesn't fully understand the implications of this despite MH explaining it multiple times, but we at least agreed that it's worth trying the whole BDA again with the peaky (rather than the four-step, flatter) priors.

### Judith's perspecitve

The asymmetric U comes out in the most basic model that contains no linking functions or additional parameters. It also makes intuitive sense (and formal sense, which you can see by computing the speaker utterance distribution for each world state,  then re-weight by prior, then marginalize over states and re-normalize to get the global probability for a particular utterance FOR THAT ITEM):  "some" is a more surprising utterance overall for the left-peaked items (in that the only utterance you should ever expect to hear is "none" -- so Quality makes "some" unexpected) than for the right-peaked items (where both "some" and "all" are semantically compatible options with the all-state -- so 'only' Quantity (and extra pragmatics), but not Quality, makes "some" unexpected). A different way of thinking about it: for the right-peaked items, whether you say "some" or "all" in the all-state doesn't matter because the prior will overwhelm interpretation anyway, so "some" is overall not too unexpected. But for the left-peaked items, whether you say "some" or "all" in the all-state really matters, because now you need pragmatic reasoning to figure out what state you're in (ie the prior won't help you distinguish the all-state from a given some-but-not-all state), so "some" is much less expected in this state, which pushes down the overall probability with which it's expected.

--> spell this bit out in more detail and with plots, to walk through with noah and mh when mh is back
![](/writing/_2015/_journal_cognition/pics/latex-formula1.png "")


### ToDo

- Run BDA with peaky priors -- *Judith*, put together datasets for MH -- *MH*, run it


## Adding a null utterance

At the MXPrag workshop, Michael asked what the effect is of adding a null utterance -- ie, why not get wonkiness via the intuition that you could have just said nothing (or something like our fillers) to retrieve the prior? I remember I had done this at some point, but we discarded it as a possibility because it didn't do what we wanted. I recently checked again what the effect of a (cheap) null utterance is: it weakens implicatures, ie it does exactly the opposite of what wonkiness does. Why Because a null utterance also makes "all" and "none" less likely for the items that are peaked on 0 and 15/all -- in the all-state, this has the effect of decreasing the ratio of the probability of "all" vs "some", so overall, "some" becomes more likely and thus implicatures are weaker.

