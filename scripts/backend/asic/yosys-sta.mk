YOSYS_DIR := $(SYN_DIR)/asic/yosys-sta

sta:
	make -C $(YOSYS_DIR) sta \
		DESIGN=$(DESIGN) \
		RTL_FILES="$(shell find $(RTL_DIR) -maxdepth 1 -name '*.sv')"