# MUSCA
This script analyzes Multiple Step Chronoamperometry data collected on a Biologic Potentiostat and outputs the calculated voltammograms at selected sweep rates in a text file.

Basic instructions
→ Put this script in the same folder as your MUSCA data (this script works for data obtained using CstV format on a Biologic(Brand) Potentiostat.)
→ Input the file name in line 6
→ Double chekc line 16 to make sure the data input has the correct number of columns and proper designation of integer and fraction numbers.
→ Check the sweep rates you wanted between line 57 and 64
→ A text filed named "Calculated Voltammograms.txt" will be generated that contains all the data.
