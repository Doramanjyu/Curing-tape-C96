#!/bin/sh

input="dt-general-\*.dat is-pavement-\*.dat ss-pavement-\*.dat"


tmpdata=$(mktemp)

n=0
for t in $input
do
  is=$(eval eval ls -1 $t)
  for i in $is
  do
    stat=$(echo "stat \"$i\" u 2:3" | gnuplot 2>&1 | sed -e "s/^ *//;s/ \+/ /g;s/\[\s*/[/g")
    max=$(echo "$stat" | grep "Maximum:" | cut -f4 -d" ")
    echo $n $max $t >> $tmpdata
  done
  n=$(expr $n + 1)
done

cat <<EOF | gnuplot -p
set xrange [-0.5:$n-0.5]
set yrange [0:*]
set ylabel "Force [kgf]"
set grid
plot "$tmpdata" u 1:2:xticlabels(3) w p notitle pt 2

set term postscript enhanced
set output "plot.eps"
replot

set term qt
replot
EOF
