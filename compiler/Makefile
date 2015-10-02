DIRCROSSCOMPILER = src/cross-compiler
DIRPRECOMPILER = src/pre-compiler
DIRSIMULATOR = src/simulateur
SUBDIRS = $(DIRCROSSCOMPILER) $(DIRPRECOMPILER) $(DIRSIMULATOR)
#src/cross-compiler src/pre-compiler src/simulateur
.PHONY: subdirs $(SUBDIRS)

all: compileeverything

compileeverything: subdirs
	@mkdir -p bin
	@for dir in $(SUBDIRS); do \
		mv $$dir/*.elf bin/; \
	done

subdirs: $(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -C $@


clean:
	@for dir in $(SUBDIRS); do \
		$(MAKE) clean -C $$dir; \
	done

mrproper:
	@for dir in $(SUBDIRS); do \
		$(MAKE) clean -C $$dir; \
	done
	@rm -rf bin/

dumpROM:
	@xxd -u -c 4 -g 1 bin/prog.rom
