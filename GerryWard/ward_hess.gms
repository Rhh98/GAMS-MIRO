$title		Hess model on Ward-Level Redistricting with Given Centroid (officical)
option limrow = 0 ,limcol = 0;
option solprint = off;
option mip = gurobi;
$set ds milwaukee

* include data processing gms
$include dataset

*initial solution // for developting use
$ontext
$onecho > cplex.opt
mipstart 1
$offecho

$onecho > gurobi.opt
mipstart 1
$offecho
$offtext

$ontext
parameter userInputCentroid(i);

userInputCentroid(i) = 0.5;
userInputCentroid(i)$centroid_hess(i) = 1;

execute_unload 'inputCentroid', userInputCentroid;
$offtext


$onExternalInput

parameter userInputCentroid(i)/
$ondelim
$include inputCentroid.csv
$offdelim
/;

scalar PopUp population upper bound /1.05/;
scalar PopLow population lower bound /0.95/;
$offExternalInput

centroid_hess(i) = no;
centroid_hess(i)$(userInputCentroid(i)>0.5) = yes;


*district number is defined by the number of predefined centroid
scalar district_num; 
district_num = card(centroid_hess);
scalar ward_num;
ward_num = card(id);

parameter distance(i,j) distance between each pair of wards;

distance(i,j) =
    sqrt(sum(xy,sqr(center(i,"ward",xy)-center(j,"ward",xy))));

positive variable
    population(i) the population for each ward;
    
free variable
    objectiveVal;
    
binary variable
    assign(i,j) 1 if ward i is assigned to ward j;
    
assign.fx(i,j)$(not centroid_hess(j)) = 0;
$ontext 
parameter assign_init(i,id);

$GDXIN init_solution.gdx
$load assign_init
$GDXIN

assign.l(i,id) = assign_init(i,id);
$offtext
**** simple Hess Model****
equation
    OBJ population weighted distance objective function
    assgin_constr(i) each ward should be assigned to exactly one centroid ward
    centroid_constr(i) set predefined centroid
    centroid_num_constr limit the number of districts
*    population_bound(i) population calculation
    ;
    
OBJ..
    objectiveVal =e= sum((i,id)$centroid_hess(id), n(i)*distance(i,id)*assign(i,id));

assgin_constr(i)..
    sum(id,assign(i,id)) =e= 1;

centroid_constr(i)$centroid_hess(i)..
    assign(i,i) =e= 1;
    
centroid_num_constr..
    sum(i,assign(i,i)) =e= district_num ;
    
*model wardHess /OBJ, assgin_constr, centroid_constr, centroid_num_constr/;

*solve wardHess using mip minimizing objectiveVal ;

$ontext
set asss(i,j);

asss(i,j)$(assign.l(i,j) > 0.5) = yes;

display asss;

**** simple Hess Model end****
$offtext

positive variable
    flow(i,j,id) flow from ward i to ward j in district id
    NV(id) population of a distirct id
;

$ontext
parameter NV_init(id);

$GDXIN init_NV.gdx
$load NV_init
$GDXIN



NV.l(id) = NV_init(id);
$offtext
binary variable
    assign_1_root_0(i,id) if i is assigned to id and is not a root return 1 otherwise 0
;

parameter root(i,id) see if ward i is the center of district id;
root(i,id) = 0;
root(i,i)$centroid_hess(i) = 1;

equation
    flow_constr_1(i,j,id) the flow between two wards should be zero if one of them is not assigned to id
    flow_constr_2(i,j,id) the flow between two wards should be zero if one of them is not assigned to id
*    assign_1_root_0_constr_1(i,id) logical construction for assign_1_root_0(id)
*    assign_1_root_0_constr_2(i,id) logical construction for assign_1_root_0(id)
    root_balance_1(i,id) the network flow for a root node
*    root_balance_2(i,id) the network flow for a root node
    non_root_balance_1(i,id) the network flow for a non-root node
*    non_root_balance_2(i,id) the network flow for a non-root node
    population_calculation(id)
;

flow_constr_1(i,j,id)$centroid_hess(id)..
    flow(i,j,id) =l= ward_num*assign(i,id);

flow_constr_2(i,j,id)$centroid_hess(id)..
    flow(i,j,id) =l= ward_num*assign(j,id);


*assign_1_root_0_constr_1(i,id)$centroid_hess(id)..
*    assign(i,id) + (1-root(i,id)) - assign_1_root_0(i,id) =l= 1;
    
*assign_1_root_0_constr_2(i,id)$centroid_hess(id)..
*    assign(i,id) + (1-root(i,id)) - 2*assign_1_root_0(i,id) =g= 0;

* if
root_balance_1(i,id)$(sameAs(i,id) and centroid_hess(id))..
    sum(j$(border(i,j) or border(j,i)), flow(i,j,id)) - sum(j$(border(i,j) or border(j,i)), flow(j,i,id)) =e=
    (sum(j,assign(j,id))-1);
    
non_root_balance_1(i,id)$((not sameAs(i,id)) and centroid_hess(id))..
    sum(j$(border(i,j) or border(j,i)), flow(i,j,id) ) - sum(j$(border(i,j) or border(j,i)), flow(j,i,id)) =e=
    -1 * assign(i,id);
    
population_calculation(id)$centroid_hess(id)..
    NV(id) =e= sum(i, assign(i,id)*n(i));
    

NV.UP(id)$centroid_hess(id) = PopUp*sum(i,n(i))/district_num;
NV.LO(id)$centroid_hess(id) = PopLow*sum(i,n(i))/district_num;




model wardHessContig /all/;


solve wardHessContig using mip minimizing objectiveVal ;
set header /value/;




$ontext
$onexternaloutput
table assign_result(rec,x,y,i,s,id,header);
$offexternaloutput

assign_result(rec,x,y,i,s,id,'value') = 0;

assign_result(rec,x,y,i,s,id,'value')$(smap(i,s) and nodes(rec,s,x,y) and assign.l(i,id) > 0.5) = 1;


$offtext

$onexternaloutput
table assign_result(i,s,id,header);
table population_result(id,header);
$offexternaloutput
assign_result(i,s,id,'value') = 0;

assign_result(i,s,id,'value')$(smap(i,s) and assign.l(i,id) > 0.5) = 1;
population_result(id,'value') = NV.l(id);