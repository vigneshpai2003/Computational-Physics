### This file must define the following targets
# build
# run
# process
# latex
# latex-dependencies

# source files for binaries
q0_SRC = 0.f90
q1_SRC = utils.f90 1.f90

DATA_DIR = data
FIG_DIR = figures

latex-dependencies = $(wildcard $(FIG_DIR)/*.png)

# define linking of source files
$(eval $(call link,q0,$(q0_SRC)))
$(eval $(call link,q1,$(q1_SRC)))

# build binaries
build: $(BIN_DIR)/q0.$(BIN_EXT) $(BIN_DIR)/q1.$(BIN_EXT)

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

latex: $(TEX_DIR)/submission.pdf

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

# override default clean
clean: clean-data clean-figs
