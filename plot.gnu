set term png size 600,1000 font "/Library/Fonts/Microsoft/Calibri.ttf,15"
set datafile separator ",";
set xlabel "Re(y)"
set ylabel "Im(y)"
set xtic auto
set ytic auto
set xrange [-0.02:0.02]
set pointsize 5.0
set grid
plot 'out.dat' notitle with points 0 0
