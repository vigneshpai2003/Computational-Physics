### This file must define the following targets
# build
# run
# process
# myclean

# source files for binaries
q0_SRC = 0.f90
q1_SRC = utils.f90 1.f90

# define linking of source files
$(eval $(call link,q0,$(q0_SRC)))
$(eval $(call link,q1,$(q1_SRC)))

# build binaries
build: $(BIN_DIR)/q0.$(BIN_EXT) $(BIN_DIR)/q1.$(BIN_EXT)

DATA_DIR = data
FIG_DIR = figures

# run binaries
run:
	@mkdir -p $(DATA_DIR)
	@echo "$(run-start) Running q0"
	@$(TIMER) ./$(BIN_DIR)/q0.$(BIN_EXT)
	$(NEWLINE)
	@echo "$(run-start) Running q1"
	@$(TIMER) ./$(BIN_DIR)/q1.$(BIN_EXT)
	$(NEWLINE)

# process the data with python
process:
	@mkdir -p $(FIG_DIR)
	@echo "$(process-start) Processing"
	@$(TIMER) ../venv/bin/python3 processing.py
	$(NEWLINE)

# remove data generated
clean-data:
	@echo "$(clean-start) CLEANING: removing data files"
	rm -rf $(DATA_DIR)
	$(NEWLINE)

# remove figures generated
clean-figs:
	@echo "$(clean-start) CLEANING: removing figures"
	rm -rf $(FIG_DIR)
	$(NEWLINE)

myclean: clean-data clean-figs
