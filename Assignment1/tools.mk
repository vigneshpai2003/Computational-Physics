# fortran compiler
FC = gfortran

# folder structure
OBJ_DIR = obj
SRC_DIR = src
BIN_DIR = bin
DATA_DIR = data

# extensions of compiled files
OBJ_EXT = obj
BIN_EXT = bin

# compile fortran files
$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.f90
	@echo "==> COMPILING $<"
	$(FC) -J$(OBJ_DIR) -o $@ -c $<
	@echo ""

# link fortran files
# $(1) is the name of the binary, $(2) is the files to be linked
define link
$(BIN_DIR)/$(1).$(BIN_EXT): $(patsubst %.f90,$(OBJ_DIR)/%.$(OBJ_EXT),$(2))
	@echo "==> LINKING $$^"
	$(FC) -o $$@ $$^
	@echo ""
endef

# remove compiled files and binaries
clean:
	@echo "==> CLEANING: removing objects and binaries"
	rm -f $(OBJ_DIR)/* $(BIN_DIR)/*
	@echo ""

# remove data generated
clean-data:
	@echo "==> CLEANING: removing data files"
	rm -f $(DATA_DIR)/*
	@echo ""

cleanall: clean clean-data
