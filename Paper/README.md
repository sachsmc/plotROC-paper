Source Files for "plotROC: A Better Tool for Plotting ROC Curves"
--------------------
Author: Michael C Sachs
====================
### Dependencies

- make
- R (3.1.2) and R packages
	+ knitr (1.8)
	+ plotROC (2.0.-) [available at http://github.com/sachsmc/plotROC]
	+ stringr (0.6.2)
	+ xtable (1.7-4)
	+ ggplot2 (1.0.1) [available at http://github.com/hadley/ggplot2]
	+ survivalROC (1.0.3)
	+ ROCR (1.0-5)
- pandoc (1.13.1)
- A latex distribution (eg. MikTex)

### Details

To recreate the manuscript, run `make sachs2015plotroc.pdf`. This command runs `knitr` on the .Rmd file, converts to .tex with pandoc, and then compiles the pdf using `pdflatex`. A standalone R script containing the code run in the document is the file with the .R extension. 

The pubmed query mentioned on page 3 can be found in the litreview folder, along with the dataset used for analysis. For questions or comments please email me at michael.sachs@nih.gov. 