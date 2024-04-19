.PHONY: clean
ALL: $(sources)
	pdflatex -shell-escape paper.tex
	bibtex paper
	pdflatex -shell-escape paper.tex
	pdflatex -shell-escape paper.tex

clean:
	@rm paper.aux paper.bbl paper.blg paper.log paper.upa paper.out
