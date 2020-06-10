$title airplane

$ontext
airplane network model with nodes for 1 to 1300 for 100 miles by 12,000 feet
split nodes as (ht in thousand feet)*100 + nautical miles

some errors in offset due to missing out 4000 feet data
$offtext

sets
    CandN /1*1299,start,finish,c1,c2,c3/
   Nodes(CandN) /1*1299,start,finish/
   N(nodes) /1*1299/
   Arcs(nodes,nodes)
   clouds(CandN) /c1*c3/
;

parameters
  c(Nodes, Nodes)
  xcoord(Nodes)
  zcoord(Nodes)
  b(Nodes);

set cloudInf /xc 'x coordinate', low 'lower bound of the cloud', high 'higher bound of the cloud'/
height /2 ,4 ,6 ,8 ,10 ,12/
upheight(height)/2 ,4, 6, 8, 10/
downheight(height)/4,6,8,10,12/;
scalar  Groundheight /0/;
set s singular set /1/;
$onExternalInput
parameter cloudsInfo(clouds,cloudInf) Information of thunderstorm
/c1.xc 21,c2.xc 71,c3.xc 72,c1.low 3,c2.low 6, c3.low 6,c1.high 8, c2*c3.high 12/;
parameter
crcost(height) cost to cruise /2 1.36, 4 1.34,6 1.31, 8 1.29,10 1.27,12 1.25/
climbDis(upheight) nautical distance to climb 2k feet /2 5, 4 5,6 6,8 7, 10 10/
upcost(upheight) cost of going up 2k feet at 'upheight' /2 10.2,4 11.42, 6 13.42, 8 17.23,10 19.7/
downcost(downheight) cost of going down 2k feet at 'downheight' /4 12.3, 6 12.5, 8 12.4, 10 12.2, 12 11.8/;
;
parameter
 minheight /200/

*this is how far about crusing decisions are made at and costs above should same distance in offsetcr
  offsetcr(s) cruise distance /1 1/

  descendDis(s) nautical distance to descend 2k feet /1 10/;

$offExternalInput
*min height of the aircraft (height in thousand of feet)*length of x e.g. 2,000 feet and 100 miles is 2*100=200

parameter
  xcoordcloud(clouds) horizontal position of clouds  /c1 21,c2 71,c3 72/
  lowcloud(clouds) height of bottom of the cloud (100 feet) /c1 3, c2 6, c3 6/
  highcloud(clouds) height of top of the cloud (100 feet) /c1 8, c2 12, c3 12/
  ;
  xcoordcloud(clouds)=cloudsInfo(clouds,'xc');
  lowcloud(clouds)=cloudsInfo(clouds,'low');
  highcloud(clouds)=cloudsInfo(clouds,'high');
parameter
*up numbers
  
*this is addition to node that occurs for rise of 2000 feet and forward travel of 6 nautical miles node addn = 2*100 + 6 = 206 
  offsetup(upheight) how far does it take to go up 2000 feet in nautical miles insert as in 2*length(x)+ distance in nautical miles  
*down numbers
 
*this is addition to node that occurs for drop of 2000 feet and forward travel of 10 nautical miles node addn = -2*100 + 10 = -190
  offsetdown how far does it takes to go down 2000 feet in nautical miles insert as 2*length(x) - distance in nautical miles 
  ;
 offsetup(upheight)=2*100+climbDis(upheight);
  offsetdown=-2*100+descendDis('1');
alias(Nodes,I,J);
alias(N, N1, N2);

*set up parameters for xcoord and y coord
xcoord(Nodes) = mod(ord(Nodes), 100);
zcoord(Nodes) = Groundheight + floor( (ord(Nodes)-1)/100)

display xcoord;
display zcoord;

*set up arcs below

* Put arcs from start to first nodes @ free cost
Arcs('start','801')=yes;
c('start','801')=0;

* Put arc from last node to finish @ free cost
Arcs('899','finish')=yes;
C('finish','899')=0;

