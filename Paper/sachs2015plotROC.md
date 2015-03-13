---
title: '\pkg{plotROC}: A Better Tool for Plotting ROC Curves'
shorttitle: '\pkg{plotROC}: A Better Tool for Plotting ROC Curves'
plaintitle: 'plotROC: A Better Tool for Plotting ROC Curves'
author:
- name: Michael C. Sachs
  affil: Biometric Research Branch, Division of Cancer Treatment and Diagnosis, National Cancer Institute
address:
- Michael C. Sachs
- 9609 Medical Center Drive, MSC 9735
- Bethesda, MD 20892
- "telephone: 240-276-7888"
email: michael.sachs@nih.gov
abstract: 'Plots of the receiver operating characteristic (ROC) curve are ubiquitous in medical research. Designed to simultaneously display the operating characteristics at every possible value of a continuous diagnostic test, ROC curves are used in oncology to evaluate screening, diagnostic, prognostic and predictive biomarkers. I reviewed a sample of ROC curve plots from the major oncology journals in order to assess current trends in usage and design elements. My review suggests that ROC curve plots are often ineffective as statistical charts and that poor design obscures the relevant information the chart is intended to display. I describe my new \proglang{R} package that was created to address the shortcomings of existing tools. The package has functions to create informative ROC curve plots, with sensible defaults, for use in print or as an interactive web-based plot. A web application was developed to reach a broader audience of scientists who do not use \proglang{R}.'
keywords: ROC curves; graphics; interactive; plots
bibliography: plotroc
...




# Introduction

## About ROC curves

The Receiver Operating Characteristic (ROC) curve is used to assess the accuracy of a continuous measurement for predicting a binary outcome. In medicine, ROC curves have a long history of use for evaluating diagnostic tests in radiology and general diagnostics. ROC curves have also been used for decades in signal detection theory. 

The accuracy of a diagnostic test can be evaluated by considering two possible types of errors: false positives, and false negatives. For a continuous measurement that I denote as $M$, convention dictates that a test positive is defined as $M$ exceeding some fixed threshold $c$: $M > c$. In reference to the binary outcome that I denote as $D$, a good outcome of the test is when the test is positive for an individual who truly has a disease: $D = 1$. A bad outcome is when the test is positive for an individual who does not have the disease $D = 0$. 

Formally, for a fixed cutoff $c$, the true positive fraction is the probability of a test positive in the diseased population:

$$ TPF(c) = P\{ M > c | D = 1 \} $$

and the false positive fraction is the probability of a test positive in the healthy population:

$$ FPF(c) = P\{ M > c | D = 0 \} $$

Since the cutoff $c$ is not fixed in advance, I can plot the TPF against the FPF for all possible values of $c$. This is exactly what the ROC curve is, a plot of $FPF(c)$ on the $x$ axis and $TPF(c)$ along the $y$ axis as $c$ varies. A useless test that is not informative at all in regards to the disease status has $TPF(c) = FPF(c)$ for all $c$. The ROC plot of a useless test is thus the diagonal line. A perfect test that is completely informative about disease status has $TPF(c) = 1$ and $FPF(c) = 0$ for all $c$. 

Given a sample of test and disease status pairs, $(M_1, D_1), \ldots, (M_n, D_n)$, I can estimate the ROC curve by computing proportions in the diseased and healthy subgroups separately. Specifically, given a fixed cutoff $c$, an estimate of the $TPF(c)$ is

$$ \widehat{TPF(c)} = \frac{\sum_{i = 1}^n 1\{M_i > c\} \cdot 1\{D_i = 1\}}{\sum_{i=1}^n 1\{D_i = 1\}}, $$ 

where $1\{\cdot\}$ is the indicator function. An estimate for $FPF(c)$ is given by a similar expression with $D_i = 1$ replaced with $D_i = 0$. Calculating these proportions for $c$ equal to each unique value of the observed $M_i$ yields what is known as the empirical ROC curve estimate. The empirical estimate is a step function. Other methods exist to estimate the ROC curve, such as the binormal parametric estimate which can be used to get a smooth curve. There are also extensions that allow for estimation with time-to-event outcomes subject to censoring. For a more thorough reference on the methods and theory surrounding ROC curves, I refer interested readers to @pepe2003statistical.

