#rtl
RTL_DIR = $(BUILD_DIR)/rtl
RTL_LIST = $(RTL_DIR)/filelist.f
ELABORATE_DIR = $(RTL_DIR)/elaborate
FIR_DIR = $(ELABORATE_DIR)/fir
MLIR_DIR = $(ELABORATE_DIR)/mlir
FIR_FILES = $(shell find $(abspath $(FIR_DIR)) -name "*.fir")
#tb
TB_RTL_DIR = $(TB_DIR)/build
TB_RTL_LIST = $(TB_RTL_DIR)/filelist.f
TB_ELABORATE_DIR = $(TB_RTL_DIR)/elaborate
TB_FIR_DIR = $(TB_ELABORATE_DIR)/fir
TB_MLIR_DIR = $(TB_ELABORATE_DIR)/mlir
TB_FIR_FILES = $(shell find $(abspath $(TB_FIR_DIR)) -name "*.fir")
#firtool options
FIRTOOL_OPTION = \
	-O=debug \
	--split-verilog \
	--preserve-values=all \
  --lowering-options=verifLabels,omitVersionComment,disallowLocalVariables,disallowPackedArrays,locationInfoStyle=wrapInAtSquareBracket \
  --strip-debug-info

.PHONY: config
config:
	mkdir -p $(CONFIG_DIR)
	mill -i elaborateRTL.runMain elaborate.Elaborate_$(DESIGN) config --width 32 --useAsyncReset true --target-dir config

.PHONY: fir
fir:
	mkdir -p $(FIR_DIR)
	mill -i elaborateRTL.runMain elaborate.Elaborate_$(DESIGN) design --target-dir $(FIR_DIR) --parameter ./config/$(DESIGN).json

.PHONY: verilog
verilog: fir
	$(call fir2rtl,$(FIR_DIR),$(FIR_FILES),$(MLIR_DIR),$(RTL_DIR))
	find $(RTL_DIR) -maxdepth 1 -name "*.sv" -type f -print > $(RTL_LIST)

.PHONY: tb-fir
tb-fir:
	mkdir -p $(TB_FIR_DIR)
	mill -i elaborateTB.runMain $(DESIGN)TestBenchMain design --target-dir $(TB_FIR_DIR) --parameter ./config/$(DESIGN)TestBench.json

.PHONY: tb-verilog
tb-verilog: tb-fir
	$(call fir2rtl,$(TB_FIR_DIR),$(TB_FIR_FILES),$(TB_MLIR_DIR),$(TB_RTL_DIR))
	find $(TB_RTL_DIR) -maxdepth 1 -name "*.sv" -type f -print > $(TB_RTL_LIST)

.PHONY: fpv-fir
fpv-fir:
	mkdir -p $(TB_FIR_DIR)
	mill -i elaborateTB.runMain $(DESIGN)FormalMain design --target-dir $(TB_FIR_DIR) --parameter ./config/$(DESIGN)Formal.json

.PHONY: fpv-verilog
fpv-verilog: fpv-fir
	$(call fir2rtl,$(TB_FIR_DIR),$(TB_FIR_FILES),$(TB_MLIR_DIR),$(TB_RTL_DIR))
	find $(TB_RTL_DIR) -name "*.sv" -type f -print > $(TB_RTL_LIST)

define fir2rtl
	mkdir -p $(3)
	for file in $(2); do \
    basename=$$(basename $$file .fir); \
    anno_file=$(1)/$$basename.anno.json; \
		firtool $(FIRTOOL_OPTION) \
			--annotation-file $$anno_file \
			$$file \
			--output-final-mlir=$(3)/$$basename.mlir \
			-o $(4); \
	done
endef

help:
	mill -i elaborateRTL.run --help

reformat:
	mill -i __.reformat

checkformat:
	mill -i __.checkFormat

bsp:
	mill -i mill.bsp.BSP/install

idea:
	mill -i mill.idea.GenIdea/idea

clean:
	-rm -rf $(BUILD_DIR)

clean-tb:
	-rm -rf $(TB_RTL_DIR)

clean-rtl:
	-rm -rf $(RTL_DIR)

.PHONY: test verilog help reformat checkformat clean