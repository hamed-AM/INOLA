# Create flat field image
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
f-indir = $(bc-light-dir)
f-tmpdir = $(BDIR)/build-flat
f-outdir = $(BDIR)/calibration-images
f-img-in = $(shell ls $(f-indir)/*.fits)
$(info $(f-img-in))






# Noisechisel for obtaining object masks
# Create detection images in temporal directory


$(b-tmpdir): ; mkdir $@
$(b-det-ims): $(b-tmpdir)/%_.fits: \
              $(b-indir)/%_fits    \
              $ (b-astnoisechisel-conf) | $(b-tmpdir)
	astnoisechisel $< --hdu=1 --output=$@ --config=$(f-astnoisechisel-conf)

















# Final tex file for this specific make file
$(mtexdir)/flat.tex: | $(mtexdir)

	touch $@
