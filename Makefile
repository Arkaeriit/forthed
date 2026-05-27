
all: forthed.frt

FORTH_SRC = ed.frt block-edit.frt file-edit.frt list.frt number-list.frt range-parser.frt str-buff.frt str-buff.frt txt-list.frt utils.frt cli.frt

IO_TARGET ?= files

ifeq ($(IO_TARGET), files)
	IO_TEMPLATE_LINE = file-edit.frt
else ifeq ($(IO_TARGET), blocks)
	IO_TEMPLATE_LINE = block-edit.frt
else
$(error "Invalid value for IO_TARGET. Valid values are 'files' and 'blocks'.")
endif

template.frt :
	printf "\\ #IR ed.frt\n\\ #IR %s\n\\ #IR cli.frt\n" "$(IO_TEMPLATE_LINE)" > $@

forthed.frt : template.frt $(FORTH_SRC)
	preforth $< $@

clean :
	rm -f forced.frt template.frt

