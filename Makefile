
all: forthed.frt

FORTH_SRC = block-and-file-support.frt block-edit.frt cli.frt ed.frt file-edit.frt line-reader.frt list.frt number-list.frt range-parser.frt str-buff.frt txt-list.frt utils.frt

IO_TARGET ?= files

ifeq ($(IO_TARGET), files)
	IO_TEMPLATE_LINE = file-edit.frt
else ifeq ($(IO_TARGET), blocks)
	IO_TEMPLATE_LINE = block-edit.frt
else ifeq ($(IO_TARGET), both)
	IO_TEMPLATE_LINE = block-and-file-support.frt
else
$(error "Invalid value for IO_TARGET. Valid values are 'files', 'blocks', or 'both'.")
endif

template.frt :
	printf "\\ #IR ed.frt\n\\ #IR %s\n\\ #IR cli.frt\n" "$(IO_TEMPLATE_LINE)" > $@

forthed.frt : template.frt $(FORTH_SRC)
	preforth $< $@

clean :
	rm -f forced.frt template.frt

