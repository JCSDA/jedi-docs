#/bin/bash

fig_list="
figure_ensemble_covariance
figure_saber_blocks_1
figure_saber_blocks_2
figure_static_covariance
figure_vertical_balance
"

for fig in $fig_list; do
   pdflatex $fig
   mogrify -format jpg -background white -alpha remove -density 500 -quality 100 -trim $fig.pdf   
   rm -f $fig.aux $fig.log $fig.pdf
done