A common way to summarize the value of a test for classifying disease status is to calculate the area under the ROC curve (AUC). The greater the AUC, the more informative the test. The AUC summarizes the complexities of the ROC curve into a single number and therefore is widely used to facilitate comparisons between tests and across populations. It has been criticized for the same reason because it does not fully characterize the trade-offs between false- and true-positives. 

## Design considerations

The main purpose of visually displaying the ROC curve is to show the trade-off between the FPF and TPF as the cutoff $c$ varies. This can be useful for aiding viewers in choosing an optimal cutoff for decision making, for comparing a small number of candidate tests, and for generally illustrating the performance of the test as a classifier. In practice, once the FPF and TPF are computed for each unique observed cutoff value, they can be plotted as a simple line chart or scatter plot using standard plotting tools. This often leads to the unfortunate design choice of obscuring the critical and useful third dimension, the range of cutoff values $c$. 

Another key design element is the use of a diagonal guideline for comparison. They allow observers to roughly estimate the area between the diagonal and the estimated ROC curve, which serves as a proxy for estimating the value of the test for classification above a useless test. Likewise, gridlines inside the plotting region and carefully selected axes allow for accurate assessment of the TPF and FPF at particular points along the ROC curve. Many medical studies use ROC curves to compare a multitude of candidate tests to each other. In those cases, curves need to be distinguished by using different colors or line types combined with a legend, or direct labels inside the plotting region. 

In the medical literature, FPF and TPF are usually referred to in terms of the jargon sensitivity and specificity. Sensitivity is equivalent to the true positive fraction. Specificity is 1 - FPF, the true negative fraction. Sometimes, the FPF and TPF are incorrectly referred to as rates, using the abbreviations FPR and TPR. These are probabilities and their estimates are proportions, therefore I prefer the use of the term fraction as opposed to rate. 

## Existing plotting software

The ROC curve plot is, at the most basic level, a line graph. Therefore, once the appropriate statistics are estimated, existing plotting functions can be used to create an ROC curve plot. Viewers can identify ROC plots through context, by observing the shape of the line, and through the addition of axis labels, titles, legends, and so on. In my review of the oncology literature, I observed plots with the distinctive characteristics of the plotting functions from Microsoft Excel [@excel], \proglang{SAS} [@sas], \proglang{SPSS} [@spss], and the base \proglang{R} plotting functions [@arr]. 

There are several \proglang{R} packages related to ROC curve estimation that contain dedicated plotting functions. The \pkg{ROCR} package [@rocr] plots the FPF _versus_ TPF, as usual, and then takes the interesting approach of encoding the cutoff values as a separate color scale along the ROC curve itself. A legend for the color scale is placed along the vertical axis on the right of the plotting region. Due to the popularity of \pkg{ROCR}, my package supports the performance objects as returned by \pkg{ROCR}. The \pkg{pROC} package [@pROC] is mainly focused on estimating confidence intervals and regions for restricted ranges of the ROC curve. The plotting methods therein use the base \proglang{R} plotting functions to create nice displays of the curves along with shaded confidence regions. My \pkg{plotROC} package uses the \pkg{ggplot2} [@ggplot2] plotting library to create clear, informative ROC plots, with interactive features for use on the web, and sensible defaults for use in print. 

## Motivation

Anyone giving a cursory look at any of the major medical journals is likely to find at least one ROC curve plot. I sought to assess the usage of ROC curve plots and to evaluate the design choices made in the current oncology literature by conducting a small literature review. I searched Pubmed for  clinical trials or observational studies in humans reported in major oncology journals for the past 10 years for the terms "ROC Curve" OR "ROC Analysis" OR "Receiver operating characteristic curve". The search was conducted on October 8, 2014 and returned 54 papers. From those papers, 47 images were extracted and reviewed. The exact specifications for the Pubmed query are available in the manuscript source files. 

