### GLOBAL VARIABLES >>>

# fortran compiler
FC = gfortran

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

# usefull shortcuts
TIMER = /usr/bin/time --format="\n Executed in %e seconds with %P CPU"
MAKE_OUT_DIR = @mkdir -p $(@D)
NEWLINE = @echo "" 

### <<<

all: build run process

### BUILDING >>>

# compile fortran files
$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.f90
	@echo "$(compile-start)  COMPILING $<"
	$(MAKE_OUT_DIR)
	$(FC) -J$(OBJ_DIR) -o $@ -c $<
	$(NEWLINE)

# link fortran files
# $(1) is the name of the binary, $(2) is the files to be linked
define link
$(BIN_DIR)/$(1).$(BIN_EXT): $(patsubst %.f90,$(OBJ_DIR)/%.$(OBJ_EXT),$(2))
	@echo "$(link-start)  LINKING $$^"
	$$(MAKE_OUT_DIR)
	$(FC) -o $$@ $$^
	$(NEWLINE)
endef

### <<<

### CLEANING >>>

# remove compiled files and binaries
clean-build:
	@echo "$(clean-start) CLEANING: removing objects and binaries"
	rm -rf $(OBJ_DIR) $(BIN_DIR)
	$(NEWLINE)

clean: clean-build myclean # myclean is defined in settings

### <<<

include settings.mk
