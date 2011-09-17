set terminal png
set datafile separator ",";
set xlabel "Re(y)"
set ylabel "Im(y)"
set xtic auto
set ytic auto
set xrange [-0.02:0.02]
set pointsize 5.0
set grid
plot 'out.dat' title 'Symplectic maps' with points 0 0
