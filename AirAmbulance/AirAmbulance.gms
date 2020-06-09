set L ;


$onexternalInput
Parameters
   x(L<) x-coordinates
   / 1 36
     2 23
     3 23
     4 10
     5 5   /

   y(L) y-coordinates
   / 1 20
     2 30
     3 56
     4 15
     5 5  /

   d(L) projected demand
   / 1 7
     2 3
     3 2
     4 4
     5 2 /

   s(L) units currently assigned
   /  1 6
      2 2
      3 3
      4 3
      5 4 /;
$offExternalInput
alias(L,nL);
Parameter dist(L,nL) distance;
dist(L,nL) = sqrt( (x(nL) - x(L))*(x(nL) - x(L)) + (y(nL) - y(L))*(y(nL) - y(L)));

Scalar c cost per kilometer /100/;

Variable 
  obj;

Positive Variable 
  z(L,nL);

Equations
   objective 
   balance(L)  ;

objective.. sum((L,nL), dist(L,nL)*c*z(L,nL)) =e= obj;

balance(L) .. sum(nL, z(nL,L)) + s(L) =e= d(L) + sum(nL, z(L,nL)) ;

Model AirAmbulance /all/ ;
Solve AirAmbulance using lp minimizing obj;
set HeliHeader /old,new/
assignHeader/x,y,value/;
$onExternalOutput
table assign(L,nL,assignHeader) helicoptpers assignment;
table  numofHeli(L,HeliHeader) number of helicopters in L;
$offExternalOutput
assign(L,nL,'value')=z.l(L,nL);
assign(L,nL,'x')=x(nL);
assign(L,nL,'y')=y(nL);
numofHeli(L,'old')=s(L);
numofHeli(L,'new')=s(L)+sum(nL,z.l(nL,L))-sum(nL,z.L(L,nL));
