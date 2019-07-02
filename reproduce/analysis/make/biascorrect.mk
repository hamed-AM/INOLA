#  bias correction
#
# Copyright (C)  2019  Hamed Alafi (hamed.altafi2@gmail.com)
#
# This Makefile is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This Makefile is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.






# Input definitions
bc-bias-indir = $(INDIR)/bias_B
bc-light-indir = $(INDIR)/light_B
bc-bias-in = $(shell ls $(bc-bias-indir)/r_b_*.fits)
bc-light-in =$(shell ls $(bc-light-indir)/CCDB-*.fits)
# $(info $(bc-light-in))






# Bulding Master Bias
bc-bias-dir = $(BDIR)/bias
bc-bias = $(bc-bias-dir)/masterbias.fits
$(bc-bias-dir):; mkdir -p $@
$(bc-bias): $(bc-bias-in) | $(bc-bias-dir)
	astarithmetic $^ 2 mean -g0 -o$@





# Building correctgalaxy with bias
basenames = $(foreach im, $(bc-light-in),$(notdir $(im)))
bc-light = $(foreach b, $(basenames),$(bc-light-dir)/$(b))
$(info $(basename))
bc-light-dir = $(bc-bias-dir)/corrected
$(bc-light-dir):; mkdir -p $@
$(bc-light): $(bc-light-dir)/%.fits: $(bc-light-indir)/%.fits \
             $(bc-bias) | $(bc-light-dir)
	astarithmetic $< -h0 $(bc-bias) -h1 - -o$@





# Final tex file for this specific make file
$(mtexdir)/biascorrect.tex: $(bc-light) | $(mtexdir)

	touch $@
