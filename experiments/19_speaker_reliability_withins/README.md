---
title: "within subjects speaker reliability manipulation"
author: "jdegen"
date: "February 24, 2015"
output: html_document
---


```r
load("results/data/r.RData")
library(ggplot2)
library(lme4)
```

### Main results thus far

* Main effect of speaker reliability on "some": **the effect of the prior on the posterior after "some" is greater for unreliable than reliable speakers**. 
* The plots suggest this reliability effect disappears by the third block: **the reliable speaker is perceived as less reliable in the third than in the first block**, i.e. there's a greater effect of the prior in the third block than in the third when the speaker is reliable
* Interesting reliability effects on "all" and "none"


Normalized mean responses by slider (column), quantifier (row), and trial type (color). We replicate the attenuated effect of the prior on "some" in the sober (reliable) speaker condition -- see lower right corner. In the same facet: when speakers are unreliable, listeners rely more on their priors -- as expected!! Though values still don't get quite as high as expected under standard RSA, but I think normalization is screwing us over here. The next plot (and three plots further down) shows the mean **raw** responses (split up by block), and it's very clear that here for the first time we're even close to approaching what RSA predicts. Also: interesting effects in the "all"/"none" conditions.

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2.png) 

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3.png) 

Normalized mean responses on 100%/all slider by block (column), quantifier (row), and trial type (color). Drunk/court are unreliable/uncooperative, sober is reliable. Clear effect of speaker reliability on "some", but values still not super high (normalization issue).

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 

Raw mean responses on 100%/all slider by block (column), quantifier (row), and trial type (color). Drunk/court are unreliable/uncooperative, sober is reliable. Very clear effect of speaker reliability on "some", and for the first time, values approaching 1 in the unreliable case. This has never happened before!


![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 

