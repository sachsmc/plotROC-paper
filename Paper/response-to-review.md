# Summary of changes

Thanks to the reviewers' comments, and some recent changes to ggplot2, the plotROC package has been greatly improved. The interface is now much more user-friendly, requires less typing, and is completely compatible with ggplot2. The computation is more efficient, and the plotting tools are much more flexible. I believe the package is much closer to my goal of providing a better tool for plotting ROC curves. Here are the main changes:

- The calculate_roc, ggroc, and plot_journal_roc functions are deprecated. 
- I have implemented the geom_roc, geom_rocci geometric layers, and stat_roc, stat_rocci statistical transformations. A recent update to ggplot2 now exports the Geom and Stat functions so that developers can create their own and be compatible with the other features of ggplot2. This is what we have done instead of the previous approach of "hacking" the existing ggplot2 geoms. The usage is now simplified to:

```r
p1 <- ggplot(data, aes(m = M, d = D)) + geom_roc() + geom_rocci() 
```
	
 - The stat functions perform the calculations and the geoms add the visual elements. The user only has to specify the marker value m and binary outcome d, optionally with grouping or faceting. 
 - The resulting ggplot object can be passed to the plot_interactive_roc or export_interactive_roc functions to create interactive figures. Grouping and faceting are fully supported. 
 - The geom_roc displays cutoff labels by default. We have included an additional function style_roc() that adds the layer of styling to match the previous plot_journal_roc(). Its usage is as simple as adding it to a ggplot object: p1 + style_roc(). 
 - Direct labels can be added now with the direct_label() function. This takes the ggplot object as an argument so that it can extract the names: direct_label(p1). 
 - The AUC can be calculated by using the calc_auc() function on a ggplot object: calc_auc(p1). It calculates the AUC for each group or facet present in the plot. 
 - We provide the convenience function melt_roc(), which takes a dataset with multiple markers in different columns, and converts it to long format for use with the ggplot function. An example of its usage is in the paper. 
 
The new version is not currently on CRAN, but I expect it will be in the next few months after ggplot2 is updated. To install, follow these two steps: 

```r
devtools::install_github("hadley/ggplot2")
devtools::install_github("sachsmc/plotROC")
```

I thank the reviewers and editors for their helpful comments, and I hope you find the updated paper and package to be vastly improved. Below are point-by-point responses to the reviewers' comments. 


# Reviewer 1

> This is a really cool package that uses state of the art tech with ggplot and shiny, as well as interactive plots, to display ROC curves.
> Unfortunately, the package is rather difficult to use and quite inconsistent. It also produces some bogus results (see below). As it is now, it looks more like a pretty cool tech demo than a scientific software I would use in my own research. Here are a few comments to try to improve it, as well as the manuscript itself.

