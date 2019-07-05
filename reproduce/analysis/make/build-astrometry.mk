# Make the astrometry
#
# This Makefile does the astrometry of the images using `solve-field'
# routine. The result of the `solve-field' rule are WCS-SIP headers, that
# is, WCS information with distorsion coefficients in SIP convention. Once
# the astrometry has been obtained, WCS-SIP headers are transformed into
# WCS-PV headers with the help of a Python script and `sip_tpv' package.
# Both WCS-SIP and WCS-PV headers are saved in separate folders. Finally,
# WCS-SIP headers are injected into the original (non-astometrized) images
# in order to be able to continue the processing. The decision of inject
# WCS-SIP and not the WCS-PV is because WCS-SIP headers are more widely used
# nowadays.  WCS-PV are only requested to be able to run `swarp'. Because of
# that, WCS-PV headers will be only considered in the resampling step: just
# before resampling each image, WCS-PV header is injected.
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
ca-indir   = $(BDIR)/lightcorrected
ca-outdir  = $(BDIR)/build-astrometry
sip-outdir = $(BDIR)/wcs-sip-headers
pv-outdir  = $(BDIR)/wcs-pv-headers




# Obtain the astrometry with `solve-field'
# ----------------------------------------
#
# Blind astrometry of each image is obtained by using `solve-field' program.
# It is part of `astrometry-net' software. Here I give some of the
# parameters while others are taken from the configuration parameters. Once
# the astrometry has been solved, temporal files generated are removed. Only
# WCS-SIP headers are obtained with this recipe, all other files are
# removed.
ca-astrometry-cfg = $(BDIR)/astrometry-catalogues/astrometry.cfg
sip-headers = $(foreach ca-bname, $(basenames), $(sip-outdir)/$(ca-bname))
$(sip-outdir):; mkdir $@
$(sip-headers): $(sip-outdir)/%.fits: $(ca-indir)/%.fits | $(sip-outdir)
       	# Run `solve-field' for obtaining blind astrometry
	solve-field $<                                         \
                    --scale-low 2.7 --scale-high 2.9 --scale-units arcsecperpix  \
                    --overwrite                                \
		    --extension 1                              \
                    --dir $(sip-outdir)                        \
		    --config $(ca-astrometry-cfg)              \
		    --wcs $@
# $(SOLVE-FIELD-PARAMS)                      \ # config file to put parameters - commented. we didn't find the approriated file so decided to import parameters here

	# Delete temporal files created by `solve-field'
	rm $(subst .fits,.axy,$@)
	rm $(subst .fits,.corr,$@)
	rm $(subst .fits,-indx.xyls,$@)
	rm $(subst .fits,.match,$@)
	rm $(subst .fits,.new,$@)
	rm $(subst .fits,.rdls,$@)
	rm $(subst .fits,.solved,$@)





# SIP to PV distorsion coefficients conversion
# --------------------------------------------
#
# Distorsion coefficients obtained by `solve-field' program are expressed in
# SIP convention. However, `swarp' only understand PV distorsion
# coefficients when resampling images. Due to that, it is necessary to
# transform SIP distorsion coefficients to PV coefficients. To do that, a
# Python script is used. For each WCS header with SIP parameters, transform
# them into PV coefficients, then save that header in a separate folder.
pv-headers = $(foreach ca-bname, $(visual-good-astr-bnames), $(pv-outdir)/$(ca-bname))
pysiptpv = $(pythondir)/sip_to_tpv.py
$(pv-outdir):; mkdir $@
$(pv-headers): $(pv-outdir)/%.fits: $(sip-outdir)/%.fits | $(pv-outdir)
	# Convert SIP to PV
	python $(pysiptpv) $< 0 $@





# Inject the WCS-SIP header into the image
# ----------------------------------------
#
# Obtained WCS-SIP headers are injected into the original and non
# astrometrized images. I only inject WCS-SIP headers because they are more
# general and most used nowadays. WCS-PV headers will be used only just
# before the resampling process with `swarp'.
ca-astr-ims = $(foreach ca-bname, $(basenames), $(ca-outdir)/$(ca-bname))
$(ca-outdir): ; mkdir $@
$(ca-astr-ims): $(ca-outdir)/%.fits: $(ca-indir)/%.fits \
                                     $(sip-outdir)/%.fits \
                                     | $(ca-outdir)
	# Inject into the input (non-astrometrized) image, the WCS-SIP header.
	astarithmetic $< --wcsfile=$(word 2,$^) --wcshdu=0 --output=$@





# Final TeX macro
# ---------------
#
# Make an empty .tex file as final file when the astrometry has been
# completed for all images.
$(mtexdir)/build-astrometry.tex: $(sip-headers) $(ca-astr-ims) | $(mtexdir)
	touch $@


#### note: we deleted this from Final Tex Macro: $(pv-headers)  \
