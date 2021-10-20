
$setglobal n 6

option mip=gurobi
option limrow=0;
option limcol=0;
option solprint=off;


set i /1*%n%/;

$onexternalinput
set initsoln(i,i,i,i) / 1.1.2.1,1.2.2.2,1.3.2.3,1.4.1.5,
			2.1.2.2,2.2.2.3,2.5.3.5,2.6.3.6,
			3.2.4.2,3.3.4.3,3.3.3.4,3.4.3.5,
			4.1.4.2,6.4.6.5 / ;
set black(i,i) / 5.6, 6.6 /;
$offexternalinput

scalar supplyValue;

supplyValue = card(i) * card(i) - card(black) - 1;

set sourceNode(i,i) the choice of source node;
sourceNode(i,i) = no;

alias(i,j,k,l);

*choose a source node
loop((i,j),
    break$(card(sourceNode)>0.5);
    sourceNode(i,j)$(not black(i,j)) = yes;
);

*define adjacency arc
set nodes(i,j);
nodes(i,j) = not black(i,j);
set arcs(i,j,k,l);
loop((i,j)$nodes(i,j),
  arcs(i,j,i+1,j)$nodes(i+1,j) = yes;
  arcs(i,j,i,j+1)$nodes(i,j+1) = yes;
  arcs(i,j,i-1,j)$nodes(i-1,j) = yes;
  arcs(i,j,i,j-1)$nodes(i,j-1) = yes;
);
loop(initsoln(i,j,k,l),
  abort$(not arcs(initsoln)) "initsoln data not in arcs";
);

integer variable flow(i,j,k,l);

flow.fx(i,j,k,l)$(not(arcs(i,j,k,l))) = 0;

binary variable notZero(i,j,k,l) "1 if the flow between point (ij) and point (kl) is greater than zero;otherwise 0";

notZero.fx(i,j,k,l)$(not arcs(i,j,k,l)) = 0;

integer variable oddEdge(i,j);

* set the supply of source node and demand node
parameter supply(i,j);

supply(i,j) = 0;
supply(sourceNode) = supplyValue;
supply(i,j)$(not(sourceNode(i,j)) and not(black(i,j))) = -1;



free variable
    obj
;

equation
    flow_constr(i,j) flow constraint
    check_flow_const1(i,j,k,l) the binary logic of nonZero variable
    check_flow_const2(i,j,k,l) the binary logic of nonZero variable
    init_setting(i,j,k,l) nonegativity for flows in initial setting
    odd_edge_constr(i,j) limit the nonZero flow degree of a node to odd number
    objective
;
    

flow_constr(i,j)$(not black(i,j))..
    sum((k,l)$arcs(i,j,k,l),flow(i,j,k,l)) - sum((k,l)$arcs(k,l,i,j),flow(k,l,i,j)) =e= supply(i,j);
    
check_flow_const1(i,j,k,l)$arcs(i,j,k,l)..
    flow(i,j,k,l) + flow(k,l,i,j) =l= notZero(i,j,k,l) * supplyValue;
    
check_flow_const2(i,j,k,l)$arcs(i,j,k,l)..
    flow(i,j,k,l) + flow(k,l,i,j) + (1-notZero(i,j,k,l)) =g= 1;
    
init_setting(i,j,k,l)$initsoln(i,j,k,l)..
    flow(i,j,k,l) + flow(k,l,i,j) =g= 0.5;
    
 
odd_edge_constr(i,j)$(not black(i,j))..
    sum((k,l)$arcs(i,j,k,l),notZero(i,j,k,l)) =e= 1 + 2 * oddEdge(i,j);
    
objective..
    obj =e= sum((i,j,k,l),notZero(i,j,k,l))/2;
    

model circuit /all/;

circuit.optCA = 1;
solve circuit using mip minimizing obj;




set lines(i,j,k,l);
lines(i,j,k,l)=no;
lines(i,j,k,l)$(notZero.l(i,j,k,l) + notZero.l(k,l,i,j) > 0.5) = yes;
lines(i,j,k,l)$(initsoln(i,j,k,l) or initsoln(k,l,i,j)) = no;
lines(i,j,k,l)$(ord(k)<ord(i)) = no;
lines(i,j,k,l)$(ord(l)<ord(j)) = no;
option lines:0:0:4;
display lines;

set header /init,sol,blocked,boardSize/;

$onexternaloutput

parameter output(i,j,k,l,header);

$offexternaloutput

output(i,j,k,l,'init') = 0;
output(i,j,k,l,'init')$initsoln(i,j,k,l) = 1;
*output(i,j,k,l,'init')$(not arcs(i,j,k,l)) = 0;

output(i,j,k,l,'sol') = 0;
output(i,j,k,l,'sol')$( lines(i,j,k,l)) = 1;


output(i,j,k,l,'blocked') = 0;
output(i,j,'1','1','blocked')$black(i,j) = 1;

output(i,j,k,l,'boardSize') = 0;
output('1','1','1','1','boardSize') = %n%;