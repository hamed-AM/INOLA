# Devide light frames by flat filed image
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






# Bulding 
fd-light-dir = $(BDIR)/lightcorrected
fd-light = $(foreach b, $(basenames),$(fd-light-dir)/$(b))
$(fd-light-dir):; mkdir -p $@
$(fd-light): $(fd-light-dir)/%.fits: $(bc-light-dir)/%.fits \
             $(fc-flat) | $(fd-light-dir)
	astarithmetic $< -h1 $(fc-flat) -h1 / -o$@




# Final tex file for this specific make file
$(mtexdir)/flat-devide.tex: $(fd-light) | $(mtexdir)

	touch $@
