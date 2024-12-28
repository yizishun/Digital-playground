BOARD ?= HDU-XL
PRJ ?= myproject

fpga:
	make -C $(SYN_DIR)/fpga BOARD=$(BOARD) PRJ=$(PRJ) DESIGN=$(DESIGN)
