
# definition of directory
#
inputs-bias-dir = inputs/rawbias
inputs-galaxy-dir = inputs/rawgalaxy
outputs-bias-dir = outputs/masterbias
outputs-calimages-dir = outputs/calimages
 

# definition of data
#
inputs-bias = $(shell ls $(inputs-bias-dir)/r*.fits)
inputs-galaxy =$(shell ls $(inputs-galaxy-dir)/C*.fits)
#$(info $(inputs-galaxy))
#exit 1
outputs-bias = $(outputs-bias-dir)/masterbias.fits
basenames = $(foreach im, $(inputs-galaxy),$(notdir $(im)))
outputs-calimages = $(foreach b, $(basenames),$(outputs-calimages-dir)/$(b))

# Ultimate targets
#
all : $(outputs-calimages)


# Bulding Master Bias
#
$(outputs-bias-dir):; mkdir -p $@

$(outputs-bias): $(inputs-bias) | $(outputs-bias-dir)
	astarithmetic $^ 12 median -g0 -o$@


# Building correctgalaxy with bias
#
$(outputs-calimages-dir):; mkdir -p $@

$(outputs-calimages): $(outputs-calimages-dir)/%.fits: $(inputs-galaxy-dir)/%.fits $(outputs-bias) | $(outputs-calimages-dir)
	astarithmetic $< -h0 $(outputs-bias) -h1 - -o$@