*Put arcs for cruise @ cost crcost
Arcs(N1,N) $((ord(N) = (ord(N1)+offsetcr('1'))) and ord(N) gt minheight) =yes;
*c(N1,N) $(ord(N) = (ord(N1)+offsetcr)) = crcost;
c(N1,N) $((ord(N) = (ord(N1)+offsetcr('1'))) AND (ord(N) ge 200) AND(ord(N) le 299)) = crcost('2');
c(N1,N) $((ord(N) = (ord(N1)+offsetcr('1'))) AND (ord(N) ge 400) AND(ord(N) le 499)) = crcost('4');
c(N1,N) $((ord(N) = (ord(N1)+offsetcr('1'))) AND (ord(N) ge 600) AND(ord(N) le 699)) = crcost('6');
c(N1,N) $((ord(N) = (ord(N1)+offsetcr('1'))) AND (ord(N) ge 800) AND(ord(N) le 899)) = crcost('8');
c(N1,N) $((ord(N) = (ord(N1)+offsetcr('1'))) AND (ord(N) ge 1000) AND(ord(N) le 1099)) = crcost('10');
c(N1,N) $((ord(N) = (ord(N1)+offsetcr('1'))) AND (ord(N) ge 1200) AND(ord(N) le 1299)) = crcost('12');

*Put arcs for climb rate climbout @ cost upcost
*Arcs(N1,N) $(ord(N) = (ord(N1)+offsetup)) =yes;
*c(N1,N) $(ord(N) = (ord(N1)+offsetup)) =upcost;

Arcs(N1,N)$((ord(N) = (ord(N1)+offsetup('2')) AND (ord(N) ge 200) AND(ord(N) le 399))) =yes;
c(N1,N)$((ord(N) = (ord(N1)+offsetup('2'))) AND (ord(N) ge 200) AND(ord(N) le 399)) =upcost('2');

Arcs(N1,N)$((ord(N) = (ord(N1)+offsetup('4'))) AND (ord(N) ge 400) AND(ord(N) le 599)) =yes;
c(N1,N)$((ord(N) = (ord(N1)+offsetup('4'))) AND (ord(N) ge 400) AND(ord(N) le 599)) =upcost('4');

Arcs(N1,N)$((ord(N) = (ord(N1)+offsetup('6'))) AND (ord(N) ge 600) AND(ord(N) le 799)) =yes;
c(N1,N)$((ord(N) = (ord(N1)+offsetup('6'))) AND (ord(N) ge 600) AND(ord(N) le 799)) =upcost('6');

Arcs(N1,N)$((ord(N) = (ord(N1)+offsetup('8'))) AND (ord(N) ge 800) AND(ord(N) le 999)) =yes;
c(N1,N)$((ord(N) = (ord(N1)+offsetup('8'))) AND (ord(N) ge 800) AND(ord(N) le 999)) =upcost('8');

Arcs(N1,N)$((ord(N) = (ord(N1)+offsetup('10'))) AND (ord(N) ge 1000) AND(ord(N) le 1299)) =yes;
c(N1,N)$((ord(N) = (ord(N1)+offsetup('10'))) AND (ord(N) ge 1000) AND(ord(N) le 1299)) =upcost('10');

*Put arcs for decsent rate descent @ cost downcost
Arcs(N1,N) $((ord(N) = (ord(N1)+offsetdown)) AND (ord(N) GT minheight  ) ) =yes;
*c(N1,N) $((ord(N) = (ord(N1)+offsetdown)) AND (ord(N) GT minheight)  ) =downcost;
c(N1,N) $((ord(N) = (ord(N1)+offsetdown))  AND(ord(N) ge 200) AND(ord(N)le 499 )  ) =downcost('4');
c(N1,N) $((ord(N) = (ord(N1)+offsetdown))  AND(ord(N) ge 500) AND(ord(N)le 699 ) ) =downcost('6');
c(N1,N) $((ord(N) = (ord(N1)+offsetdown))  AND(ord(N) ge 700) AND(ord(N)le 899 ) ) =downcost('8');
c(N1,N) $((ord(N) = (ord(N1)+offsetdown))  AND(ord(N) ge 900) AND(ord(N)le 1099 ) ) =downcost('10');
c(N1,N) $((ord(N) = (ord(N1)+offsetdown))  AND(ord(N) ge 1100) AND(ord(N)le 1299 ) ) =downcost('12');

