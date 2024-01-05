all: build run process

include tools.mk

# folders for generated data
DATA_DIR = data
FIG_DIR = figures

myfolders:
	@mkdir -p $(DATA_DIR) $(FIG_DIR)

# source files for binaries
q0_SRC = 0.f90
q1_SRC = utils.f90 1.f90

# define linking of source files
$(eval $(call link,q0,$(q0_SRC)))
$(eval $(call link,q1,$(q1_SRC)))

# build binaries
build: $(BIN_DIR)/q0.$(BIN_EXT) $(BIN_DIR)/q1.$(BIN_EXT)

# run binaries
run: myfolders
	@echo "$(run-start) Running q0"
	@$(timer) ./$(BIN_DIR)/q0.$(BIN_EXT)
	$(newline)
	@echo "$(run-start) Running q1"
	@$(timer) ./$(BIN_DIR)/q1.$(BIN_EXT)
	$(newline)

# process the data with python
process: myfolders
	@echo "$(process-start) Processing"
	@../venv/bin/python3 processing.py
	$(newline)

### CLEANING

# remove data generated
clean-data:
	@echo "$(clean-start) CLEANING: removing data files"
	rm -f $(DATA_DIR)/*
	$(newline)

# remove figures generated
clean-figs:
	@echo "$(clean-start) CLEANING: removing figures"
	rm -f $(FIG_DIR)/*
	$(newline)

cleanall: clean clean-data clean-figs
