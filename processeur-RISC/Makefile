################################
# Makefile for ghdl simulation #
################################

# project name
PROJECT = global
PLATFORM = digilent-nexys3
PART = xc6slx16-3-csg324

SIMDIR = simu
SRCDIR = src
TESTBENCHDIR = testbench

# VHDL files
TESTBENCH_FILE= $(PROJECT)_tb.vhd
LIBRARY_FILE = #testbench/apf_test_pkg.vhd
SYNTHESIS_FILE= $(PROJECT)_synthesis.vhd
PLACE_AND_ROUTE_FILE= $(PROJECT)_timesim.vhd
FILES = $(SRCDIR)/global.vhd \
	$(SRCDIR)/ALU_Impl.vhd \
	$(SRCDIR)/ALU.vhd \
	$(SRCDIR)/dataMemory.vhd \
	$(SRCDIR)/decoder7Seg.vhd \
	$(SRCDIR)/frequencyDivisor.vhd \
	$(SRCDIR)/sevenSegments.vhd \
	$(SRCDIR)/instructionsMemory.vhd \
	$(SRCDIR)/registres.vhd

# testbench
SIMTOP =$(PROJECT)_tb
# Simu break condition
#GHDL_SIM_OPT    = --assert-level=error
GHDL_SIM_OPT	= --stop-time=10000ns

# pin configuration
UCF_FILE = mapping.ucf

#synthesis constraints file
XCF_FILE =

##############################
# GHDL options
##############################
# -P Add DIRECTORY to the end of the list of directories to be searched for library files. 

GHDL_CMD = ghdl
VIEW_CMD = gtkwave

GHDL_SIMU_FLAGS      = --std=93c --ieee=mentor --ieee=synopsys --vital-checks --warn-binding --warn-reserved --warn-library --warn-vital-generic --warn-delayed-checks --warn-body --warn-specs --warn-unused --warn-error
GHDL_SYNTHESIS_FLAGS = --ieee=synopsys -P$$XILINX/vhdl/src/unisims  --warn-no-vital-generic
GHDL_PANDR_FLAGS     = --ieee=synopsys -P$$XILINX/vhdl/src/simprims  --warn-no-vital-generic

OBJS_FILES      = $(patsubst %.vhd, %.o, $(notdir $(FILES)) )
#OBJS_SIMFILES   = $(patsubst %.vhd, %.o, $(notdir $(SIMFILES)) )

SMARTGUIDE =
USAGE_DEPTH = 0

##########################################
# Synthèse VHDL et génération du bitstream
##########################################

