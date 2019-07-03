# Creating flat field image with masking by noisechisel.
#
# Copyright (C) 2019 Zahra Sharbaf <samaeh.sharbaf2@yahoo.com>
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



#detected images with noisechisel 

fc-detection-dir = $(BDIR)/flat
fc-detection = $(foreach b,$(basenames),$(fc-detection-dir)/$(b))
fc-astnoisechisel-conf = reproduce/analysis/config/astnoisechisel-flat.conf
$(fc-detection-dir): ; mkdir -p $@
$(fc-detection): $(fc-detection-dir)/%.fits: $(bc-light-dir)/%.fits $(fc-astnoisechisel-conf)| $(fc-detection-dir)
	astnoisechisel $< --hdu=1 --output=$@ --config=$(fc-astnoisechisel-conf)





#masked images by outputs of noisechisel,detected images
fc-mask-dir = $(BDIR)/mask
fc-mask = $(foreach b,$(basenames),$(fc-mask-dir)/$(b))
$(fc-mask-dir):; mkdir -p $@
$(fc-mask) : $(fc-mask-dir)/%.fits: $(bc-light-dir)/%.fits \
		     $(fc-detection-dir)/%.fits | $(fc-mask-dir) 
	astarithmetic $< -h1 $(word 2, $^) -h2 1 eq nan where -o$@





#Normalize masked images
fc-normal-mask-dir = $(BDIR)/normal
fc-normal-mask = $(foreach b,$(basenames),$(fc-normal-mask-dir)/$(b))
$(fc-normal-mask-dir):; mkdir -p $@	
$(fc-normal-mask): $(fc-normal-mask-dir)/%.fits: $(fc-mask-dir)/%.fits | $(fc-normal-mask-dir)
	vmedian=$$(aststatistics $< -h1 --median)
	astarithmetic $< -h1 $$vmedian / -o$@




fc-flat-dir = $(BDIR)/finalflat
fc-flat = $(fc-flat-dir)/final-flat.fits
$(fc-flat-dir):; mkdir -p $@
$(fc-flat): $(fc-normal-mask) | $(fc-flat-dir)
	astarithmetic $^ 9 median -g1 -o$@





#final tex file for this make file
$(mtexdir)/flat-creat.tex: $(fc-flat) | $(mtexdir)
	touch $@