## Bug report:
> The confidence intervals are apparently bogus. The following code executed in Rstudio or from the command line, with R 3.1.3 on Ubuntu 14.04 (from CRAN's Debian repository) and R 3.1.2 on Mac OS Yosemite (from Fink):

```r
set.seed(42)
D.ex <- rbinom(100, size = 1, prob = .5)
M.ex <- rnorm(100, mean = D.ex)
roc.estimate <- calculate_roc(round(M.ex, 2), D.ex, ci = TRUE)
plot_interactive_roc(ggroc(roc.estimate, ci = TRUE))
```

> After clicking on a point around 1.6, I got the screenshot shown in Figure 1. This seems related to the rounding (here to the 2nd decimal).

Thank you for the bug report. I believe this was due to the way the previous function handled ties in the results. The computation of the ROC curve in R and the javascript functions for interactivity have been completely revamped. I cannot reproduce the error using the new update in any browser that I've tested, so I believe it has been fixed. 

## General:
> • The manuscript is written partially in the first person. It is surprising and not totally consistent throughout the manuscript, some of which is written in passive tense (for instance “Labels can be added easily [...]”).

I have edited the manuscript to be more consistent with the use of active voice. 

> • The abstract highlights the literature review as a significant finding. Surprisingly it is is only briefly mentioned in the introduction. This seems a bit inconsistent. 

I added another paragraph of discussion at the end of the section about the literature review and how it motivated the package development. The discussion of the review is now its own subsection in the introduction. It is difficult to discuss at length because it is mostly a subjective assessment of the figures. 

> • Strictly speaking one could argue the plotROC package "obscures the cutoffs", as they are not displayed by default when calling the ggroc function. This is not so different from existing packages (as reviewed in subsection 1.3) that allow accessing the thresholds and adding them to the plot in different ways. The user has to request an interactive or journal plot to get them. The abstract and introduction should be rephrased in a more neutral way on this topic, as this is not the key point addressed by this package.

In the update, calling the geom_roc function includes cutoff labels by default. The labels and points are inherently part of the roc geometric layer, and the user can optionally suppress them. 


## Introduction:
> • The introduction states that "ROC curves have been used for decades in signal detection theory". In fact, they originate from this field (s/n in radio receivers, hence the name)

This has been noted in the first paragraph of the introduction.

> • The "good outcome", "bad outcome" is confusing to design correct / incorrect classifications. Especially in the medical field. I don't think it is necessary.

This section has been rewritten for clarity, and the confusion matrix has been added as a table to clarify the terminology. 

> • "A perfect test [...] has TPF(c) = 1 and FPF(c) = 0 for all c". This is not correct. It is sufficient that this equality holds true for a single c.

Thank you, this error has been corrected. 

> • The formula hat(TPF(c)) is slightly confusing. It may be useful to first introduce the confusion table with true | false positive | negatives. It seems correct nonetheless.

I have added a phrase clarifying what the indicator function is, and a sentence simply stating that the formula is simply counting the proportion of test positives out of the group of disease positives.

> • "The greater the AUC, the more informative the test". This statement is incomplete at best. What matters is | AUC - 0.5 |. An AUC = 0 is also the result of a perfect test (for which M < c if I am not mistaken).

This is true when you consider the case where the marker and disease status are negatively correlated. To avoid this issue, as is typical in the ROC curve literature, we make the implicit assumption that larger values of M are more indicative of D = 1. We note this in the introduction, and point out that it is possible for the estimate to lie below the diagonal in a given sample. 

> • Existing software: pROC allows to plot cutoffs quite easily (with print.thres=TRUE, just checked now). Of course it still uses the base R plots.

Thank you for pointing this out, I had overlooked it. This is noted in the summary of existing software. 

> • I am surprised a Pubmed search returned only 54 papers. This part would probably deserve to be expanded a little bit, and maybe turned into a whole section.

I was also surprised by this, and perhaps my search term was too restrictive. I just checked again, and the search returned 59 papers (October 15). The search term is included in the paper source in the litreview/pubmed-search-term.txt file. As mentioned above the subsection called "Motivation" was renamed to Literature Review, and slightly expanded. 


## Usage of the package:
> • Plots such as fig 4 will be hard to read in small figures, as is often seen in journals.

If the image is scaled properly before printing, the fonts should appear in a readable size. This is of course adjustable by using the labelsize option of geom_roc. Figure 1 is scaled appropriately, and I find it to be readable.

> • Fig 5 is unclear. Especially, what was the cutoff used to compute the region, as several ones are displayed in the region?

I have updated the Rocci geom so that the point where the region is calculated is marked as an "X" by default, to distinguish it from the other points. I hope this makes it more clear. 

> • In general, the use of shaded region instead of bars is quite surprising, although perhaps more accurate than bars.

I did consider using boxes instead of shaded regions, and it is possible to do this using the linetype = 1 and alpha.box = 0 options. I am opposed to bars because it is difficult to determine where the boundary is in the corners of the region. 

> • Why are the regions rectangle-shaped and not oval? That would seem even more correct, although probably quite difficult to set up.

They are rectangles because they are a cross product of two 1-dimensional confidence intervals. It is possible to get oval regions if you assume bivariate normality, but I think the exact confidence regions are a better match for the empirical estimate. If you think there's interest, I would consider adding a stat_binormal to compute that estimate as well. 

> • The gridlines in figures 3-5 & 7 are so thin and light-coloured that they did not appear when I printed this manuscript on paper. The printer was not (yet) running out of ink.

This is a result of the default theme in ggplot2, which unfortunately I cannot change. Of course the user can change the appearance of the grid lines using the + theme(panel.grid.major = ..., panel.grid.minor = ...) construction.

> • When reporting an AUC and confidence intervals in a publication, it seems to me at least as important to report values in addition to a plot. One can annotate a curve with the AUC (p. 13), with, for instance, label = “AUC=0.80”. But this value comes out of nowhere, and does not even look realistic (to me it looks more like AUC = 0.7). In addition, it isn't an “Advanced option”, as the subsection suggests, but rather as something quite basic. An easy way out would be to add a few additional lines computing this AUC to the manuscript. The case of CI seem a bit more difficult to deal with.

Agreed, and you are correct in your assessment that the AUC=0.80 label was fake. I have added a function called calc_auc that takes a ggplot object that contains an Roc layer, extracts the data, and calculates the auc. It computes the AUC for each group and returns a data frame containing the group specification and a column containing the AUC estimate. An example of its usage is given on page 13 and in the help file.  

## Package:

> • The usage requires a lot of typing, and does not appear to be straightforward. For instance, the function calculate_roc must be used to create the FPF and TPF matrix. This will create a lot of headaches for infrequent users: is it calculate_, or create_, or generate_, or ...?

I think you will find the update much more user friendly, and consistent with the general usage of ggplot2. 

> • This wouldn't be an issue if users could browse the functions of the package as one can usually do by typing ?plotROC. Unfortunately, this leads to a stub that has never been authored. Please update man/plotROC-package.R with some useful pointers. Of course one can always find this paper, but it is much easier to get a proper help.

This stub has been updated with descriptions, links to key functions, and a series of examples. 

> • It is of course a design choice, but the use of underscores over dots (or camelCase) in function names seems quite surprising and may disturb some users. See Bååth, R. (2012). The State of Naming Conventions in R. R Journal, 4, 74-75. R Foundation for Statistical Computing for a review of current usage of function name styles.

This was a personal choice and unfortunately it won't please everyone. I opted to be consistent with the ggplot2 package, which uses underscores for functions and dots for objects and argument names. 


> • Wouldn't it be more idiomatic to introduce the roc as a ggplot geometry? That would allow some much more straightforward syntax like:
> ```r
> data.for.roc <- data.frame(M.ex, D.ex)
> qplot(M.ex, D.ex, data = data.for.roc) + geom_roc()
> ```
>or suchlike that would be much easier to remember.

Yes I totally agree, and now is is possible since the Geom and Stat functions are exported from ggplot2. However, the qplot function in ggplot2 is now being deprecated, thus it is necessary to use the ggplot(data, aes(m = M, d = D)) + geom_roc() construction. I expect the updates to be on CRAN in the next few months. 

> • I don't understand why one has to pass a ggroc argument to plot_interactive_roc. That is a lot of functions to use in row and in the right order to get an interactive plot, and 3 times (_)?roc. I suspect a few well designed objects would make it much more user-friendly.

I believe the new design is much more user friendly and flexible, although it is still necessary to pass the ggplot object to plot_interactive_roc. 

> • What do the modCss and modJs functions do? The documentation is really limited and an example would help. Same with verify_d. As it stands now these functions seem useless.

These functions have been removed, but to answer your question, they were internal functions that inserted the CSS and javascript source into the html documents generated by export_interactive_roc. In the update, the javascript source files are self-contained in the inst directory, and are pasted into the documents using the getD3() function, which is also internal. verify_d is also an internal function that checks the class labels and converts them to 0/1. These functions are not intended to be used by end-users. 

> • The help files lack examples altogether. Not only does it help a lot to have copy- pasteable code snippets as a start, but it can also help checking the package for potential regressions during updates.

I've added a number of examples to the main help files, including the package help file ?plotROC. 

> • Performance: as most R packages doing ROC curves, this one scales pretty badly with larger sample sizes. I recommend using the cumsum function to compute the FPF/TPF. This will be much faster than the current implementation with sapply (which is really just a hidden slow loop). See the ROCR package that does it correctly. The calculate_roc function with the sample data of subsection 2.4 scaled to 1E5 data points literally collapsed and took > 10 minutes to compute. Such sample sizes may be uncommon in oncology, but are not rare in genomics or computer science. ROCR returns nearly instantly with such a low (sic!) sample size and scales much higher.

The computation has been rewritten to use cumsum instead of a loop. It now scales up much better. There are still bottlenecks in the rendering functions done by ggplot2 and gridSVG, although once the output is written, the interactive figures with large sample sizes are quite responsive. 


> • How do I add the cut-offs to the plot? If I say ggplot(..., ci.at = 0.5) I get an unused argument error and nothing is added. Is this only available in the interactive plot?

Cutoffs are included by default, and the user can adjust the number of cutoffs using the geom_roc(n.cuts = x) option. For now, the placement of cutoffs is automatically determined and set to be evenly spaced. Confidence regions can be placed at specified points using the geom_rocc(ci.at = c(a, b, c)) construction. 


## Shiny app:

> • The shiny application has an hard dependency on ggthemes and is unusable without that package. Unfortunately it is only “Suggest”ed, and and error message is printed only after a query to the shiny web application that doesn't work. PlotROC should either “Depend” on that package, as for shiny, or catch its absence and print the error message immediately when the shiny app is launched.

This has been changed and now the only hard dependency is ggplot2. 

> • On my Ubuntu system, the Download button opens a 404 error page with URL as http://127.0.0.1:3048/session/61edd0aac13532dc34788b220e9d27c8/downlo ad/printDownload?w= instead of downloading the image. I can right click the image and “View image” normally. The download works properly on my Mac where a tab shortly opens before the download starts.

I cannot replicate the error, perhaps it was a shiny bug that got fixed? Is this using the locally running version of the shiny app, or the shinyapps.io hosted version?  Which browsers did this occur in? It seems to work on Ubuntu 14.04 with Firefox. 

> • The browse button appears very low in the page and is not visible enough IMO.

I swapped the locations of the data selector and the upload button. Also there is some bolded help text to draw attention to the upload button. 

# Reviewer 2


> The paper about plotROC describes a new R package for plotting receiver operating characteristic curves (ROC) curves for the evaluation of binary classifiers.

> The paper is well written and gives background on ROC curves, motivation for improving ROC curves based on a literature survey, as well as code examples on how to use plotROC.

> The greatest strengths of the new package are: 
	- Clean and nice graphics (based on ggplot2)
	- The attempt to provide sensible defaults (e.g. for fontsize, axis tickmarks, etc.)
	- Options for interactivity, i.e. providing a web-interface using shiny. This is intended to make high quality ROC analyses accessible to non-technical users

> However, the package falls short of the goal proclaimed in the title of providing a "better tool for plotting ROC curves". While the strengths above deserve credit, other established tools (e.g. the referenced packages pROC and ROCR) provide several other features that are not covered in the current package (e.g. other performance measures, AUC, partial AUC, averaging of curves, aggregating curves across bootstraps or cross-validation folds, and confidence limits and regions on many of those measures).

It was my intention to develop a useful tool for plotting, which seemed to be lacking from the other packages that perform many useful statistical features as you have mentioned. I have included an additional function for calculating the AUC, but I think the other features are best left to the other packages. With the recent update to ggplot2, it is now possible to add additional stats and geoms. A potential future line of work would be to implement some of the statistical transformations and alternative estimates for ROC curves. 

> Also the paper and package suffer from a number of ambiguities and inaccuracies (either technical or in the description):
	- The extreme point TPF/TPR=1/1 is not included in the output of the calculate_roc function. This could lead to problems when plotting curves that don't span the full 0/0 to 1/1 space and also when computing AUCs.

This has been corrected in the updated version. The (0,0) and (1,1) points are now always included in the computation output. 

	
>	- plotROC seems to implictly define that samples ">" the threshold are positive, samples "<=" the threshold are negative. In this it differs from e.g. Fawcett "An introduction to ROC analysis" or other software (e.g. the ROCR package) that define samples ">=" the threshold as a positive prediction.
	
This was an oversight and I thank you for pointing out the error. This has been corrected in the computation and in the text of the introduction. 

>	- It is not obvious how plotROC handles ties (i.e. samples with identical numerical measurements)

The computation handles ties correctly by including them in the calculation of the proportions, and then removing the duplicated elements from the results. This is the same as what is implemented in the ROCR package. 

>	- The paper defines "good outcome" and "bad outcome" in Section 1.1. These definitions seem to ignore half of the confusion matrix (i.e. ignoring true and false negatives).
	

This section has been revamped and edited for clarity. The good and bad outcome terminology has been removed and the confusion matrix illustrating the concepts has been added as table 1. 

>	- In "Help and Documentation" of the webpage, the confusion matrix and the definitions seem to be copied from Wikipedia. Credits and reference are needed.
	
This is correct, it has been adapted from Wikipedia. I added a reference and link. 

>	- The website states "confidence level = 0.05". Should this be "significance level" instead?

Yes this has been changed to significance level. 

> Overall, the paper and package provide some new noteworthy ideas to ROC analysis with the attempt to make high quality analyses more accessible to non-technical experts. The current tool does not have the maturity and comprehensiveness of other tools - therefore the users will be left with the choice between alternative tools, each with their own strengths and weaknesses.

Thank you for the praise and useful criticism, I believe the updated package is much more user friendly and flexible as a plotting tool. 
