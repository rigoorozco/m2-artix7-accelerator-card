#
# Common Makefile
#

PROJECT_ONLY:=0

default: all

vivado:
ifeq (,$(shell which vivado))
	$(error "Vivado was not found! Source environment to proceed.")
endif

build: vivado
	@echo "Launching Vivado build scripts..."
	@vivado -mode batch -source ../../scripts/tcl/build.tcl -tclargs ${PROJECT_ONLY}

clean:
	@echo "Cleaning project directory..."
	@rm -rf temp_project *.jou *.log *.rpt

all: build