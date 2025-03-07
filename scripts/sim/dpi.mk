# cpp -> a -------------------------
CSRCS = $(shell find $(TB_DIR)/dpi -name "*.cpp")
OBJS = $(CSRCS:.cpp=.o)  # 将所有 .cpp 文件替换为对应的 .o 文件
LIBC_A = $(TB_DIR)/dpi/dpi-lib.a
CXXFLAGS = -std=c++11 -fPIC -O2 \
	-I$(DEP_DIR)/json/include \
	-I$(TB_DIR)/dpi/include \
	-I$(VERLATOR_INC) \
	-DCONFIG_FILE='"$(CONFIG_DIR)/$(DESIGN)TestBench.json"'

.PHONY: dpi-lib
dpi-lib: $(LIBC_A)
$(LIBC_A): $(OBJS)
	@echo "+ $@"
	ar rcs $@ $^
	rm -f $(OBJS)

%.o: %.cpp
	@echo "+ $< -> $@"
	g++ $(CXXFLAGS) -c $< -o $@

.PHONY: cleanlib
cleanlib:
	rm -f $(LIBC_A)
