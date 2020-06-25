* Facility Layout Optimization

Option optcr=0.01;
Option Optca=0;

Set Machines /CNC, Mill, Drill, Punch/;
Set Products /P1,P2,P3/;

Alias(Machines,m1,m2);


*Initial Co-ordinates of Machines
set coord /X,Y/
    RS recieving and shipping /R,S/;
$onexternalInput
table Mcoord(machines,coord)
      X    Y
CNC   100  200
Drill 200  100
Mill  300  100
Punch 100  300;

* Co-ordinates of Shipping and Receiving
table RScoord(RS,coord)
   X    Y
R  500  125
S  715  450;

*Minimum Distance
Parameter 
  Min_Distance(Machines,Machines) /
   CNC.Mill 50, 
   CNC.Drill 50, 
   CNC.Punch 50  
/;

*Costing Data
Parameters CM(Machines) /set.Machines 300/, CH(Products) /set.Products 100/;
$offexternalInput
Set Arcs(Products, Machines, Machines);
Arcs('P1','CNC', 'Drill')=yes;
Arcs('P1','Drill', 'Punch')=yes;
Arcs('P2','Mill', 'Drill')=yes;
Arcs('P2','Drill', 'Punch')=yes;
Arcs('P3','CNC', 'Drill')=yes;
Arcs('P3','Drill', 'Mill')=yes;
Arcs('P3','Mill', 'Punch')=yes;
*Area for Machine movement restriction
set lucoord /Xlow,Xup,Ylow,Yup/;
$onExternalInput
table LowUpCoord(Machines,lucoord) "lower and upper bound of the co-coordinats of machines"
       Xlow    Xup  Ylow  Yup
CNC    155     300  100   300
Drill  100     300  100   300
Punch  221     300  100   293 
Mill   100     228  100   300
;
$offExternalInput

*Initial Distance Matrix
Parameter Distances(Machines,Machines);
alias(m1,m2,Machines);
Distances(m1,m2)=sqrt(sqr(Mcoord(m1,'X')-Mcoord(m2,'X'))+  sqr(Mcoord(m1,'Y')-Mcoord(m2,'Y')));

free variable cost;
variable X_new(Machines), Y_new(Machines);

Equations
Objective,
Min_Dist(Machines,Machines);

Objective..
cost =E= sum(Machines,CM(Machines)*sqrt(sqr(X_new(Machines)-Mcoord(Machines,'X'))+  sqr(Y_new(Machines)-Mcoord(Machines,'Y'))))
       + sum((Products,m1,m2)$Arcs(Products,m1,m2), CH(Products)*(sqrt(sqr(X_new(m1)-X_new(m2))+  sqr(Y_new(m1)-Y_new(m2)))- sqrt(sqr(Mcoord(m1,'X')-Mcoord(m2,'X'))+  sqr(Mcoord(m1,'Y')-Mcoord(m2,'Y')))))
       + (CH('P1')+CH('P3'))*(sqrt(sqr(X_new('CNC')-RScoord('R','X'))+ sqr(Y_new('CNC')-RScoord('R','Y')))-sqrt(sqr(Mcoord('CNC','X')-RScoord('R','X'))+ sqr(Mcoord('CNC','Y')-RScoord('R','Y')))) + CH('P2')*(sqrt(sqr(X_new('Mill')-RScoord('R','X'))+
       sqr(Y_new('Mill')-RScoord('R','Y')))-sqrt(sqr(Mcoord('Mill','X')-RScoord('R','X'))+ sqr(Mcoord('Mill','y')-RScoord('R','Y'))))
       + (CH('P1')+CH('P2')+CH('P3'))*(sqrt(sqr(X_new('Punch')-RScoord('S','X'))+ sqr(Y_new('Punch')-RScoord('S','Y')))-sqrt(sqr(Mcoord('Punch','X')-RScoord('S','X'))+ sqr(Mcoord('Punch','Y')-RScoord('S','Y'))));

Min_Dist(m1,m2)$(ord(m1) <> ord(m2))..
sqrt(sqr(X_new(m1)-X_new(m2))+  sqr(Y_new(m1)-Y_new(m2))) =G= Min_Distance(m1,m2)+30;

model Facility_Layout /all/;

option nlp=baron;
Facility_Layout.optcr = 1e-4;

X_new.lo(Machines) = LowUpcoord(Machines,'xlow');
Y_new.lo(Machines) = LowUpcoord(Machines,'ylow');
X_new.up(Machines) = LowUpcoord(Machines,'xup');
Y_new.up(Machines) = LowUpcoord(Machines,'yup');

solve Facility_Layout using nlp minimizing cost;
Set resultHeader /x,y,newx,newy,CH,CM,XR,YR,XS,YS,status/;

$onExternalOutput
table result(machines,products,resultHeader);
$offexternaloutput

result(machines,products,'newx')=x_new.l(Machines);
result(machines,products,'newy')=y_new.l(Machines);
result(machines,products,'x')=mcoord(Machines,'x');
result(machines,products,'y')=mcoord(Machines,'y');
result(machines,products,'CH')=CH(products);
result(machines,products,'CM')=CM(machines);
result(machines,products,'XR')=RScoord('R','X');
result(machines,products,'XS')=RScoord('S','X');
result(machines,products,'YR')=RScoord('R','Y');
result(machines,products,'YS')=RScoord('S','Y');
result(machines,products,'status')=Facility_Layout.suminfes+1;