*Need to insert cloud and stop arc from entering node where cloud is
Arcs(N,N2)$((lowcloud('c1')le (zcoord(N)+(zcoord(N2)-zcoord(N))/(xcoord(N2)-xcoord(N))*(xcoordcloud('c1')-xcoord(N))))
           AND ((zcoord(N)+((zcoord(N2)-zcoord(N))/(xcoord(N2)-xcoord(N))*(xcoordcloud('c1')-xcoord(N)))) le (highcloud('c1')))
           AND xcoord(N) le xcoordcloud('c1') AND xcoord(N2) ge xcoordcloud('c1'))=no;


Arcs(N,N2)$((lowcloud('c2')le (zcoord(N)+((zcoord(N2)-zcoord(N))/(xcoord(N2)-xcoord(N))*(xcoordcloud('c2')-xcoord(N)))))
           AND ((zcoord(N)+((zcoord(N2)-zcoord(N))/(xcoord(N2)-xcoord(N))*(xcoordcloud('c2')-xcoord(N)))) le (highcloud('c2')))
           AND xcoord(N) le xcoordcloud('c2') AND xcoord(N2) ge xcoordcloud('c2'))=no;

Arcs(N,N2)$((lowcloud('c3')le (zcoord(N)+((zcoord(N2)-zcoord(N))/(xcoord(N2)-xcoord(N))*(xcoordcloud('c2')-xcoord(N)))))
           AND ((zcoord(N)+((zcoord(N2)-zcoord(N))/(xcoord(N2)-xcoord(N))*(xcoordcloud('c3')-xcoord(N)))) le (highcloud('c3')))
           AND xcoord(N) le xcoordcloud('c3') AND xcoord(N2) ge xcoordcloud('c3'))=no;

display Arcs;
display c;

* Nodes should demand 0.
b(N) = 0 ;

*Need to pass flow of 1 from start to finish
b('start') =1;
b('finish')=-1;
display b;

* It's just MCNF.

variables flow(nodes,nodes), totalcost;
positive variables flow;
equations balance(nodes), objective;

balance(nodes)..
        sum(arcs(nodes,j), flow(nodes,j)) - sum(arcs(i,nodes), flow(i,nodes))
          =e= b(nodes);

objective..
        totalcost =e= sum(arcs, flow(arcs) * c(arcs));

*option lp = MOSEK;

model airplane /all/;
solve airplane using lp minimizing TotalCost ;

*shows what arcs airplane should travel on.
option flow:0:0:1;
display flow.l;
set 
    heightHeader /low,high,xcoord, zcoord,cloudx,status/;
$onExternalOutput
table FlowOP(CandN,CandN, heightHeader) 'Flow';
Scalar Cost;
$offExternalOutput
 Cost = TotalCost.L;
 FlowOP(N,Nodes, 'zcoord')$(flow.l(N,Nodes))=Groundheight + floor( (ord(N)-1)/100);
 flowOP(N,Nodes, 'xcoord')$(flow.l(N,Nodes))=mod(ord(N),100);
FlowOP(clouds,clouds,'low')=lowcloud(clouds);
FlowOp(clouds,clouds,'high')=highcloud(clouds);
FlowOp(clouds,clouds,'cloudx')=xcoordcloud(clouds);
FlowOP(CandN,CandN, 'status')=airplane.sumInfes+1;
display FlowOP;