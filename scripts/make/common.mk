#
# Common Makefile
#

# BUILD_STEP: PROJECT=0, SYNTH=1, IMPL=2
BUILD_STEP:=2

default: all

vivado:
ifeq (,$(shell which vivado))
	$(error "Vivado was not found! Source environment to proceed.")
endif

build: vivado
	@echo "Launching Vivado build script..."
	@vivado -mode batch -source ../../scripts/tcl/build.tcl -tclargs ${BUILD_STEP} $(shell nproc)

synth_partitions: vivado
	@echo "Creating partition synth checkpoints..."
	@vivado -mode batch -source ../../scripts/tcl/build.tcl -tclargs 1 $(shell nproc)

impl_partitions: vivado
	@echo "Building partial bitstreams..."
	@vivado -mode batch -source ../../scripts/tcl/build_partitions.tcl

clean:
	@echo "Cleaning project directory..."
	@rm -rf build hd_visual *.jou *.log *.rpt clockInfo.txt

all: build