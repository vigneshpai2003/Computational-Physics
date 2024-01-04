all: build run process

include tools.mk

# source files for binaries
q0_SRC = 0.f90
q1_SRC = utils.f90 1.f90

# define linking of source files
$(eval $(call link,q0,$(q0_SRC)))
$(eval $(call link,q1,$(q1_SRC)))

# build binaries
build: $(BIN_DIR)/q0.$(BIN_EXT) $(BIN_DIR)/q1.$(BIN_EXT)

run:
	@echo "==> Running q0"
	@./$(BIN_DIR)/q0.$(BIN_EXT)
	@echo ""
	@echo "==> Running q1"
	@./$(BIN_DIR)/q1.$(BIN_EXT)
	@echo ""

process:
	@echo "==> Processing"
	@../venv/bin/python3 processing.py
	@echo ""
