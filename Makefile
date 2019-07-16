#============================================================

# エントリーポイントを設定したファイル (処理の都合で拡張子は記入しない)
MAIN = main

# 追跡対象のファイル (変更されたときのみコンパイル)
SRCDIR = ./*.tex
BIBDIR = ./*.bib

FIGDIR_doc     = ./figs_algo
doc_name       = algorism
PDFS_from_doc  = $(FIGDIR_doc)/$(doc_name).pdf
PDFS_cropped   = $(FIGDIR_doc)/$(doc_name)_crop.pdf
PDFS_separated = $(FIGDIR_doc)/$(doc_name)_crop_\%02d.pdf

FIGDIR = ./figs $(FIGDIR_doc)
FIGPNG = $(FIGDIR)/*.png
FIGPDF = $(FIGDIR)/*.pdf

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

$(TARGET): $(PDFS_cropped) $(XBBS) $(SRCS)
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

$(PDFS_from_doc): $(FIGDIR_doc)/$(doc_name).odg
	(cd ./$(FIGDIR_doc); export HOME=/tmp; soffice --headless --convert-to pdf *.odg) # convert *.odp to *.pdf

$(PDFS_cropped): $(PDFS_from_doc)
	-rm -f $(FIGDIR_doc)/$(doc_name)_crop_*.xbb
	pdfcrop $< $(PDFS_cropped)
	pdfseparate $(PDFS_cropped) $(PDFS_separated)

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
	@(make -j)

.PHONY: clean
clean:
	-rm -rf $(TEMPDIR)
	-rm -f $(TARGET) ./*.log ./figs/*.xbb ./.fuse_hidden* \
	$(FIGDIR_doc)/*.pdf $(FIGDIR_doc)/*.xbb

