# Download Gaia DR2 data
#
# This script downloads data from Gaia 2 source table for a given region of the sky.
# WEB: https://astroquery.readthedocs.io/en/latest/gaia/gaia.html
#
# Original author:
#     Raul Infante-Sainz <infantesainz@gmail.com>
# Contributing author(s):
# Copyright (C) 2019, Raul Infante-Sainz.
#
# This Python script is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This Python script is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details. See <http://www.gnu.org/licenses/>.




# ------
# USAGE:
# ------
# python3 download-gaia2-catalogue.py RA  DEC  dRA  dDEC  cat_name
#
# PARAMETERS:
# -----------
# RA		=   float         =   RA coordinates in deg
# DEC		=   float         =   DEC coordinates in deg
# dRA		=   float         =   Delta RA coordinate, a square of side=2*dRA will be searched
# dDEC          =   float         =   Delta DEC coordinate, a square of side=2*dDEC will be searched
# cat_name      =   str		  =   Output catalogue name with all objects found
# ----------------------------------------------------------------------------------------------------


# Import modules
import sys
from astroquery.gaia import Gaia


# Define the input parameters
tablename_all = 'gaiadr2.gaia_source'
t = Gaia.load_table(tablename_all)
ra = float(sys.argv[1])
dec = float(sys.argv[2])
d_ra = float(sys.argv[3])
d_dec = float(sys.argv[4])
cat_name = sys.argv[5]


# Define the searching area of sources
ra_min = str(ra - d_ra)
ra_max = str(ra + d_ra)
dec_min = str(dec - d_dec)
dec_max = str(dec + d_dec)


# SQL string type
query_all = (' select                  '  +
             '        ra, dec,         '  +
             '        phot_g_mean_mag  '  +
             ' from  ' + tablename_all    +
             ' where '                    +
             '        ra  > ' + ra_min    +
             ' and    ra  < ' + ra_max    +
             ' and    dec > ' + dec_min   +
             ' and    dec < ' + dec_max )


# Lunch the SQL petition and get the data
job = Gaia.launch_job_async(query_all)
table = job.get_data()


# Save the data as .fits table
table.write(cat_name, format='fits', overwrite=True)




# -------------------------------------------------------
# For a more general usage of this script look at
# the lines below, they contain information of interest.
# Uncomment lines for use them
# -------------------------------------------------------
"""
tables = Gaia.load_tables(only_names=True)
for table in (tables):
    print(table.get_qualified_name())



for column in (t.get_columns()):
    name = column.get_name()
    print(name)


query_all1 = (' select ' +
          '       source_id, '         +
         '        ra, dec, '          +
         '        pmra,pmra_error, pmdec, pmdec_error, '      +
         '        phot_g_mean_mag,  ' +
         '        phot_bp_mean_mag, ' +
         '        phot_rp_mean_mag,  ' +
         '        radial_velocity, '   +
         '        duplicated_source, ' +
         '        frame_rotator_object_type, ' +
         '        parallax ' +
         ' from ' + tablename_all         +
         ' where ' +
         '        ra  > ' + ra_min  +
         ' and    ra  < ' + ra_max  +
         ' and    dec > ' + dec_min +
         ' and    dec < ' + dec_max )#+
         ' and    phot_g_mean_mag < ' + '7' )
"""
