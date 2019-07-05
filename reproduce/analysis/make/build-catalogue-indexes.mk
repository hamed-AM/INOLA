# Download catalogues and build the indexes for making the astrometry
#
# To obtain the astrometry of the images `astrometry-net' software is used.
# This software makes blind astrometry of astronomical images, but some
# preparation is needed. The preparation consists in split the reference
# catalogue (Gaia DR2) into multiple indexes that the routine `solve-field'
# can read.
#
# This Makefile does this job. First, it downloads the Gaia DR2 catalogue
# corresponding to the region of M101 using a Python script and then, it
# generates the indexes.  Finally, a configuration file for `solve-field' is
# generated. This configuration contains the path where the generated
# indexes are placed.
#
# Original author:
#     Raul Infante-Sainz <infantesainz@gmail.com>
# Contributing author(s):
# Copyright (C) 2019, Raul Infante-Sainz.
#
# This Makefile is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This Makefile is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details. See <http://www.gnu.org/licenses/>.




# Directories
# -----------
#
bci-outdir = $(BDIR)/astrometry-catalogues





# Download Gaia DR2 catalogue for each object
# -------------------------------------------
#
# Download one catalogue for each object.  The catalogue information needed
# is read from the configuration Makefile with the name of the object. It
# contains the RA DEC coordinates and the RAwidth DECwidth size on the sky
# (all in degrees). Using this information, these catalogues are downloaded
# using a Python script.
bci-catalogues = $(foreach bci-obj, M101galaxy, $(bci-outdir)/$(bci-obj)-gaia-dr2-catalogue.fits)
$(bci-outdir):; mkdir $@
$(bci-catalogues): $(bci-outdir)/%-gaia-dr2-catalogue.fits: \
                   reproduce/analysis/python/download-gaia2-catalogue.py | $(bci-outdir)

	# Read: RA DEC and RAwidth DECwidth
	# This line is passed as argument to `python' script
	#radecparams=$$(cat $<)

	# Download the catalogue
	python reproduce/analysis/python/download-gaia2-catalogue.py 210.802267 54.348950 2.0 2.0 $@





# Build the indexes
# -----------------
#
# Function to define the recipe and build the indexes, three arguments:
#     Target: index name
#     Prerequisit: catalogue with all stars previously downloaded
#     Index number: number for making the index
define BINDEX
$(1): $(2)
	build-astrometry-index -i $$< -e1 -o $$@ -P $$$(3) -S phot_g_mean_mag -E -A RA -D DEC
endef





# Define the index file names. They will be read by `solve-field'.
# First loop correspond to the different objects considered.
# Second loop is for make indexes from -5 to 6, they correspond to
# different sizes on the sky.
bci-indexes = $(foreach bci-catalogue, $(bci-catalogues),          \
               $(foreach bci-i, $(shell seq -5 6),                 \
                 $(subst .fits,_$(bci-i).index,$(bci-catalogue))  ))

# Build the indexes by calling the function inside two loops:
# Foreach object and foreach index number, generate the index.
# The function has three arguments:
#     Target: index name
#     Prerequisit: catalogue with all stars previously downloaded
#     Index number: number for making the index
$(foreach bci-obj, M101galaxy,                                                       \
 $(foreach bci-i, $(shell seq -5 6),                                                 \
  $(eval                                                                             \
   $(call BINDEX,                                                                    \
    $(subst .fits,_$(bci-i).index,$(bci-outdir)/$(bci-obj)-gaia-dr2-catalogue.fits), \
    $(bci-outdir)/$(bci-obj)-gaia-dr2-catalogue.fits,                                \
    $(bci-i)                                                                      ))))





# Create the configuration file for `solve-field'
# -----------------------------------------------
#
# This configuration file is the final target of the current script.
# It is the configuration file that `solve-field' will read when doing the
# astrometry of the images. It is specified the following information:
#     Run in parallel
#     Time limit for using the
#     Path where the indexes are
#     Use autoindex
$(bci-outdir)/astrometry.cfg: $(bci-indexes)
	# New lines introduced by \n
	echo -e "inparallel\ncpulimit 300\nadd_path $(bci-outdir)\nautoindex" > $@





# Final TeX macro
# ---------------
#
# Make an empty .tex file as final file when the configuration filefor
# `solve-field' has been generated.
$(mtexdir)/build-catalogue-indexes.tex: $(bci-outdir)/astrometry.cfg | $(mtexdir)
	touch $@