Each image consisted of a single ROC curve plot or a panel of multiple plots. Each plot was inspected manually for the following design features: the number of curves displayed, the type of axis labels (sensitivity/ 1 - specificity or true/false positive fractions), presence or absence of grid lines, presence or absence of a diagonal guide line, whether any cutpoints were indicated, the type of curve label (legend or direct label), and presence of other textual annotations such as the AUC. The numerical results of the survey are summarized in Table \ref{table1}. 

\begin{table}[ht]
\centering
\begin{tabular}{ll}
  \hline
 & Percent (count) \\ 
  \hline
Number of curves &  \\ 
  $\quad$1 & 19.6 (9) \\ 
  $\quad$2 & 43.5 (20) \\ 
  $\quad$3 & 10.9 (5) \\ 
  $\quad$4+ & 26.1 (12) \\ 
  $\quad$Average (SD) & 2.6 (1.5) \\ 
  Axis labels &  \\ 
  $\quad$FPF/TPF & 13.0 (6) \\ 
  $\quad$mixed & 2.2 (1) \\ 
  $\quad$none & 2.2 (1) \\ 
  $\quad$sens/spec & 82.6 (38) \\ 
  Diagonal Guide & 43.5 (20) \\ 
  Gridlines & 17.4 (8) \\ 
  Cutoffs indicated & 15.2 (7) \\ 
  AUC indicated & 50.0 (23) \\ 
  Curve Labels &  \\ 
  $\quad$direct & 10.9 (5) \\ 
  $\quad$legend & 63.0 (29) \\ 
  $\quad$none & 19.6 (9) \\ 
  $\quad$title & 6.5 (3) \\ 
   \hline
\end{tabular}
\caption{Results of a literature review of major oncology journals for ROC curve plots. The rows indicate the frequency and count of key design elements of an ROC curve plot. FPR = False positive rate; TPR = True positive rate; sens = Sensitivity; spec = Specificity; AUC = Area under the Curve} 
\label{table1}
\end{table}


The small minority of the figures make any attempt to indicate the values of the test cutoffs, which is an integral component of the ROC curve. I conjecture that this is mainly due to the use of default plotting procedures in statistical software. The software, by default, treats the ROC curve as a 2 dimensional object, obscuring the cutoff dimension. Gridlines and direct labels are also somewhat out of the ordinary. The absence of these features make accurate determination and comparison of the values more difficult. Many of the plots included large tables containing estimates and inference for AUCs, while the ROC curves themselves, numerous and without clear labels or reference lines, merely served as decoration. I aim to solve some of these problems by providing an easy-to-use plotting interface for the ROC curve that provides sensible defaults. 

The panels of Figure \ref{figure1} illustrate the most common styles of ROC curve plots, and the associated design elements. I favor the use of gridlines and a diagonal reference line to facilitate accurate readings off of the axes. Direct labels are preferred over legends because they omit the additional cognitive step of matching line types or colors to labels. My \pkg{plotROC} package additionally provides plotting of cutoff values, which are displayed interactively with the web-based output option, and direct labels for print use. Exact confidence regions for points on the ROC curve are optionally calculated and displayed. Additionally, I use axis scales adjusted to be denser near the margins 0 and 1. In medical applications, it is often necessary to have a very low FPR (less than 10%, for instance), therefore the smaller scales are useful for accurately determining values near the margins. The next section details the usage of the \pkg{plotROC} \proglang{R} package and these features. 

\begin{Schunk}
\begin{figure}
\includegraphics{figure/figure1-1} \caption[Illustration of design choices in plotting ROC curves]{Illustration of design choices in plotting ROC curves. Panel A shows a sparse ROC curve, with no design additions inside the plotting region. The plot results in more white space than anything else. It is difficult to accurately determine values without reference lines. Panel B shows a plot comparing 2 curves, with different line types and a legend. AUCs are also given in the legend. Panels C and D add gridlines, diagonal reference lines, and direct labels. \label{figure1}}\label{fig:figure1}
\end{figure}
\end{Schunk}

