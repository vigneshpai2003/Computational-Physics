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
tex-start = 📜
clean-start = 🔥

# folder structure
OBJ_DIR = obj
SRC_DIR = src
BIN_DIR = bin
TEX_DIR = tex

# extensions of compiled files
OBJ_EXT = o
BIN_EXT = bin

# usefull shortcuts
TIMER = /usr/bin/time --format="\n Executed in %e seconds with %P CPU"
MAKE_OUT_DIR = @mkdir -p $(@D)
NEWLINE = @echo "" 

### <<<

all: build run process latex

### BUILDING >>>

# compile fortran files
$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.f90
	@echo "$(compile-start)  COMPILING $(<F)"
	$(MAKE_OUT_DIR)
	$(FC) -J$(OBJ_DIR) -o $@ -c $<
	$(NEWLINE)

# link fortran files
# $(1) is the name of the binary, $(2) is the files to be linked
define link
$(BIN_DIR)/$(1).$(BIN_EXT): $(patsubst %.f90,$(OBJ_DIR)/%.$(OBJ_EXT),$(2))
	@echo "$(link-start)  LINKING $$(^F)"
	$$(MAKE_OUT_DIR)
	$(FC) -o $$@ $$^
	$(NEWLINE)
endef

### <<<

### LaTeX >>>

# compile latex
$(TEX_DIR)/%.pdf: $(TEX_DIR)/%.tex
	@echo "$(tex-start)  COMPILING LATEX $(^F)"
	@cd $(TEX_DIR) && \
	pdflatex $(^F) 1>/dev/null
	$(NEWLINE)

### <<<

### CLEANING >>>

# remove compiled files and binaries
clean-build:
	@echo "$(clean-start) CLEANING: removing objects and binaries"
	rm -rf $(OBJ_DIR) $(BIN_DIR)
	$(NEWLINE)

# remove latex objects
clean-latex:
	@echo "$(clean-start) CLEANING: removing latex objects"
	rm -f $(TEX_DIR)/*.pdf $(TEX_DIR)/*.aux $(TEX_DIR)/*.fdb_latexmk $(TEX_DIR)/*.fls $(TEX_DIR)/*.log $(TEX_DIR)/*.gz
	$(NEWLINE)

clean: clean-build myclean # myclean is defined in settings

### <<<

include settings.mk
