## ----setup, echo = FALSE, include = FALSE--------------------------------
library(knitr)
library(stringr)

knit_hooks$set(plot = function(x, options) {
  if ('tikz' %in% options$dev && !options$external) {
    hook_plot_tex(x, options)
  } else hook_plot_md(x, options)
})

options(prompt = "R> ")

opts_chunk$set(dev="tikz", prompt = TRUE)

render_sweave()


## ----review, echo = FALSE, results = 'asis'------------------------------
library(xtable)

rev <- read.csv("litreview/rocusage.csv", stringsAsFactors = FALSE)
rev <- subset(rev, flag != "comedy")
rev$axis.names <- gsub("fpr/tpr", "FPF/TPF", rev$axis.names, fixed = TRUE)

mytable <- function(var, groups = sort(unique(var)), tab = FALSE, name = NULL) {

    if(tab) groupsa <- paste0("\t", groups) else groupsa <- groups
    blah <- data.frame(lab = groupsa, `Percent (count)`  = NA, check.names = FALSE, stringsAsFactors = FALSE)
    N <- sum(!is.na(var))
    for(k in 1:length(groups)){

      nk <- sum(var == groups[k])
      perc <- nk/N
      cnt <- nk

      blah[k, 2] <- paste0(format(100 * perc, digits = 1, nsmall = 1), " (", cnt, ")")

    }

    if(all(groups == c("no", "yes"))) {

      c(name, paste0(format(100 * perc, digits = 1, nsmall = 1), " (", cnt, ")"))

      } else blah

  }

rev$numcurves <- with(rev, ifelse(number.of.curves >= 4, "4+", as.character(number.of.curves)))
rev$cutyesno <- with(rev, ifelse(cutoffs != "none" & cutoffs != "points", "yes", "no"))

a1 <- rbind(c("Number of curves", ""), mytable(rev$numcurves, tab = TRUE))
a2 <- c("\tAverage (SD)", paste0(round(mean(rev$number.of.curves), 1), " (", round(sd(rev$number.of.curves), 1), ")"))

b1 <- rbind(c("Axis labels", ""), mytable(rev$axis.names, tab = TRUE))
clist <- with(rev, list(`Diagonal Guide` = guide, Gridlines = minor.axes, `Cutoffs indicated` = cutyesno, `AUC indicated` = auc))
cname <- names(clist)
c1 <- as.data.frame(do.call(rbind, lapply(1:length(clist),
                            function(x) mytable(clist[[x]], groups = c("no", "yes"), tab = FALSE, name = cname[x]))))
colnames(c1) <- colnames(a1)
d1 <- rbind(c("Curve Labels", ""), mytable(rev$labels, tab = TRUE))

table1 <- rbind(a1, a2, b1, c1, d1)
colnames(table1) <- c("", colnames(table1)[2])
print(xtable(table1, label = "table1",
             caption = "Results of a literature review of major oncology journals for ROC curve plots. The rows indicate the frequency and count of key design elements of an ROC curve plot. FPR = False positive rate; TPR = True positive rate; sens = Sensitivity; spec = Specificity; AUC = Area under the Curve"),
      include.rownames = FALSE,
      comment = FALSE,
      sanitize.text.function = function(x) gsub("\t", "$\\quad$", x, fixed = TRUE))


## ----figure1, fig.width = 6, fig.height = 6, echo = FALSE, fig.cap = "Illustration of design choices in plotting ROC curves. Panel A shows a sparse ROC curve, with no design additions inside the plotting region. The plot results in more white space than anything else. It is difficult to accurately determine values without reference lines. Panel B shows a plot comparing 2 curves, with different line types and a legend. AUCs are also given in the legend. Panels C and D add gridlines, diagonal reference lines, and direct labels. \\label{figure1}"----
library(plotROC)

set.seed(520)
D0 <- rbinom(100, size = 1, prob = .5)
M1 <- rnorm(100, mean = D0)
M2 <- rnorm(100, mean = D0, sd = 1.5)

R1 <- calculate_roc(M1, D0)
R2 <- calculate_roc(M2, D0)

par(mfrow = c(2,2))

# A
plot(TPF ~ FPF, data = R1, type = 's', xlab = "1 - Specificity", ylab = "Sensitivity", main = "A")
# B
plot(TPF ~ FPF, data = R1, type = 's', xlab = "1 - Specificity", ylab = "Sensitivity", main = "B")
lines(TPF ~ FPF, data = R2, type = 's', lty = 2)
legend("bottomright", legend = c("Test A: AUC = 0.81", "Test B: AUC = 0.64"), lty = 1:2, cex = .75)

# C
plot(TPF ~ FPF, data = R1, type = 's', lwd  = 2, xlab = "False positive fraction", ylab = "True positive fraction", main = "C")
abline(v = seq(0, 1, by = .2), lwd = 1, col = "grey80")
abline(h = seq(0, 1, by = .2), lwd = 1, col = "grey80")
abline(0, 1, col = "grey80")
lines(TPF ~ FPF, data = R1, type = 's', lwd = 2)
text(.2, .8, "Test A")

# D
plot(TPF ~ FPF, data = R1, type = 's', lwd  = 2, xlab = "False positive fraction", ylab = "True positive fraction", main = "D")
abline(v = seq(0, 1, by = .2), lwd = 1, col = "grey80")
abline(h = seq(0, 1, by = .2), lwd = 1, col = "grey80")
abline(0, 1, col = "grey80")
lines(TPF ~ FPF, data = R1, type = 's', lwd = 2)
lines(TPF ~ FPF, data = R2, type = 's', lwd = 2)
text(.2, .8, "A")
text(.3, .4, "B")

## ----load, eval = FALSE--------------------------------------------------
install.packages("plotROC")
library(plotROC)