# Usage of the package

## Shiny application

I created a \pkg{shiny} application [@shiny] in order to make the features more accessible to non-\proglang{R} users. A limited subset of the functions of \pkg{plotROC} can be performed on an example dataset or on data that users upload to the website. Resulting plots can be saved to the users' machine as a pdf or as a stand-alone html file.  It can be used in any modern web browser with no other dependencies at the website here: http://sachsmc.shinyapps.io/plotROC. 

## Installation and loading

\pkg{plotROC} can be installed from the Comprehensive \proglang{R} Archive Network, or installed from source. 

\begin{Schunk}
\begin{Sinput}
R> install.packages("plotROC")
R> library(plotROC)
\end{Sinput}
\end{Schunk}

## Quick start
After installing, the interactive Shiny application can be run locally. 
\begin{Schunk}
\begin{Sinput}
R> shiny_plotROC()
\end{Sinput}
\end{Schunk}

## Command line basic usage

I start by creating an example data set. The marker I generate is moderately accurate for predicting disease status. Next I use the \code{calculate_roc} function to compute the empirical ROC curve. The disease status need not be coded as 0/1, but if it is not, \code{calculate_roc} assumes (with a warning) that the lowest value in sort order signifies disease-free status. This returns a dataframe with three columns: the cutoff values, the TPF and the FPF. 

\begin{Schunk}
\begin{Sinput}
R> D.ex <- rbinom(100, size = 1, prob = .5)
R> M.ex <- rnorm(100, mean = D.ex)
R> roc.estimate <- calculate_roc(M.ex, D.ex)
R> head(roc.estimate)
\end{Sinput}
\begin{Soutput}
          c TPF       FPF
1 -2.182331   1 0.9811321
2 -1.674012   1 0.9622642
3 -1.568181   1 0.9433962
4 -1.550585   1 0.9245283
5 -1.539929   1 0.9056604
6 -1.190555   1 0.8867925
\end{Soutput}
\end{Schunk}

The \code{roc.estimate} object is passed to the \code{ggroc} function with an optional label. This creates a \code{ggplot} object of the ROC curve using the \pkg{ggplot2} package [@ggplot2]. 

\begin{Schunk}
\begin{Sinput}
R> single.rocplot <- ggroc(roc.estimate, label = "Example")
\end{Sinput}
\end{Schunk}

The \code{single.rocplot} object can be used to create an interactive plot and display it in the Rstudio viewer or default web browser by passing it to the \code{plot_interactive_roc} function. Give the function an optional path to an html file as an argument called \code{file} to save the interactive plot as a complete web page. A screen shot of an interactive plot is shown in Figure \ref{interact}. Hovering over the display shows the cutoff value at the point nearest to the cursor. Clicking makes the cutoff label stick until the next click, and if confidence regions are available, clicks will also display those as grey rectangles. 

\begin{Schunk}
\begin{Sinput}
R> plot_interactive_roc(single.rocplot)
\end{Sinput}
\end{Schunk}

