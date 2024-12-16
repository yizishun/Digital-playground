SIM_DIR = $(SCRIPTS_DIR)/sim
#-------------------simulator specific--------------
# verilator specific
VERILATOR_DIR = $(BUILD_DIR)/verilator
VERILATOR_FLAGS = --trace --timing -j 8 -O1 --build --exe -cc --top $(TOP) -Mdir $(VERILATOR_DIR) -CFLAGS -std=c++20
VERILATOR_BIN = $(VERILATOR_DIR)/V$(TOP)

VERILATOR_HOME = $(shell verilator --getenv VERILATOR_ROOT)
VERLATOR_INC = $(VERILATOR_HOME)/include

# vcs specific
VCS_DIR = $(BUILD_DIR)/vcs
VCS_FLAGS = -full64 -timescale=1ns/1ns -debug_access+all -l $(VCS_DIR)/vcs.log -o $(VCS_BIN) -sverilog +assert -Mdir=$(VCS_OBJDIR)
VCS_OBJDIR = $(VCS_DIR)/obj
VCS_BIN = $(VCS_DIR)/simv

# iverilog specific
IVERILOG_DIR = $(BUILD_DIR)/iverilog
IVERILOG_FLAGS =
IVERILOG_BIN =

# backend simulator(for default use)
# python have its own default backend simulator script
# verilator too
BACKENDSCP.python = $(SIM_DIR)/$(TBLANG)/$(SIM).mk
BACKENDSCP.verilator_uvm = $(SIM_DIR)/$(TBLANG)/$(SIM).mk
BACKENDSCP.default = $(SIM_DIR)/backend/$(SIM).mk

ifneq ($(BACKENDSCP.$(TBLANG)),)
  BACKENDSCP_PATH = $(BACKENDSCP.$(TBLANG))
else ifneq ($(BACKENDSCP.$(SIM)_$(TBLANG)),)
  BACKENDSCP_PATH = $(BACKENDSCP.$(SIM)_$(TBLANG))
else
  BACKENDSCP_PATH = $(BACKENDSCP.default)
endif

$(info SIM=$(SIM))
$(info TBLANG=$(TBLANG))
$(info BACKENDSCP_PATH=$(BACKENDSCP_PATH))
$(info LANGSCP_PATH=$(SIM_DIR)/$(TBLANG)/sim-$(TBLANG).mk)

include $(BACKENDSCP_PATH)


#ifeq ($(TBLANG), python)
#include $(SIM_DIR)/$(TBLANG)/$(SIM).mk
#else ifeq ($(and $(filter $(SIM), verilator), $(filter $(TBLANG), uvm)), 1)
#include $(SIM_DIR)/$(TBLANG)/$(SIM).mk
#else
#include $(SIM_DIR)/backend/$(SIM).mk
#endif

# language specific files
include $(SIM_DIR)/$(TBLANG)/sim-$(TBLANG).mk

# build dpi to .a
include $(SIM_DIR)/dpi.mk

LAYERS.verilator := Verification
LAYERS.vcs := Verification Verification/Assert Verification/Assume Verification/Cover
LAYERS.icarus := Verification

define collect_layer
$(shell find $(abspath $(1)) -maxdepth 1 -name "*.sv")
endef