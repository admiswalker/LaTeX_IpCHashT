#============================================================

# エントリーポイントを設定したファイル (処理の都合で拡張子は記入しない)
MAIN = main

# 追跡対象のファイル (変更されたときのみコンパイル)
SRCDIR = ./*.tex
BIBDIR = ./*.bib

FIGDIR = ./figs
FIGPNG = $(FIGDIR)/*.png
FIGPDF = $(FIGDIR)/*.pdf

doc_name      = algorism
PDFS_from_doc = $(FIGDIR)/$(doc_name).pdf
PDFS_cropped  = $(FIGDIR)/$(doc_name)_crop.pdf

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

$(TARGET): $(SRCS) $(XBBS) $(PDFS_cropped)
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

$(PDFS_from_doc):
	(cd ./$(FIGDIR); export HOME=/tmp; soffice --headless --convert-to pdf *.odp) # convert *.odp to *.pdf

$(PDFS_cropped): $(PDFS_from_doc)
	pdfcrop $< $(PDFS_cropped)
	$(EXTRACTBB) $(PDFS_cropped)

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
	-rm -f $(TARGET) ./*.log ./figs/*.xbb $(PDFS_from_doc) $(PDFS_cropped) ./.fuse_hidden*