\begin{figure}[ht]
\centering
\includegraphics{figure/screen-shot.pdf}
\caption{Screen shot of an interactive plot created with \pkg{plotROC} being displayed in the Rstudio viewer. Hovering the mouse cursor over the plot causes the cutoff label nearest to the cursor to be displayed. Clicking will display a confidence region, if available, and make the label stick until the next click. For live examples, see the package vignette, or go to http://sachsmc.github.io/plotROC. \label{interact}}
\end{figure}


An interactive ROC plot can be exported by using the \code{export_interactive_roc} function, which returns a character string containing the necessary \proglang{HTML} and \proglang{JavaScript}. The character string can be copy-pasted into an html document, or better yet, incorporated directly into a dynamic document using \pkg{knitr} [@knitr]. In a \pkg{knitr} document, it is necessary to use the \code{cat} function on the results and use the chunk options \code{results = 'asis'} and \code{fig.keep = 'none'} so that the interactive plot is displayed correctly. For documents that contain multiple interactive plots, it is necessary to assign each plot a unique name using the \code{prefix} argument of \code{export_interactive_roc}. This is necessary to ensure that the \proglang{JavaScript} code manipulates the correct svg elements. For examples of interactive plots and how to incorporate them into \pkg{knitr} documents, see the package vignette (\code{vignette("examples", package = "plotROC")}) or the web page https://sachsmc.github.io/plotROC/. The next code block shows an example \pkg{knitr} chunk that can be used in an .Rmd document to display an interactive plot. 

\begin{Code}
```{r int-no, results = 'asis', fig.keep = 'none'}
cat(
  export_interactive_roc(single.rocplot, 
                        prefix = "a")
  )
```
\end{Code}

The same \code{ggroc} object that I called \code{single.rocplot} can be used to generate an ROC plot suitable for use in print. It annotates the cutoff values and is completely in black and white. A simple example with the default options is shown in Figure \ref{first}. 

\begin{Schunk}
\begin{Sinput}
R> plot_journal_roc(single.rocplot)
\end{Sinput}
\begin{figure}
\includegraphics{figure/print-1} \caption{Illustration of ROC curve plot generated by \pkg{plotROC} for use in print. \label{first}}\label{fig:print}
\end{figure}
\end{Schunk}

### Multiple ROC curves

If you have multiple tests of different types measured on the same subjects, you can use the \code{calculate_multi_roc} function to compute the empirical ROC curve for each test. It returns a list of data frames with the estimates and cutoff values. Then the \code{multi_ggroc} function creates the appropriate type of \code{ggplot} object. Confidence regions are not supported for multiple curves at the time of writing. 

\begin{Schunk}
\begin{Sinput}
R> D.ex <- rbinom(100, 1, .5)
R> 
R> paired.data <- data.frame(M1 = rnorm(100, mean = D.ex), 
+                        M2 = rnorm(100, mean = D.ex, sd = .4), 
+                        M3 = runif(100), D = D.ex)
R> 
R> estimate.list <- calculate_multi_roc(paired.data, 
+                                      c("M1", "M2", "M3"), "D")
\end{Sinput}
\end{Schunk}

Labels can be added easily with the \code{label} option of \code{multi_ggroc}. The length of the label element should match the number of plotted curves. The \code{multi_ggroc} object can be passed to the \code{plot_journal_roc} and the \code{export_interactive_roc} functions, as desired. The resulting plot is shown in Figure \ref{multi}.

\begin{Schunk}
\begin{Sinput}
R> multi.rocplot <- multi_ggroc(estimate.list, label = c("M1", "M2", "M3"))
R> plot_journal_roc(multi.rocplot)
\end{Sinput}
\begin{figure}
\includegraphics{figure/multi2-1} \caption{Illustration of \pkg{plotROC} plot with multiple curves. \label{multi} }\label{fig:multi2}
\end{figure}
\end{Schunk}

Both \code{plot_journal_roc} and \code{export_interactive_roc} support a number of options to customize the look of the plots. By default, multiple curves are distinguished by different line types and direct labels. For multiple ROC curves that are similar to one another, those defaults can make it difficult to interpret the plots. Therefore, we also support colors and legends. The x- and y-axis can be changed by passing options to \code{ggroc} or \code{multi_ggroc}. The next code block illustrates the available options. 

\begin{Schunk}
\begin{Sinput}
R> colorplot <- multi_ggroc(estimate.list, 
+                          xlabel = "1 - Specificity", 
+                          ylabel = "Sensitivity")
R> cat(
+   export_interactive_roc(colorplot, lty = rep(1, 3), 
+                          color = c("black", "purple", "orange"), 
+                          legend = TRUE)
+   )
\end{Sinput}
\end{Schunk}

## Advanced options

### Click to view confidence region

I use the \code{ci = TRUE} option in \code{calculcate_roc} and \code{ggroc} to compute confidence regions for points on the ROC curve using the @clopper1934use exact method. Briefly, exact confidence intervals are calculated for the $FPF$ and $TPF$ separately, each at level $1 - \sqrt{1 - \alpha}$. Based on result 2.4 from @pepe2003statistical, the cross-product of these intervals yields a $100 * (1 - \alpha)$ percent rectangular confidence region for the pair. The significance level can be specified using the \code{alpha} option. 

\begin{Schunk}
\begin{Sinput}
R> roc.ci <- calculate_roc(paired.data$M1, paired.data$D, 
+                         ci = TRUE, alpha = 0.05)
R> ci.rocplot <- ggroc(roc.ci, label = "CI Example", ci = TRUE)
\end{Sinput}
\end{Schunk}

For interactive plots, the confidence regions are automatically detected. When the user clicks on the ROC curve, the confidence region for the TPF and FPF is overlaid using a grey rectangle. The label and region stick until the next click.

\begin{Schunk}
\begin{Sinput}
R> cat(
+   export_interactive_roc(ci.rocplot, 
+                          prefix = "aci")
+   )
\end{Sinput}
\end{Schunk}

For use in print, I pass a small vector of cutoff locations at which to display the confidence regions. This is shown in Figure \ref{conf}.

\begin{Schunk}
\begin{Sinput}
R> plot_journal_roc(ci.rocplot, n.cuts = 10, 
+                  ci.at = c(-.5, .5, 2.1))
\end{Sinput}
\begin{figure}
\includegraphics{figure/printci-1} \caption{Illustration of \pkg{plotROC} plot with exact confidence regions. \label{conf}}\label{fig:printci}
\end{figure}
\end{Schunk}

### Themes and annotations

\pkg{plotROC} uses the \pkg{ggplot2} package to create the objects to be plotted. Therefore, themes and annotations can be added in the usual \pkg{ggplot2} way. A \code{plot_journal_roc} figure with a new theme, title, axis label, and AUC annotation is shown in Figure \ref{annotate}. 

\begin{Schunk}
\begin{Sinput}
R> library(ggplot2)
R> plot_journal_roc(ci.rocplot, n.cuts = 10, 
+                  ci.at = c(-.5, .5, 2.1)) + 
+   theme_grey() + 
+   geom_abline(intercept = 0, slope = 1, color = "white") + 
+   ggtitle("Themes and annotations") + 
+   annotate("text", x = .75, y = .25, 
+            label = "AUC = 0.80") +
+   scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))
\end{Sinput}
\begin{figure}
\includegraphics{figure/print2-1} \caption{Using \pkg{ggplot2} themes and annotations with \pkg{plotROC} objects. \label{annotate}}\label{fig:print2}
\end{figure}
\end{Schunk}

