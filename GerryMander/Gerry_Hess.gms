$title gerrymandering (based on HESS)
option mip = gurobi;

$onecho > cplex.opt
mipstart 1
$offecho

$onecho > gurobi.opt
mipstart 1
$offecho


set P  parties  / republicans, democrats/;
set nodes 'fips code';

$onExternalInput
scalar forDem /-1/;
scalar DISTRICT_NUM /10/;
scalar pop_Upper /1.7/;
scalar pop_Lower /0.4/;
scalar lambda_compactness /1/;
scalar lambda_pop /0/;
*read in the voting data
parameter num(nodes<,P)/
$ondelim
$include vote_Wisconsin.csv
$offdelim
/;

* read in the distance data
parameter distance(nodes,nodes)/
$ondelim
$include distance_Wisconsin.csv
$offdelim
/;

parameter foo(nodes,nodes)/
$ondelim
$include adj_Wisconsin.csv
$offdelim
/;
$offExternalInput
* population scalars
scalar
        avgPop average population per district
        totPop total population
;
totPop = sum((nodes,P),num(nodes,P));
avgPop = totPop/DISTRICT_NUM;


scalar county_num;
county_num = card(nodes);

alias(nodes,i,j,k,district);

set arcs(nodes,nodes);
arcs(i,j)$(foo(i,j) = 1) = yes;

parameter dist(nodes,nodes);
dist(i,j)$(ord(i)<ord(j)) = distance(i,j);
dist(i,j)$(ord(i)>ord(j)) = distance(j,i);

binary variable 
    assigned(i,j) 1 if i is assigned to j otherwise 0
    z(j) 1 if republicans win in unit j
    win_rep(j)
    both_assign(i,k,j) if i k are both assign to j 1
;

free variable
    obj
    t
;

positive variable
    flow(nodes,nodes)
    popL
    popU
;

parameter
    assigned_init(i,j)
    z_init(j)
    win_rep_init(j)
    both_assign_init(i,k,j)
;


$GDXIN initial_point_Hess.gdx
$load assigned_init
$load z_init
$load win_rep_init
$load both_assign_init
$GDXIN
assigned.L(i,j) = assigned_init(i,j);
z.L(j) = z_init(j);
win_rep.L(j) = win_rep_init(j);
both_assign.L(i,k,j) = both_assign_init(i,k,j);

equation
    obj_Hess
    population_bound_U(j) population upper bound
    population_bound_L(j) population lower bound
    assigned_to_one(i) each unit is assigned to one county
    district_constr only k districts can be the center of a district
    assigned_constr(i,j) a unit can be assigned to only when it is a center
    both_assign_constr1(i,k,j) construct binary logic of both_assign variable
    flow_not_root_assign_constr_1(i) determine the flow of a non-center unit
    flow_not_root_assign_constr_2(i) determine the flow of a non-center unit
    flow_existence_constr1(i,k) flow can exist only if two units are in the same district
    flow_existence_constr2(i,k) flow can exist only if two units are in the same district
    root_inflow_constr(j) center unit cannot have inflow
    
    decide_win_rep1(j)
    decide_win_rep2(j)
    decide_win_rep3(j)
    decide_win_rep4(j)

;
obj_Hess..
*obj =e= sum((i,j),dist(i,j)*assigned(i,j));
*obj =e= lambda_pop*(popU-popL)/smax(i, sum(P, num(i,P)));
*obj =e= lambda_pop*(popU-popL)/smax(i, sum(P, num(i,P))) + lambda_compactness * sum((i,j),dist(i,j)*assigned(i,j));
*obj =e= forDem * sum(j,win_rep(j)) + lambda_pop*(popU-popL)/smax(i, sum(P, num(i,P))) ;
    obj =e= forDem * sum(j,win_rep(j));
population_bound_U(j)..
    sum((P,i),num(i,P)*assigned(i,j)) =l= pop_Upper*avgPop + totPop*(1-assigned(j,j));
    
population_bound_L(j)..
    sum((P,i),num(i,P)*assigned(i,j)) =g= assigned(j,j)*pop_Lower*avgPop;
    

*---- ---------flow constraint----------------
assigned_to_one(i)..
    sum(j, assigned(i,j)) =e= 1;
    
