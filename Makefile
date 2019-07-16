#============================================================

# エントリーポイントを設定したファイル (処理の都合で拡張子は記入しない)
MAIN = main

# 追跡対象のファイル (変更されたときのみコンパイル)
SRCDIR = ./*.tex
BIBDIR = ./*.bib

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

FIGS_ALGO = FORCE_FIGS_ALGO # Force to build every time using a blank name

$(TARGET): $(FIGS_ALGO) $(XBBS) $(SRCS)
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

$(FIGS_ALGO):
	@(cd ./figs_algo; make -j)

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
	-rm -f $(TEMPDIR)/.fuse_hidden*
	-rm -rf $(TEMPDIR)
	-rm -f $(TARGET) $(XBBS) ./*.log .fuse_hidden*
	@(cd ./figs_algo; make clean)