## ----shiny, eval = FALSE-------------------------------------------------
shiny_plotROC()

## ----dataset, echo = -1--------------------------------------------------
library(plotROC)
D.ex <- rbinom(100, size = 1, prob = .5)
M.ex <- rnorm(100, mean = D.ex)
roc.estimate <- calculate_roc(M.ex, D.ex)
head(roc.estimate)

## ----test-a--------------------------------------------------------------
single.rocplot <- ggroc(roc.estimate, label = "Example")

## ----inter, eval = FALSE-------------------------------------------------
plot_interactive_roc(single.rocplot)

## ----print, fig.width = 6, fig.height = 6, fig.cap = "Illustration of ROC curve plot generated by \\pkg{plotROC} for use in print. \\label{first}"----
plot_journal_roc(single.rocplot)

## ----multistart----------------------------------------------------------
D.ex <- rbinom(100, 1, .5)

paired.data <- data.frame(M1 = rnorm(100, mean = D.ex),
                       M2 = rnorm(100, mean = D.ex, sd = .4),
                       M3 = runif(100), D = D.ex)

estimate.list <- calculate_multi_roc(paired.data,
                                     c("M1", "M2", "M3"), "D")

## ----multi2, fig.width = 6, fig.height = 6, fig.cap = "Illustration of \\pkg{plotROC} plot with multiple curves. \\label{multi} "----
multi.rocplot <- multi_ggroc(estimate.list, label = c("M1", "M2", "M3"))
plot_journal_roc(multi.rocplot)

## ----multi3, eval = FALSE------------------------------------------------
colorplot <- multi_ggroc(estimate.list,
                        xlabel = "1 - Specificity",
                          ylabel = "Sensitivity")
cat(
 export_interactive_roc(colorplot, lty = rep(1, 3),
                        color = c("black", "purple", "orange"),
                        legend = TRUE)
 )

## ----test-a-ci-----------------------------------------------------------
roc.ci <- calculate_roc(paired.data$M1, paired.data$D,
                        ci = TRUE, alpha = 0.05)
ci.rocplot <- ggroc(roc.ci, label = "CI Example", ci = TRUE)

## ----int-nob, eval = FALSE-----------------------------------------------
cat(
export_interactive_roc(ci.rocplot,
                        prefix = "aci")
   )

## ----printci, fig.width = 6, fig.height = 6, fig.cap = "Illustration of \\pkg{plotROC} plot with exact confidence regions. \\label{conf}"----
plot_journal_roc(ci.rocplot, n.cuts = 10,
                 ci.at = c(-.5, .5, 2.1))

## ----print2, warning = FALSE, message = FALSE, fig.width = 6, fig.height = 6, fig.cap = "Using \\pkg{ggplot2} themes and annotations with \\pkg{plotROC} objects. \\label{annotate}"----
library(ggplot2)
plot_journal_roc(ci.rocplot, n.cuts = 10,
                 ci.at = c(-.5, .5, 2.1)) +
  theme_grey() +
  geom_abline(intercept = 0, slope = 1, color = "white") +
  ggtitle("Themes and annotations") +
  annotate("text", x = .75, y = .25,
           label = "AUC = 0.80") +
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))

## ----binormalsetup-------------------------------------------------------
D.ex <- rbinom(100, 1, .5)
M.ex <- rnorm(100, mean = D.ex, sd = .5)

mu1 <- mean(M.ex[D.ex == 1])
mu0 <- mean(M.ex[D.ex == 0])
s1 <- sd(M.ex[D.ex == 1])
s0 <- sd(M.ex[D.ex == 0])
c.ex <- seq(min(M.ex), max(M.ex), length.out = 300)

binorm.roc <- data.frame(c = c.ex,
                             FPF = pnorm((mu0 - c.ex)/s0),
                             TPF = pnorm((mu1 - c.ex)/s1)
                             )

## ----binormal, echo = TRUE, fig.width=6, fig.height=6, fig.cap = "Illustration of smooth binormal ROC curve. \\label{binorm}"----
binorm.plot <- ggroc(binorm.roc, label = "Binormal")
plot_journal_roc(binorm.plot)

## ----rocr, message = FALSE, warning = FALSE------------------------------
library(ROCR)
rocr.est <- performance(prediction(M.ex, D.ex), "tpr", "fpr")
rocr.plot <- ggroc(rocr.est, label = "ROCR object")

## ----survival------------------------------------------------------------
library(survivalROC)
survT <- rexp(350, 1/5)
cens <- rbinom(350, 1, .1)
M <- -8 * sqrt(survT) + rnorm(350, sd = survT)
sroc <- lapply(c(2, 5, 10), function(t){
  stroc <- survivalROC(Stime = survT, status = cens, marker = M,
                       predict.time = t, method = "NNE",
                       span = .25 * 350^(-.2))
  data.frame(TPF = stroc[["TP"]], FPF = stroc[["FP"]],
             c = stroc[["cut.values"]],
             time = rep(stroc[["predict.time"]],
                        length(stroc[["FP"]])))
  })

surv.plot <- multi_ggroc(sroc, label = paste("t =", c(2, 5, 10)))

## ----diagram, include = FALSE--------------------------------------------
library(DiagrammeR)

DiagrammeR("
  graph LR;
    A[ROC Estimate]-->|ggroc|B(ggplot object);
    B-->|plot_journal_roc|C(Static Plot);
    B-->|grid.export|D(svg object);
    D-->E(Interactive Plot);
    F(d3.js functions)-->E;
    G(css styles)-->E;

  style A fill:#DCEBE3
  style C fill:#A2EB86
  style E fill:#A2EB86
")

## export as pdf


## ----sesh----------------------------------------------------------------
sessionInfo()

