# fortran compiler
FC = gfortran

# timing
timer = /usr/bin/time --format="\n Executed in %e seconds"

# colors
reset = \e[0m
black = \e[;30m
red = \e[;31m
green = \e[;32m
yellow = \e[;33m
blue = \e[;34m
magenta = \e[;35m
cyan = \e[;36m
white = \e[;37m

newline = @echo "" 

run-start = $(green)▶$(reset)
process-start = 🌊
compile-start = 🛠️
link-start = ⛓️
clean-start = 🔥

# folder structure
OBJ_DIR = obj
SRC_DIR = src
BIN_DIR = bin

# extensions of compiled files
OBJ_EXT = o
BIN_EXT = bin

# make required folders
build-folders:
	@mkdir -p ${OBJ_DIR} ${BIN_DIR}

# compile fortran files
$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.f90 build-folders
	@echo "$(compile-start)  COMPILING $<"
	$(FC) -J$(OBJ_DIR) -o $@ -c $<
	$(newline)

# link fortran files
# $(1) is the name of the binary, $(2) is the files to be linked
define link
$(BIN_DIR)/$(1).$(BIN_EXT): $(patsubst %.f90,$(OBJ_DIR)/%.$(OBJ_EXT),$(2))
	@echo "$(link-start)  LINKING $$^"
	$(FC) -o $$@ $$^
	$(newline)
endef

# remove compiled files and binaries
clean:
	@echo "$(clean-start) CLEANING: removing objects and binaries"
	rm -f $(OBJ_DIR)/* $(BIN_DIR)/*
	$(newline)