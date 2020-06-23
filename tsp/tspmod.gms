$ontext
TSP with Pataki modifications
$offtext
set city /  Atlanta,Chicago,Denver,Houston,LosAngeles,Madison,Miami,NewYork,SanFrancisco,Seattle,WashingtonDC /;
alias(city,i,j,k);

table      dist(i,j)      "distances"
            Atlanta Chicago   Denver Houston LosAngeles Madison Miami NewYork SanFrancisco Seattle WashingtonDC
Atlanta      0       587     1212    701       1936       700    604     748      2139       2182     543
Chicago      587      0      920     940       1745       122   1188     713      1858       1737     597
Denver       1212     920     0      879        831       839   1726    1631       949       1021    1494
Houston      701     940     879      0        1372       978    968    1420      1645       1891    1220
LosAngeles   1936    1745    831     1374        0        1670  2339    2451       347        959    2300
Madison      700     122     839      978      1670        0    1303     808       1764      1618     706
Miami        604    1188    1726     968       2339       1303    0      1092      2594       2734    923
NewYork      748     713    1631     1420      2451        808  1092     0        2571       2408    205
SanFrancisco 2139   1858    949     1645       347        1764  2594    2571        0         678    2442
Seattle      2182    1737   1021    1891       959        1618  2734    2408       678         0     2329
WashingtonDC  543    597    1494    1220      2300         706   923      205      2442        2329    0 ;

binary variables x(i,j);
free variable obj;
positive variables u(i) ;

equations defobj, assign1(j), assign2(i), mtz(i,j);;

defobj..
obj =e= sum((i,j), dist(i,j) * x(i,j));

assign1(j)..
sum(i$(not sameas(i,j)), x(i,j)) =e= 1;

assign2(i)..
sum(j$(not sameas(i,j)), x(i,j)) =e= 1;

mtz(i,j)$(ord(i) ne 1 and ord(j) ne 1)..
  u(i) - u(j) + 1 =L= (card(i) - 1) * (1 - x(i,j)) ;

model tsp /defobj, assign1, assign2, mtz/;

x.fx(i,i) = 0;
u.lo(i) = 2; u.up(i) = card(i);
u.fx(i)$(i.ord eq 1) = 1;

option optcr = 0;
solve tsp using mip minimizing obj ;
display obj.l;

set tour(i,i) ;
* Just print the tour in a simple way
option tour:0:0:1 ;

tour(i,j) = no;
tour(i,j)$(x.l(i,j) > 0.01) = yes ;
display tour;
display u.L;