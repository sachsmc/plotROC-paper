Source Files for "plotROC: A Better Tool for Plotting ROC Curves"
--------------------
Author: Michael C Sachs
====================
### Dependencies

- make
- R (3.1.2) and R packages
	+ knitr (1.8)
	+ plotROC (1.3)
	+ stringr (0.6.2)
	+ xtable (1.7-4)
	+ ggplot2 (1.0.0)
	+ DiagrammeR (0.3)
- pandoc (1.13.1)
- A latex distribution (eg. MikTex)

### Details

To recreate the manuscript, run `make sachs2014plotroc.pdf`. This command runs `knitr` on the .Rmd file, converts to .tex with pandoc, and then compiles the pdf using `pdflatex`. 

The pubmed query mentioned on page 3 can be found in the litreview folder, along with the dataset used for analysis. For questions or comments please email me at michael.sachs@nih.gov. 