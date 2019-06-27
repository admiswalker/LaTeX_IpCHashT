#============================================================

# エントリーポイントを設定したファイル (処理の都合で拡張子は記入しない)
MAIN = main

# 追跡対象のファイル (変更されたときのみコンパイル)
SRCDIR = ./*.tex
BIBDIR = ./*.bib

FIGDIR = ./figs
FIGPNG = $(FIGDIR)/*.png
FIGPDF = $(FIGDIR)/*.pdf

#CROP_PDFS_name   = $(FIGDIR)/algorism
CROP_PDFS   = $(FIGDIR)/algorism.pdf
CROPed_PDFS = $(FIGDIR)/algorism_crop.pdf

TARGET = out.pdf

#============================================================

TEMPDIR   = tmpMake
STYLEFILE = jecon.bst

SRCS      = $(wildcard $(SRCDIR))
BIBS      = $(wildcard $(BIBDIR))

PDFS      = $(wildcard $(FIGPDF))
PNGS      = $(wildcard $(FIGPNG))
XBBS      = $(patsubst %.pdf, %.xbb, $(PDFS)) $(patsubst %.png, %.xbb, $(PNGS))

TEX       = uplatex
DVIPDFMX  = dvipdfmx
EXTRACTBB = extractbb
BIB       = pbibtex

$(TARGET): $(SRCS) $(XBBS) $(CROPed_PDFS)
	mkdir -p $(TEMPDIR)
	@echo -e "\n============================================================\n"
	@echo -e "SRCS: \n$(SRCS)\n"
	@echo -e "BIBS: \n$(BIBS)\n"
	@echo -e "XBBS: \n$(XBBS)"
	@echo -e "\n============================================================\n"
	(make makemain)
	cp -u $(STYLEFILE) ./$(TEMPDIR)
	cp -u $(BIBS) ./$(TEMPDIR)
	(cd $(TEMPDIR); $(BIB) -terse $(MAIN);)

	if egrep 'No file $(TEMPDIR)/$(MAIN).toc.' $(TEMPDIR)/$(MAIN).log;\
	then\
		(make makemain);\
	fi

	if egrep 'LaTeX Warning: There were undefined references.' $(TEMPDIR)/$(MAIN).log;\
	then\
		(make makemain);\
	fi

	if egrep 'There were undefined citations.' $(TEMPDIR)/$(MAIN).log;\
	then\
		(make makemain);\
	fi

	dvipdfmx -o $(TARGET) ./$(TEMPDIR)/$(MAIN)
	@echo ""

#$(CROPed_PDFS):
#	soffice --headless --convert-to pdf:writer_pdf_Export $(FIGDIR)/*.odp # convert *.odp to *.pdf
./figs/algorism.pdf:
	(cd ./$(FIGDIR); soffice --headless --convert-to pdf:writer_pdf_Export *.odp) # convert *.odp to *.pdf

$(CROPed_PDFS): ./figs/algorism.pdf
#	(cd ./$(FIGDIR); soffice --headless --convert-to pdf:writer_pdf_Export *.odp) # convert *.odp to *.pdf
	pdfcrop $< $(CROPed_PDFS)
	$(EXTRACTBB) $(CROPed_PDFS)

%.xbb: %.png
	$(EXTRACTBB) $<

%.xbb: %.pdf
	$(EXTRACTBB) $<

.PHONY: makemain
makemain:
	$(TEX) -output-directory=$(TEMPDIR) $(MAIN)

.PHONY: all
all:
	@(make clean)
	@(make)

.PHONY: clean
clean:
	-rm -rf $(TEMPDIR)
	-rm -f $(TARGET) ./*.log ./figs/*.xbb $(CROP_PDFS) $(CROPed_PDFS)