### Other estimation methods

By default \code{calculate_roc} computes the empirical ROC curve. There are other estimation methods out there, as I have summarized in the introduction.  Any estimation method can be used, as long as the cutoff, the TPF and the FPF are returned. Then you can simply pass those values in a data frame to the \code{ggroc} function. For example, let us use the binormal method to create a smooth curve. This approach assumes that the test distribution is normal conditional on disease status. 

\begin{Schunk}
\begin{Sinput}
R> D.ex <- rbinom(100, 1, .5)
R> M.ex <- rnorm(100, mean = D.ex, sd = .5)
R> 
R> mu1 <- mean(M.ex[D.ex == 1])
R> mu0 <- mean(M.ex[D.ex == 0])
R> s1 <- sd(M.ex[D.ex == 1])
R> s0 <- sd(M.ex[D.ex == 0])
R> c.ex <- seq(min(M.ex), max(M.ex), length.out = 300)
R> 
R> binorm.roc <- data.frame(c = c.ex, 
+                              FPF = pnorm((mu0 - c.ex)/s0), 
+                              TPF = pnorm((mu1 - c.ex)/s1)
+                              )
\end{Sinput}
\end{Schunk}

Then I can pass this \code{data.frame} to the \code{ggroc} function as before. The example is shown in Figure \ref{binorm}.

