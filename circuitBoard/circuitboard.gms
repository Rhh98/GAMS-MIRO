$title circuitboad.gms 
$setglobal n 6
$ontext
See New York Times (Kousha Nejad, Sep 19, 2021)
Connect the points on the circuit board so that every point is connected to either one or three (never two) other points, and so that no areas are enclosed.  When you're done, all the points must be interconnected.

Do a visualization.
$offtext

option limrow=0, limcol=0, solprint = off;

$ontext
$setglobal n 5
set i /1*%n%/;

set initsoln(i,i,i,i) / 1.1.2.1,1.2.2.2,1.4.1.5,
			3.3.4.3,4.2.4.3,5.3.5.4 /;
set black(i,i) / 4.1, 5.1, 5.5 /;
$offtext

set i /1*%n%/;

$onExternalInput
* $ontext

set initsoln(i,i,i,i) / 1.1.2.1,1.2.2.2,1.3.2.3,1.4.1.5,
			2.1.2.2,2.2.2.3,2.5.3.5,2.6.3.6,
			3.2.4.2,3.3.4.3,3.3.3.4,3.4.3.5,
			4.1.4.2,6.4.6.5 / ;
set black(i,i) / 5.6, 6.6 /;
* $offtext
$offExternalInput

alias (i,j,k,l);
set nodes(i,j);
nodes(i,j) = not black(i,j);
set arcs(i,j,k,l);
loop((i,j)$nodes(i,j),
  arcs(i,j,i+1,j)$nodes(i+1,j) = yes;
  arcs(i,j,i,j+1)$nodes(i,j+1) = yes;
);
loop(initsoln(i,j,k,l),
  abort$(not arcs(initsoln)) "initsoln data not in arcs";
);
set squares(i,j);
loop(i$(not i.last),
  loop(j$(not j.last),
    squares(i,j)$(nodes(i,j) and nodes(i,j+1) and nodes(i+1,j) and nodes(i+1,j+1)) = yes;
  );
);

binary variables line(i,j,k,l);
variables totlines;
binary variables onethree(i,j);
equations degree(i,j), enclose(i,j),
	  connecti(i,j), connectj(i,j), cost;

degree(i,j)$(not black(i,j))..
  1 + 2*onethree(i,j) =e=
  line(i-1,j,i,j) + line(i,j-1,i,j) +
  line(i,j,i+1,j) + line(i,j,i,j+1);

enclose(i,j)$squares(i,j)..
  line(i,j,i+1,j) + line(i,j,i,j+1) + line(i+1,j,i+1,j+1) + line(i,j+1,i+1,j+1)
  =l= 3;

connecti(i,j)$(nodes(i,j) and nodes(i,j+1) and not j.last)..
  line(i,j,i,j+1) =l= onethree(i,j) + onethree(i,j+1); 

connectj(i,j)$(nodes(i,j) and nodes(i+1,j) and not i.last)..
  line(i,j,i+1,j) =l= onethree(i,j) + onethree(i+1,j); 

cost..
  totlines =e= sum(arcs, line(arcs));

model board /cost,degree,enclose,connecti,connectj/;
board.optcr = 0;
board.optca = 0.999;
board.reslim = 4000;
board.iterlim = 1000000000;

parameter soln(*,*);

line.fx(i,j,k,l)$initsoln(i,j,k,l) = 1;
line.fx(i,j,k,l)$(not arcs(i,j,k,l)) = 0;

solve board using mip max totlines;
option line:0:0:1; display line.l;
soln('simple','totlines') = totlines.l;

option soln:0:1:1; display soln;

set header /init,sol,blocked/;

$onexternaloutput

parameter output(i,j,k,l,header);

$offexternaloutput

output(i,j,k,l,'init')$initsoln(i,j,k,l) = 1;
output(i,j,k,l,'init')$(not arcs(i,j,k,l)) = 0;

output(i,j,k,l,'sol') = 0;
output(i,j,k,l,'sol')$( not initsoln(i,j,k,l) and  line.l(i,j,k,l) > 0.5) = 1;


output(i,j,k,l,'blocked') = 0;
output(i,j,'1','1','blocked')$black(i,j) = 1;
