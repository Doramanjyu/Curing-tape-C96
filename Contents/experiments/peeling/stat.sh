#!/bin/sh

input="dt-general-0h.dat dt-general-12h.dat is-pavement-0h.dat is-pavement-12h.dat ss-pavement-0h.dat ss-pavement-12h.dat"

tmpdata=$(mktemp)

n=0
echo \# file mean stddev q1 median q2 >> $tmpdata
for i in $input
do
  stat=$(echo "stat \"$i\" u 2:3" | gnuplot 2>&1 | sed -e "s/^ *//;s/ \+/ /g;s/\[\s*/[/g")
  mean=$(echo "$stat" | grep "Mean:" | cut -f3 -d" ")
  sd=$(echo "$stat" | grep "Std Dev:" | cut -f3 -d" ")
  median=$(echo "$stat" | grep "Median:" | cut -f3 -d" ")
  q1=$(echo "$stat" | grep "Quartile:" | head -n1 | cut -f3 -d" ")
  q3=$(echo "$stat" | grep "Quartile:" | tail -n1 | cut -f3 -d" ")
  min=$(echo "$stat" | grep "Minimum:" | cut -f4 -d" ")
  max=$(echo "$stat" | grep "Maximum:" | cut -f4 -d" ")
  echo $n $q1 $min $max $q3 $median $i >> $tmpdata
  points="$points, \"$i\" u ($n):3 w p pt 7 notitle"
  n=$(expr $n + 1)
done

cat <<EOF | gnuplot -p
set xrange [-0.5:$n-0.5]
set yrange [0:*]
set ylabel "Force [kgf]"
set grid
plot "$tmpdata" u 1:2:2:5:5:(0.4):xticlabels(7) w candlesticks notitle whiskerbars, \
  "" u 1:6:6:6:6:(0.4) w candlesticks lt -1 notitle \
  $points

set term postscript enhanced
set output "plot.eps"
replot

set term qt
replot
EOF