\begin{Schunk}
\begin{Sinput}
R> binorm.plot <- ggroc(binorm.roc, label = "Binormal")
R> plot_journal_roc(binorm.plot)
\end{Sinput}
\begin{figure}
\includegraphics{figure/binormal-1} \caption[Illustration of smooth binormal ROC curve]{Illustration of smooth binormal ROC curve. \label{binorm}}\label{fig:binormal}
\end{figure}
\end{Schunk}

\pkg{plotROC} also supports the use of the \pkg{ROCR} estimation method. Objects as returned by the function \code{rocr::performance} can be passed directly to \code{ggroc}: 

\begin{Schunk}
\begin{Sinput}
R> library(ROCR)
R> rocr.est <- performance(prediction(M.ex, D.ex), "tpr", "fpr")
R> rocr.plot <- ggroc(rocr.est, label = "ROCR object")
\end{Sinput}
\end{Schunk}

Another potential use of this approach is for plotting time-dependent ROC curves for time-to-event outcomes estimated as desribed in [@heagerty2000time]. Here is an example using the \pkg{survivalROC} package [@survroc] for estimation:

\begin{Schunk}
\begin{Sinput}
R> library(survivalROC)
R> survT <- rexp(350, 1/5)
R> cens <- rbinom(350, 1, .1)
R> M <- -8 * sqrt(survT) + rnorm(350, sd = survT)
R> sroc <- lapply(c(2, 5, 10), function(t){ 
+   stroc <- survivalROC(Stime = survT, status = cens, marker = M, 
+                        predict.time = t, method = "NNE", 
+                        span = .25 * 350^(-.2))
+   data.frame(TPF = stroc[["TP"]], FPF = stroc[["FP"]], 
+              c = stroc[["cut.values"]], 
+              time = rep(stroc[["predict.time"]], 
+                         length(stroc[["FP"]])))
+   })
R> 
R> surv.plot <- multi_ggroc(sroc, label = paste("t =", c(2, 5, 10)))
\end{Sinput}
\end{Schunk}


# How it works

\pkg{plotROC} makes use of \pkg{ggplot2} [@ggplot2], \pkg{gridSVG} [@gridsvg], and \pkg{d3.js} [@bostock2011d3] to create interactive plots. The first step in the process is to create \code{ggplot} objects using the \code{ggroc} or \code{multi_ggroc} functions. These functions return standard \code{ggplot} objects that include basic styling, hidden cutoff labels, and hidden confidence regions. They can be plotted and inspected in the \proglang{R} console. These form the basis for both the print versions and the interactive versions of the plots. Creating a print version by using the \code{plot_journal_roc} function simply makes visible a subset of the hidden cutoff labels and confidence regions, if available. 

\pkg{plotROC} makes interactive plots by first converting the \code{ggplot} object into a scalable vector graphic (svg) object with the \code{gridSVG::grid.export} function. This function maps each element of the plot to a corresponding element of the svg markup language. I keep track of the names of the points and labels elements so that I can add interactivity using \pkg{d3.js} and \proglang{JavaScript}. The main interactive feature I wanted was to be able to display the cutoff labels at the points on the ROC curve closest to the mouse cursor. 

There are many ways to solve this with \pkg{d3.js}, but I decided to use Voronoi polygons to map the cursor location to the nearest point on the ROC curve. The idea is that for the set of cutoff points along the ROC curve, the \code{d3.geom.voronoi} function chain computes a set of polygons overlaying the plotting region such that the area of each polygon contains the region of the plot closest to it's corresponding cutoff point. Hover events are bound to the polygons so that when the mouse cursor moves around the plotting region, the closest point on the ROC curve is made visible. Similarly, click events are bound to the polygons so that the appropriate confidence region is made visible upon clicking. The svg code and all necessary \proglang{JavaScript} code is returned in the character string provided by \code{export_interactive_roc}. Figure \ref{flow} outlines the \pkg{plotROC} process. 



