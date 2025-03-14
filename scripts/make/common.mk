#
# Common Makefile
#

# BUILD_STEP: PROJECT=0, SYNTH=1, IMPL=2
BUILD_STEP:=2

default: help

vivado:
ifeq (,$(shell which vivado))
	$(error "Vivado was not found! Source environment to proceed.")
endif

help_full:
	@echo "To build the full bitstream and associated checkpoint:"
	@echo "    make full"

help_partial:
	@echo "To build a partial bitstream for a specific block design container:"
	@echo "    NOTE: you must first run 'make full' and/or have a checkpoint"
	@echo "    make partial BDC=<DFX block design container>"

help: help_full help_partial

full: vivado
	@echo "Launching Vivado build script..."
	@vivado -mode batch -source ../../scripts/tcl/full.tcl -tclargs ${BUILD_STEP} $(shell nproc)

partial: vivado
ifeq (, ${BDC})
	@make --no-print-directory help_partial
else
	@echo "Creating partition synth checkpoints..."
	@vivado -mode batch -source ../../scripts/tcl/partial_synth.tcl -tclargs ${BDC} $(shell nproc)
	@echo "Building partial bitstreams..."
	@vivado -mode batch -source ../../scripts/tcl/partial_impl.tcl
endif

cleanall:
	@echo "Cleaning project directory..."
	@rm -rf build hd_visual *.jou *.log *.rpt clockInfo.txt
