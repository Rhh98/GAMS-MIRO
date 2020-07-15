set L 'locations';

set coord 'Coordinates'/x,y/;
$onexternalInput
table LocInfo(L<,coord) Coordinates of locations
  x  y
1 36 20
2 23 30
3 23 56
4 10 15
5 5  5
;

Parameters

   d(L) Projected demand
   / 1 7
     2 3
     3 2
     4 4
     5 2 /

   s(L) Units currently assigned
   /  1 6
      2 2
      3 3
      4 3
      5 4 /;
$offExternalInput
alias(L,nL);
Parameter dist(L,nL) distance;
dist(L,nL) = sqrt( (LocInfo(nL,'x') - LocInfo(L,'x'))*(LocInfo(nL,'x') - LocInfo(L,'x')) + (LocInfo(nL,'y') - LocInfo(L,'y'))*(LocInfo(nL,'y') - LocInfo(L,'y')));

Scalar c cost per kilometer /100/;

Variable 
  obj;

Positive Variable 
  z(L,nL);

Equations
   objective 
   balance1(L)
   balance2(L);

objective.. sum((L,nL), dist(L,nL)*c*z(L,nL)) =e= obj;

balance1(L) .. sum(nL, z(nL,L)) + s(L) =g= d(L) + sum(nL, z(L,nL)) ;

balance2(L).. sum(nL, z(nL,L)) + s(L) =l= d(L) + sum(nL, z(L,nL)) ;

Model AirAmbulance1 /objective,balance1/ ;
Model AirAmbulance2 /objective,balance2/ ;
if (sum(L,s(L)) > sum(L,d(L)),  Solve AirAmbulance1 using lp minimizing obj;
else solve  AirAmbulance2 using lp minimizing obj);
set HeliHeader /old,new,demand/
assignHeader/x,y,value,tox,toy/;
$onExternalOutput
table assign(L,nL,assignHeader) Helicopters reassignment;
table  numofHeli(L,HeliHeader) Number of helicopters in L;
$offExternalOutput
assign(L,nL,'value')=z.l(L,nL);
assign(L,nL,'tox')=LocInfo(nL,'x');
assign(L,nL,'toy')=LocInfo(nL,'y');
assign(L,nL,'x')=LocInfo(L,'x');
assign(L,nL,'y')=LocInfo(L,'y');
numofHeli(L,'old')=s(L);
numofHeli(L,'demand')=d(L);
numofHeli(L,'new')=s(L)+sum(nL,z.l(nL,L))-sum(nL,z.L(L,nL));