\begin{figure}[ht]
\centering
\includegraphics{figure/diagram.pdf}
\caption{Flowchart illustrating the approach that \pkg{plotROC} takes to generate either static plots for print or interactive plots for web-use. \label{flow}}
\end{figure}

This approach is similar to what is done in the \pkg{gridSVG} \code{grid.animate} function, which uses the svg \code{<animate />} tags. However, the available features were not sufficient for my needs, which is why I used \pkg{d3.js}. There are several other \proglang{R} packages that aim to create interactive figures. The authors of \pkg{animint} [@animint] created an extensive \proglang{JavaScript} library that creates plots in a similar way as \pkg{ggplot2}. A set of interactive features can be added to plots using \pkg{d3.js}. \pkg{ggvis} [@ggvis], \pkg{rCharts} [@rcharts], and the more recently released \pkg{htmlwidgets} [@htmlwidgets] all leverage existing charting libraries written in \proglang{JavaScript}. \pkg{qtlcharts} [@qtlcharts] uses a set of custom \proglang{JavaScript} and \pkg{d3.js} functions to visualize data from genetic experiments. Their general approach is to manipulate the data and create options in \proglang{R}, and then let the charting libraries or functions handle the rendering and interactivity. \pkg{plotROC} lets \proglang{R} do the rendering, allowing the figures to be consistent across print and web-based media, and retaining the distinctive \proglang{R} style. This also allows users to manipulate the figures directly in \proglang{R} to suit their needs, using tools that are more accessible and familiar to most \proglang{R} users. 


# Discussion

Here I have illustrated the usage and described the mechanics of a new \proglang{R} package for creating ROC curve plots. The functions are easy to use, even for non-\proglang{R} users _via_ the web application, yet have sufficient flexibility to meet the needs of power users. My approach to creating interactive plots differs from other interactive charting packages. I found that existing approaches did not meet the highly specialized needs of plotting ROC curves. While ROC curve plots can technically be created with even the most basic plotting tools, I find that specialized functions make the results clearer and more informative. 

## Reproducibility note

This manuscript is completely reproducible using the source files. The output below indicates the \proglang{R} packages and versions used. Compiling the pdf output also requires \pkg{pandoc} version 1.13.1 and \pkg{pdflatex}. 

\begin{Schunk}
\begin{Sinput}
R> sessionInfo()
\end{Sinput}
\begin{Soutput}
R version 3.1.2 (2014-10-31)
Platform: x86_64-apple-darwin13.4.0 (64-bit)

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

attached base packages:
[1] methods   stats     graphics  grDevices utils     datasets  base     

other attached packages:
 [1] DiagrammeR_0.4    survivalROC_1.0.3 ROCR_1.0-5       
 [4] gplots_2.16.0     ggplot2_1.0.0     tikzDevice_0.8.1 
 [7] plotROC_1.3.3     xtable_1.7-4      stringr_0.6.2    
[10] knitr_1.9        

loaded via a namespace (and not attached):
 [1] bitops_1.0-6       caTools_1.17.1     colorspace_1.2-4  
 [4] digest_0.6.8       evaluate_0.5.5     filehash_2.2-2    
 [7] formatR_1.0.3      gdata_2.13.3       grid_3.1.2        
[10] gtable_0.1.2       gtools_3.4.1       highr_0.4         
[13] htmltools_0.2.6    htmlwidgets_0.3.2  KernSmooth_2.23-14
[16] MASS_7.3-39        munsell_0.4.2      plyr_1.8.1        
[19] proto_0.3-10       Rcpp_0.11.4        reshape2_1.4.1    
[22] RJSONIO_1.3-0      rstudioapi_0.2     scales_0.2.4      
[25] tools_3.1.2        yaml_2.1.13       
\end{Soutput}
\end{Schunk}

Bibliography 
===============