district_constr..
    sum(j, assigned(j,j)) =e= DISTRICT_NUM;
    
assigned_constr(i,j)..
    assigned(i,j) =l= assigned(j,j);

both_assign_constr1(i,k,j)$(arcs(i,k) or arcs(k,i))..
    assigned(i,j) + assigned(k,j) =g= 2*(both_assign(i,k,j));  

flow_not_root_assign_constr_1(i)..
    sum(k$(arcs(i,k) or arcs(k,i)), flow(i,k)) - sum(k$(arcs(i,k) or arcs(k,i)), flow(k,i)) + 1 =g= 0;
    
flow_not_root_assign_constr_2(i)..
    sum(k$(arcs(i,k) or arcs(k,i)), flow(i,k)) - sum(k$(arcs(i,k) or arcs(k,i)), flow(k,i)) + 1 + county_num*(1-assigned(i,i)) =l= county_num;
   
flow_existence_constr1(i,k)$(arcs(i,k) or arcs(k,i))..
    flow(i,k) =l= (county_num-1)*(sum(j,both_assign(i,k,j)));
    
flow_existence_constr2(i,k)$(not(arcs(i,k) or arcs(k,i)))..
    flow(i,k) =e= 0;
    
root_inflow_constr(j)..
    sum(i$(arcs(i,j) or arcs(j,i)), flow(i,j)) + (county_num-1)*assigned(j,j) =l= (county_num-1);

*----------------Gerrymandering Constraint --------------------
 
decide_win_rep1(j)..
    sum(i,num(i,'republicans')*assigned(i,j)) + totPop*(1-z(j)) =g= sum(i,num(i,'democrats')*assigned(i,j));

decide_win_rep2(j)..
    sum(i,num(i,'republicans')*assigned(i,j)) =l= totPop*z(j) + sum(i,num(i,'democrats')*assigned(i,j));

decide_win_rep3(j)..
    z(j) + assigned(j,j) - win_rep(j) =l= 1;
    
decide_win_rep4(j)..
    z(j) + assigned(j,j) - 2*win_rep(j) =g= 0;

model hess_model /all/;

solve hess_model using mip minimizing obj;
hess_model.optfile=1;

set result(j);

result(j)$(assigned.l(j,j) = 1 and win_rep.l(j) = 1) = yes;
set gerryHeader /result1,result2/;
set gerryHeader2 /result1,RorD/; 

$onExternalOutput
table assign_result(nodes,district,gerryHeader) 'assigned';
table assign_result2(nodes,district,gerryHeader2) 'assigned';
table assign_result3(nodes,district,gerryHeader2) 'assigned';
parameter rep_district_num Number of Republicans Districts;
parameter dem_district_num Number of Democrats Districts;
parameter pop_each_D(district) population;
$offExternalOutput
assign_result(i,j,'result1') = assigned.l(i,j);
assign_result2(nodes,district,'result1') = assigned.l(nodes,district);
assign_result2(nodes,district,'RorD')$(win_rep.l(district)=1 and assigned.l(nodes,district)=1) = 1;
assign_result2(nodes,district,'RorD')$(win_rep.l(district)=0 and assigned.l(nodes,district)=1) = -1;
assign_result3(nodes,district,'result1') = assigned.l(nodes,district);
assign_result3(nodes,district,'RorD')$(win_rep.l(district)=1 and assigned.l(nodes,district)=1) = 1;
assign_result3(nodes,district,'RorD')$(win_rep.l(district)=0 and assigned.l(nodes,district)=1) = -1;

rep_district_num = sum(district,win_rep.l(district));
dem_district_num = DISTRICT_NUM-sum(district,win_rep.l(district));

pop_each_D(district)$(assigned.l(district,district)=1) = sum((nodes,P)$(assigned.l(nodes, district)=1), num(nodes,p));

$ontext
parameter
    assigned_init(i,j)
    z_init(j)
    win_rep_init(j)
    both_assign_init(i,k,j)
;

assigned_init(i,j) = assigned.l(i,j);
z_init(j) = z.l(j);
win_rep_init(j) = win_rep.l(j);
both_assign_init(i,k,j) = both_assign.l(i,k,j);
$offtext

*execute_unload 'initial_point_Hess.gdx', assigned_init, z_init, win_rep_init,both_assign_init ;
display result;

    




