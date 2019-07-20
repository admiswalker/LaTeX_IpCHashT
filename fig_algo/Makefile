#============================================================

doc_name       = algorism
PDFS_from_doc  = ./$(doc_name).pdf
PDFS_cropped   = ./$(doc_name)_crop.pdf
PDFS_separated = ./$(doc_name)_crop_\%02d.pdf

#============================================================

XBB     = extractbb
XBB_ext = ./*.pdf # extension

$(PDFS_cropped): $(PDFS_from_doc)
	-rm -f ./$(doc_name)_crop_*.xbb
	pdfcrop $< $(PDFS_cropped)
	pdfseparate $(PDFS_cropped) $(PDFS_separated)
	@(for s in grep $(XBB_ext); do $(XBB) $$s; done)

$(PDFS_from_doc): ./$(doc_name).odg
	(export HOME=/tmp; soffice --headless --convert-to pdf *.odg) # convert *.odp to *.pdf

.PHONY: clean
clean:
	-rm -f ./*.pdf ./*.xbb

