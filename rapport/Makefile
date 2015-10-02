REPORTNAME=compte-rendu-archimat-gayraud-longo.pdf

TEX=main.tex

PDF=$(TEX:.tex=.pdf)
AUX=$(TEX:.tex=.aux)
LOG=$(TEX:.tex=.log)
OUT=$(TEX:.tex=.out)
TOC=$(TEX:.tex=.toc)
LOF=$(TEX:.tex=.lof)
LOT=$(TEX:.tex=.lot)

all: $(REPORTNAME)

$(REPORTNAME): $(PDF)
	-mv $^ $@

%.pdf: %.tex
	pdflatex -shell-escape $<
	pdflatex -shell-escape $<

clean:
	-rm -f $(PDF) $(AUX) $(PDF) $(LOG) $(OUT) $(TOC) $(LOF) $(LOT) *~

mrproper: clean
	-rm $(REPORTNAME)

read:
	-evince $(PDF) &

.PHONY: clean