synthesis:
	@mkdir -p synthesis
	@ls src/*.vhd | sed -r 's/[a-zA-Z0-9_]*\/([a-zA-Z0-9_]*\.vhd)/vhdl work \1/' > synthesis/${PROJECT}.prj
	@echo "set -tmpdir \"xst/projnav.tmp\"" > synthesis/${PLATFORM}.xst
	@echo "set -xsthdpdir \"xst\"" >> synthesis/${PLATFORM}.xst
	@echo "run" >> synthesis/${PLATFORM}.xst
	@echo "-ifn ${PROJECT}.prj" >> synthesis/${PLATFORM}.xst
	@echo "-ofn ${PROJECT}" >> synthesis/${PLATFORM}.xst
	@echo "-ofmt NGC" >> synthesis/${PLATFORM}.xst
	@echo "-p $(PART)" >> synthesis/${PLATFORM}.xst
	@echo "-top ${PROJECT}" >> synthesis/${PLATFORM}.xst
	@echo "-opt_mode Speed" >> synthesis/${PLATFORM}.xst
	@echo "-opt_level 1" >> synthesis/${PLATFORM}.xst
	@echo "-power NO" >> synthesis/${PLATFORM}.xst
	@echo "-iuc NO" >> synthesis/${PLATFORM}.xst
	@echo "-keep_hierarchy No" >> synthesis/${PLATFORM}.xst
	@echo "-netlist_hierarchy As_Optimized" >> synthesis/${PLATFORM}.xst
	@echo "-rtlview Yes" >> synthesis/${PLATFORM}.xst
	@echo "-glob_opt AllClockNets" >> synthesis/${PLATFORM}.xst
	@echo "-read_cores YES" >> synthesis/${PLATFORM}.xst
	@echo "-write_timing_constraints NO" >> synthesis/${PLATFORM}.xst
	@echo "-cross_clock_analysis NO" >> synthesis/${PLATFORM}.xst
	@echo "-hierarchy_separator /" >> synthesis/${PLATFORM}.xst
	@echo "-bus_delimiter <>" >> synthesis/${PLATFORM}.xst
	@echo "-case Maintain" >> synthesis/${PLATFORM}.xst
	@echo "-slice_utilization_ratio 100" >> synthesis/${PLATFORM}.xst
	@echo "-bram_utilization_ratio 100" >> synthesis/${PLATFORM}.xst
	@echo "-dsp_utilization_ratio 100" >> synthesis/${PLATFORM}.xst
	@echo "-lc Auto" >> synthesis/${PLATFORM}.xst
	@echo "-reduce_control_sets Auto" >> synthesis/${PLATFORM}.xst
	@echo "-fsm_extract YES -fsm_encoding Auto" >> synthesis/${PLATFORM}.xst
	@echo "-safe_implementation No" >> synthesis/${PLATFORM}.xst
	@echo "-fsm_style LUT" >> synthesis/${PLATFORM}.xst
	@echo "-ram_extract Yes" >> synthesis/${PLATFORM}.xst
	@echo "-ram_style Auto" >> synthesis/${PLATFORM}.xst
	@echo "-rom_extract Yes" >> synthesis/${PLATFORM}.xst
	@echo "-shreg_extract YES" >> synthesis/${PLATFORM}.xst
	@echo "-rom_style Auto" >> synthesis/${PLATFORM}.xst
	@echo "-auto_bram_packing NO" >> synthesis/${PLATFORM}.xst
	@echo "-resource_sharing YES" >> synthesis/${PLATFORM}.xst
	@echo "-async_to_sync NO" >> synthesis/${PLATFORM}.xst
	@echo "-shreg_min_size 2" >> synthesis/${PLATFORM}.xst
	@echo "-use_dsp48 Auto" >> synthesis/${PLATFORM}.xst
	@echo "-iobuf YES" >> synthesis/${PLATFORM}.xst
	@echo "-max_fanout 100000" >> synthesis/${PLATFORM}.xst
	@echo "-bufg 16" >> synthesis/${PLATFORM}.xst
	@echo "-register_duplication YES" >> synthesis/${PLATFORM}.xst
	@echo "-register_balancing No" >> synthesis/${PLATFORM}.xst
	@echo "-optimize_primitives NO" >> synthesis/${PLATFORM}.xst
	@echo "-use_clock_enable Auto" >> synthesis/${PLATFORM}.xst
	@echo "-use_sync_set Auto" >> synthesis/${PLATFORM}.xst
	@echo "-use_sync_reset Auto" >> synthesis/${PLATFORM}.xst
	@echo "-iob Auto" >> synthesis/${PLATFORM}.xst
	@echo "-equivalent_register_removal YES" >> synthesis/${PLATFORM}.xst
	@echo "-slice_utilization_ratio_maxmargin 5" >> synthesis/${PLATFORM}.xst
	@cp ${SRCDIR}/*.vhd synthesis/
	@cp ${SRCDIR}/*.ucf synthesis/
	@mkdir -p synthesis/xst/projnav.tmp
	cd synthesis && xst -intstyle ise -ifn ${PLATFORM}.xst -ofn ${PROJECT}.syr

mapAndRoute: synthesis
	cd synthesis && ngdbuild -uc mapping.ucf ${PROJECT}.ngc \
	&& map $(SMARTGUIDE) -w ${PROJECT}.ngd && par -ol high -w ${PROJECT}.ncd ${PROJECT}-routed.ncd \
	&& par $(SMARTGUIDE) -ol high -w ${PROJECT}.ncd ${PROJECT}-routed.ncd

bitstream: mapAndRoute
	cd synthesis && bitgen -w ${PROJECT}-routed.ncd ${PROJECT}.bit

xdlanalyze: bitstream
	cd synthesis && promgen -u 0 $(PROJECT) && \
	xdl -ncd2xdl $(PROJECT)-routed.ncd $(PROJECT)-routed.xdl && \
	trce -v 10 $(PROJECT)-routed.ncd $(PROJECT).pcf && \
	../xdlanalyze.pl $(PROJECT)-routed.xdl $(USAGE_DEPTH)

load:
	impact -batch impact_script

########################
# Simulation with GHDL
########################

help:
	@echo 'Cleaning:'
	@echo '  clean      - delete simulation directory'
	@echo
	@echo 'simulate:'
	@echo '  ghdl-simu      - make behavioural simulation'
	@echo '  ghdl-synthesis - make post synthesis simulation'
	@echo '  ghdl-pr        - make post place and route simulation'
	@echo ' '
	@echo 'view result:'
	@echo '  ghdl-view      - Launch wave view with gtk-waves'

ghdl-simu : ghdl-compil ghdl-run
ghdl-synthesis : ghdl-compil-synthesis ghdl-run
ghdl-pr : ghdl-compil-pr ghdl-run


#$(GHDL_CMD) -i $(GHDL_SIMU_FLAGS) --workdir=$(SIMDIR) --work=work $(TESTBENCHDIR)/$(TESTBENCH_FILE) $(TESTBENCHDIR)/$(LIBRARY_FILE) $(FILES)
ghdl-compil : $(TESTBENCHDIR)/$(TESTBENCH_FILE) $(FILES)
	mkdir -p $(SIMDIR)
	$(GHDL_CMD) -i $(GHDL_SIMU_FLAGS) --workdir=$(SIMDIR) --work=work $(TESTBENCHDIR)/$(TESTBENCH_FILE) $(FILES)
	$(GHDL_CMD) -e $(GHDL_SIMU_FLAGS) --workdir=$(SIMDIR) --work=work $(SIMTOP)
	mv $(SIMTOP) $(SIMDIR)/$(SIMTOP)

ghdl-compil-synthesis:
	@if [ ! -e $(SYNTHESIS_FILE) ] ; then\
		echo "You have to copy $(SYNTHESIS_FILE), in this directory first" ;\
		[ -e $(SYNTHESIS_FILE) ];\
	fi;
	mkdir -p $(SIMDIR)
	$(GHDL_CMD) -i $(GHDL_SYNTHESIS_FLAGS) --workdir=$(SIMDIR) --work=work $(TESTBENCHDIR)/$(TESTBENCH_FILE) $(TESTBENCHDIR)/$(LIBRARY_FILE) $(SYNTHESIS_FILE)
	$(GHDL_CMD) -m $(GHDL_SYNTHESIS_FLAGS) --workdir=$(SIMDIR) --work=work $(SIMTOP)
	@mv $(SIMTOP) $(SIMDIR)/$(SIMTOP)

ghdl-compil-pr :
	@if [ ! -e $(PLACE_AND_ROUTE_FILE) ] ; then\
		echo "You have to copy $(PLACE_AND_ROUTE_FILE), in this directory first" ;\
		[ -e $(PLACE_AND_ROUTE_FILE) ];\
	fi;
	mkdir -p $(SIMDIR)
	$(GHDL_CMD) -i $(GHDL_PANDR_FLAGS) --workdir=$(SIMDIR) --work=work $(TESTBENCHDIR)/$(TESTBENCH_FILE) $(TESTBENCHDIR)/$(LIBRARY_FILE) $(PLACE_AND_ROUTE_FILE)
	$(GHDL_CMD) -m $(GHDL_PANDR_FLAGS) --workdir=$(SIMDIR) --work=work $(SIMTOP)
	@mv $(SIMTOP) $(SIMDIR)/$(SIMTOP)

ghdl-run :
	@$(SIMDIR)/$(SIMTOP) $(GHDL_SIM_OPT) --vcdgz=$(SIMDIR)/$(SIMTOP).vcdgz

ghdl-view:
	gunzip --stdout $(SIMDIR)/$(SIMTOP).vcdgz | $(VIEW_CMD) --vcd

ghdl-clean :
	$(GHDL_CMD) --clean --workdir=$(SIMDIR)
	@rm -rf $(SIMDIR)


simulation:
	@mkdir -p simulation results
	ghdl -i $(GHDL_SIMU_FLAGS) --workdir=simulation --work=work $(TESTBENCHDIR)/$(TESTBENCH_FILE) src/*.vhd
	ghdl -m $(GHDL_SIMU_FLAGS) --workdir=simulation --work=work ${PROJECT}_tb
	mv ${PROJECT}_tb simulation
	./simulation/${PROJECT}_tb $(GHDL_SIM_OPT) --vcd=simulation/${MODULE}_tb.vcd

clean: FORCE
	rm -rf synthesis simulation results _impactbatch.log *~

FORCE: