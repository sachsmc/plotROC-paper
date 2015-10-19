## ----setup, echo = FALSE, include = FALSE--------------------------------
library(knitr)
library(stringr)

knit_hooks$set(plot = function(x, options) {
  if ('tikz' %in% options$dev && !options$external) {
    hook_plot_tex(x, options)
  } else hook_plot_md(x, options)
})

options(prompt = "R> ")

opts_chunk$set(dev="tikz", prompt = TRUE, sanitize = TRUE, comment = NA)

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


## ----figure1, fig.width = 6, fig.height = 6, message = FALSE, echo = FALSE, fig.cap = "Illustration of design choices in plotting ROC curves. Panel A shows a sparse ROC curve, with no design additions inside the plotting region. The plot results in more white space than anything else. It is difficult to accurately determine values without reference lines. Panel B shows a plot comparing 2 curves, with different line types and a legend. AUCs are also given in the legend. Panels C and D add gridlines, diagonal reference lines, and direct labels. \\label{figure1}"----
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
plot(TPF ~ FPF, data = R1, type = 's', lwd  = 2, xlab = "False positive fraction", ylab = "True positive fraction", main = "C", xlim = c(-.05, 1))
abline(v = seq(0, 1, by = .2), lwd = 1, col = "grey80")
abline(h = seq(0, 1, by = .2), lwd = 1, col = "grey80")
abline(0, 1, col = "grey80")
lines(TPF ~ FPF, data = R1, type = 's', lwd = 2)
text(.35, .6, "Test A")
dexc <- seq(1, length(R1$FPF), length.out = 7)[-c(1, 7)]
text(R1$FPF[dexc] - .075, R1$TPF[dexc] + .05, round(R1$c[dexc], 1))
lines(TPF ~ FPF, data = R1[dexc, ], type = 'p', pch = 20)

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
## devtools::install_github("hadley/ggplot2")
## devtools::install_github("sachsmc/plotROC")
## library(plotROC)

## ----shiny, eval = FALSE-------------------------------------------------
shiny_plotROC()

## ----dataset, echo = -1--------------------------------------------------
#library(plotROC)
set.seed(2529)
D.ex <- rbinom(200, size = 1, prob = .5)
M1 <- rnorm(200, mean = D.ex, sd = .65)
M2 <- rnorm(200, mean = D.ex, sd = 1.5)

test <- data.frame(D = D.ex, D.str = c("Healthy", "Ill")[D.ex + 1],
                   M1 = M1, M2 = M2, stringsAsFactors = FALSE)

## ----calc----------------------------------------------------------------
basicplot <- ggplot(test, aes(d = D, m = M1)) + geom_roc()

## ----opts, eval = FALSE--------------------------------------------------
ggplot(test, aes(d = D, m = M1)) + geom_roc(n.cuts = 0)
ggplot(test, aes(d = D, m = M1)) + geom_roc(n.cuts = 5,
                                             labelsize = 5, labelround = 2)
ggplot(test, aes(d = D, m = M1)) + geom_roc(n.cuts = 50, labels = FALSE)

## ----test-a-ci, eval = 1, fig.cap = "Illustration of \\pkg{plotROC} with exact confidence regions. \\label{ciex}"----
basicplot + geom_rocci()
basicplot + geom_rocci(sig.level = .01)
ggplot(test, aes(d = D, m = M1)) + geom_roc(n.cuts = 0) +
  geom_rocci(ci.at = quantile(M1, c(.1, .4, .5, .6, .9)))

## ----print, eval = 1, fig.width = 6, fig.height = 6, fig.cap = "Illustration of ROC curve plot generated by \\pkg{plotROC} with the styles and direct labels applied for use in print. \\label{first}"----
direct_label(basicplot) + style_roc()
basicplot + style_roc(theme = theme_grey, xlab = "1 - Specificity")
direct_label(basicplot, labels = "Biomarker", nudge_y = -.1)

## ----inter, eval = FALSE-------------------------------------------------
plot_interactive_roc(basicplot)
plot_interactive_roc(basicplot, hide.points = TRUE)
plot_interactive_roc(basicplot, style = style_roc(theme = theme_bw))

## ----head----------------------------------------------------------------
head(test)

## ------------------------------------------------------------------------
longtest <- melt_roc(test, "D", c("M1", "M2"))
head(longtest)

## ----group, eval = FALSE-------------------------------------------------
ggplot(longtest, aes(d = D, m = M, color = name)) + geom_roc()
ggplot(longtest, aes(d = D, m = M)) + geom_roc() + facet_wrap(~ name)
ggplot(longtest, aes(d = D, m = M, linetype = name)) + geom_roc() + geom_rocci()
ggplot(longtest, aes(d = D, m = M, color = name)) + geom_roc()
pairplot <- ggplot(longtest, aes(d = D, m = M, color = name)) +
 geom_roc(show.legend = FALSE)
direct_label(pairplot)
##
pairplot + geom_rocci()
pairplot + geom_rocci(linetype = 1)

## ----ex2, echo = -1------------------------------------------------------
set.seed(400)
D.cov <- rbinom(400, 1, .5)
gender <- c("Male", "Female")[rbinom(400, 1, .49) + 1]
M.diff <- rnorm(400, mean = D.cov,
                sd = ifelse(gender == "Male", .5, 1.5))

test.cov <- data.frame(D = D.cov, gender = gender, M = M.diff)

## ----covplot, fig.width = 6, fig.height = 6, fig.cap = "Illustration of \\pkg{plotROC} with multiple curves. \\label{multi}"----
bygend <- ggplot(test.cov, aes(d = D, m = M, color = gender)) +
  geom_roc(show.legend = FALSE)
direct_label(bygend) + style_roc()

## ----print2s, warning = FALSE, message = FALSE---------------------------
annotate <- basicplot + style_roc(theme = theme_grey) +
  theme(axis.text = element_text(colour = "blue")) +
  ggtitle("Themes and annotations") +
  annotate("text", x = .75, y = .25,
           label = paste("AUC =", round(calc_auc(basicplot)["AUC"], 2))) +
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))

## ----print2, echo = FALSE, fig.width = 6, fig.height = 6, fig.cap = "Using \\pkg{ggplot2} themes and annotations with \\pkg{plotROC} objects. \\label{annotate}"----
annotate

## ----binormalsetup-------------------------------------------------------
D.ex <- test$D
M.ex <- test$M1
mu1 <- mean(M.ex[D.ex == 1])
mu0 <- mean(M.ex[D.ex == 0])
s1 <- sd(M.ex[D.ex == 1])
s0 <- sd(M.ex[D.ex == 0])
c.ex <- seq(min(M.ex), max(M.ex), length.out = 300)

binorm.roc <- data.frame(c = c.ex,
                             FPF = pnorm((mu0 - c.ex)/s0),
                             TPF = pnorm((mu1 - c.ex)/s1)
                             )

binorm.plot <- ggplot(binorm.roc, aes(x = FPF, y = TPF, label = c)) +
  geom_roc(stat = "identity") + style_roc()

## ----binormal, echo = FALSE, fig.width=6, fig.height=6, fig.cap = "Illustration of smooth binormal ROC curve. \\label{binorm}"----
binorm.plot

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

sroclong <- do.call(rbind, sroc)

survplot <- ggplot(sroclong, aes(x = FPF, y = TPF, label = c, color = time)) +
  geom_roc(labels = FALSE, stat = "identity")

survplot
## ----sesh----------------------------------------------------------------
sessionInfo()

