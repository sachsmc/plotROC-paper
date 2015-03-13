
%.md: %.Rmd
	Rscript -e "library(methods); library(knitr); knit('$<')" 
	
%.R: %.Rmd
	Rscript -e "library(methods); library(knitr); knit('$<', tangle = TRUE)" 
	
%.tex:	%.md
	pandoc --to latex --from markdown+raw_tex+simple_tables+table_captions+yaml_metadata_block -s -S --no-highlight --latex-engine=pdflatex --template=jss.latex --natbib -o $@ $<
 
%.pdf:	%.tex
	pdflatex $(basename $<)
	bibtex $(basename $<)
	pdflatex $(basename $<)
	pdflatex $(basename $<)
	rm -f *.aux *.bcf *.blg *.log *.out

clean:
	rm -f *.pdf *.tex *.aux *.bcf *.blg *.log *.out *.bbl
	
reknit:
	rm -f *.md