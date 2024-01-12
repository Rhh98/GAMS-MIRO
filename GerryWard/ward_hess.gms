$title		Hess model on Ward-Level Redistricting with Given Centroid (officical)
option limrow = 0 ,limcol = 0;
option solprint = off;
option mip = gurobi;

$set ds milwaukee

* include data processing gms
$include dataset


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

distance(i,j)$centroid_hess(j) =
    sqrt(sum(xy,sqr(center(i,"ward",xy)-center(j,"ward",xy))));

positive variable
    population(i) the population for each ward;
    
free variable
    objectiveVal;
    
binary variable
    assign(i,j) 1 if ward i is assigned to ward j;
    
*assign.fx(i,j)$(not centroid_hess(j)) = 0;

**** simple Hess Model****
equation
    OBJ population weighted distance objective function
    assgin_constr(i) each ward should be assigned to exactly one centroid ward
    centroid_constr(i) set predefined centroid
    centroid_num_constr limit the number of districts

    ;
    
OBJ..
    objectiveVal =e= sum((i,id)$centroid_hess(id), n(i)*distance(i,id)*assign(i,id));

assgin_constr(i)..
    sum(id$centroid_hess(id),assign(i,id)) =e= 1;

centroid_constr(i)$centroid_hess(i)..
    assign(i,i) =e= 1;
    
centroid_num_constr..
    sum(i$centroid_hess(i),assign(i,i)) =e= district_num;
    
*model wardHess /OBJ, assgin_constr, centroid_constr, centroid_num_constr/;

*solve wardHess using mip minimizing objectiveVal ;


* the folllowing are flow constraints and population constraints
positive variable
    flow(i,j,id) flow from ward i to ward j in district id
    NV(id) population of a distirct id
;


parameter root(i,id) see if ward i is the center of district id;
root(i,id) = 0;
root(i,i)$centroid_hess(i) = 1;

equation
    flow_constr_1(i,j,id) the flow between two wards should be zero if one of them is not assigned to id
    flow_constr_2(i,j,id) the flow between two wards should be zero if one of them is not assigned to id
    root_balance_1(id) the network flow for a root node
    non_root_balance_1(i,id) the network flow for a non-root node
    population_calculation(id)
;

flow_constr_1(i,j,id)$(centroid_hess(id))..
    flow(i,j,id) =l= ward_num*assign(i,id);

flow_constr_2(i,j,id)$(centroid_hess(id))..
    flow(i,j,id) =l= ward_num*assign(j,id);
    
root_balance_1(id)$(centroid_hess(id))..
    sum(j$(border(id,j) or border(j,id)), flow(id,j,id)) - sum(j$(border(id,j) or border(j,id)), flow(j,id,id)) =e=
    (sum(j,assign(j,id))-1);
    
non_root_balance_1(i,id)$((not sameAs(i,id)) and centroid_hess(id))..
    sum(j$(border(i,j) or border(j,i)), flow(i,j,id) ) - sum(j$(border(i,j) or border(j,i)), flow(j,i,id)) =e=
    -1 * assign(i,id);
    
population_calculation(id)$centroid_hess(id)..
    NV(id) =e= sum(i, assign(i,id)*n(i));
    
* use parameter upper/lower bounds to model population upper/lower bounds
NV.UP(id)$centroid_hess(id) = PopUp*sum(i,n(i))/district_num;
NV.LO(id)$centroid_hess(id) = PopLow*sum(i,n(i))/district_num;


*flow.fx(i,j,id)$(not centroid_hess(id)) = 0;
*flow.fx(i,j,id)$(centroid_hess(j)) = 0;
*assign.fx(i,j)$(not centroid_hess(j)) = 0;

model wardHessContig /all/;

wardHessContig.holdfixed=1;

solve wardHessContig using mip minimizing objectiveVal ;
set header /value/;


* the following are for miro output, do not run under these line


$onexternaloutput
table assign_result(i,s,id,header);
table population_result(id,header);
$offexternaloutput
assign_result(i,s,id,'value') = 0;

assign_result(i,s,id,'value')$(smap(i,s) and assign.l(i,id) > 0.5) = 1;
population_result(id,'value') = NV.l(id);