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
define link
$(BIN_DIR)/$(1).$(BIN_EXT): $(patsubst %.f90,$(OBJ_DIR)/%.$(OBJ_EXT),$(2))
	@echo "==> LINKING $$^"
	$(FC) -o $$@ $$^
	@echo ""
endef

# source files for binaries
q0_SRC = 0.f90
q1_SRC = utils.f90 1.f90

$(eval $(call link,q0,$(q0_SRC)))
$(eval $(call link,q1,$(q1_SRC)))

default: $(BIN_DIR)/q0.$(BIN_EXT) $(BIN_DIR)/q1.$(BIN_EXT)

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
