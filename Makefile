.PHONY: init

BRDIR=buildroot-2019.08.1
BOARD=orangepi_zero_custom
BR2EXT=br2ext
PATCHED_PACKAGES=tcf-agent-1.7.0
OUT_DIR=output

PATCH_PREFIX=$(BR2EXT)/board/$(BOARD)/patches/
PATCH_POSTFIX=-0-add_board_support.patch
PATCHES=$(foreach patch, $(PATCHED_PACKAGES),  $(PATCH_PREFIX)$(shell echo $(patch) | sed -e 's/-.*$$//')/$(patch)$(PATCH_POSTFIX))
HG_REV?=$(shell hg parents --template '{rev}')
HG_BRANCH?=$(shell hg parents --template '{branch}')
ARCHIVE_NAME=$(BR2EXT)-$(BOARD)-r$(HG_REV)
ARCHIVE_FILES=$(BR2EXT) Makefile ChangeLog .hg .hgignore readme

all:  $(OUT_DIR)/.config $(BRDIR)/Makefile
	$(MAKE) -C $(OUT_DIR)

init: $(BRDIR)/.config
	@echo "!!! Now we can use buildroot in $(BRDIR) like usually (make menuconfig; make;...) !!!"

$(BRDIR).tar.bz2:
	@wget https://buildroot.org/downloads/$@

$(BRDIR)/Makefile: $(BRDIR)

$(BRDIR): $(BRDIR).tar.bz2
	@echo EXTRACT   $<
	@tar -jxf $<
	@touch $(BRDIR)
#	@patch -d $(BRDIR) -p1 < patches/valgrind.patch

$(OUT_DIR)/.config: $(BRDIR)/Makefile
	$(MAKE) BR2_EXTERNAL='../$(BR2EXT)' O='../$(OUT_DIR)' -C $(BRDIR) $(BOARD)_defconfig

patches: $(PATCHES)

define patch_template =
 $(1): $$(notdir $$(subst $(PATCH_POSTFIX), , $(1)))  $$(notdir $$(subst $(PATCH_POSTFIX), , $(1)))-orig
endef

$(foreach patch, $(PATCHES), $(eval $(call patch_template, $(patch))))

%.patch:
	@echo DIFF	$@
	@diff -purN --no-dereference $<-orig $< > $@; [ $$? -eq 1 ] || (echo rm -f $@; exit -1)

release:
	-hg log --style=changelog > ChangeLog
	-rm -f $(ARCHIVE_NAME).tar.bz2
	tar -cjf $(ARCHIVE_NAME).tar.bz2 $(ARCHIVE_FILES)

release-7z:
	-hg log --style=changelog > ChangeLog
	-rm -f $(ARCHIVE_NAME).tar.7z
	tar cf - $(ARCHIVE_FILES) | 7z a -si -mx=9 -myx=9 $(ARCHIVE_NAME).tar.7z
