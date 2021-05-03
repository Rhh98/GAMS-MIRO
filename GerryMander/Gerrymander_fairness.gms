$title gerrymandering model

*solver choice
option mip = osigurobi;
*allow mipstart for osigurobi
option integer4 = 1;
*time limit
option resLim = 120;

set P  parties  / republicans, democrats/;
set nodes 'fips code';

*this will forever be set at 1, since we are now trying to maintain the fairness
scalar forRepub /1/;

$onExternalInput

*number of districts to be assigned to
scalar DISTRICT_NUM 'district number'/10/;

*fraction of population upper and lower bound for a district
* washington 0.2 / 3.8
* Wisconsin  0.5 / 1.6
scalar lower_fraction 'population lowerbound fraction' /0.5/;
scalar upper_fraction 'population upperbound fraction' /1.6/;
scalar lambda 'the penalty of the population difference between max district and min district' /0/;

alias (nodes,i,j);

*read in the voting data
parameter num(nodes<,P)/
$ondelim
$include vote_Wisconsin.csv
$offdelim
/;

* read in the adjacency data
parameter foo(nodes,nodes)/
$ondelim
$include adj_Wisconsin.csv
$offdelim
/;


$offExternalInput

* construct adjacency arc according to adjacency csv
set arcs(nodes,nodes);
arcs(i,j)$(foo(i,j) = 1) = yes;

*declare the district set and setup the district subset according to district_num
set district/d1*d20/;
set sDistrict(district);
sDistrict(district)$(ord(district)<=DISTRICT_NUM) = yes;
alias(sDistrict,d);

* calculate population upper and lower bounds for every district 
Scalar
    Upper
    Lower
;
scalar totalPeople,totalRep,totalDem, ratio_R2D;
totalPeople = sum((I,P), num(I,P)) ;
Lower = lower_fraction * totalPeople / card(d) ;
Upper = upper_fraction * totalPeople / card(d) ;
totalRep = sum(I,num(I,'Republicans'));
totalDem = sum(I,num(I,'Democrats'));
ratio_R2D = totalDem/totalRep;


* some parameter used for statistical use
parameter pop_each_N(nodes);
pop_each_N(nodes) = sum(P,num(nodes,P));
scalar node_num;
node_num = card(nodes);



free variable
    obj;
nonnegative variable
    x(district,i,j) flow from i to j in district d
    pop(district) total population in a given district
    y(district) the product of total population of and whether it wins in district d
    abs_t absolute value for the objective function
    max_pop the population of the biggest district
    min_pop the population of the smallest district
;
    
binary variable 
    assign(i,district) 1 if i is assigned to d otherwise 0  
    root(district,i) 1 if i s the root in d otherwise 0
    assign_1_root_0(i,district) if i is assigned to d and is not a root return 1 otherwise 0
    z(district) 1 if republican win in district d otherwise 0
    both_assign(i,j,district) if both i and j are assigned to a district return 1 otherwise 0
;




*set initial starting value (important for large problem)
set
    assign_init(i,district) 1 if i is assigned to d otherwise 0(set)
    root_init(district,i) 1 if i s the root in d otherwise 0(set)
    assign_1_root_0_init(i,district) if i is assigned to d and is not a root return 1 otherwise 0(set)
    z_init(district) 1 if republican win in district d otherwise 0
    both_assign_init(i,j,district) if both i and j are assigned to a district return 1 otherwise 0
;
$GDXIN initial_point_Wisconsin_3.gdx
$load assign_init
$load root_init
$load assign_1_root_0_init
$load z_init
$load both_assign_init
$GDXIN
assign.l(i,district)$assign_init(i,district) = 1;
root.l(district,i)$root_init(district,i) = 1;
assign_1_root_0.l(i,district)$assign_1_root_0_init(i,district) = 1;
z.l(district)$z_init(district) = 1;
both_assign.l(i,j,district)$both_assign_init(i,j,district) = 1;
scalar original_win;
original_win = sum(district,z.l(district));


* constraint declaration
equation
    objective objective function
*------------------------------connectiviy constraint------------------------------
    each_assign_one(i) each county is assigned to one district
    one_root_constr(district) there can only be one root for a district
    root_constr(i,district) county i can be the root of a distirct iff it is inside district d
    avoid_root_search(i,j,district) avoid unncessary search for root
    flow_district_constr_1(district,i,j) only if a county is assigned to a district can it have flow > 0
    flow_district_constr_2(district,i,j) only if a county is assigned to a district can it have flow > 0
    assign_1_root_0_constr_1(i,district) logical construction for assign_1_root_0(id)
    assign_1_root_0_constr_2(i,district) logical construction for assign_1_root_0(id)
    root_balance_1(district,i) the network flow for a root node
    root_balance_2(district,i) the network flow for a root node
    non_root_balance_1(district,i) the network flow for a non-root node
    non_root_balance_2(district,i) the network flow for a non-root node
*------------------------------vote calculation constraint------------------------------
    ppl_constr_lo(district) min Number of PPL should be in the interval for every district
    ppl_constr_up(district) max Number of PPL should be in the interval for every district
    decide_win_rep(district) See if in District J republicans are the winner
    decide_win_rep2(district) See if in District J republicans are the winner
    abs_obj1 help construct the absolute value of the difference between two party
    abs_obj2 help construct the absolute value of the difference between two party
    dif_pop1(district) help construct the penalty term of the objective
    dif_pop2(district) help construct the penalty term of the objective

;

*------------------------------objective function------------------------------
objective..
    obj =e= abs_t + lambda * (max_pop-min_pop);
*------------------------------connectiviy constraint------------------------------

each_assign_one(i)..
    sum(d, assign(i,d)) =e= 1;
    
one_root_constr(d)..
    sum(i, root(d,i)) =e= 1;
    
root_constr(i,d)..
    root(d,i) =l= assign(i,d);
    
avoid_root_search(i,j,d)$(ord(i) < ord(j))..
    root(d,i) - root(d,j) + 2*both_assign(i,j,d) =l=3;
    
flow_district_constr_1(d,i,j)$(arcs(i,j) or arcs(j,i))..
    x(d,i,j) =l= (node_num)*(assign(i,d));
    
flow_district_constr_2(d,i,j)$(arcs(i,j) or arcs(j,i))..
    x(d,i,j) =l= (node_num)*(assign(j,d));
    
assign_1_root_0_constr_1(i,d)..
    assign(i,d) + (1-root(d,i)) - assign_1_root_0(i,d) =l= 1;
    
assign_1_root_0_constr_2(i,d)..
    assign(i,d) + (1-root(d,i)) - 2*assign_1_root_0(i,d) =g= 0;
    
root_balance_1(d,i)..
    sum(j$(arcs(i,j) or arcs(j,i)), x(d,i,j)) - sum(j$(arcs(i,j) or arcs(j,i)), x(d,j,i)) - (sum(j,assign(j,d))-1) +
    root(d,i)*(node_num) =l= (node_num);
    
root_balance_2(d,i)..
    sum(j$(arcs(i,j) or arcs(j,i)), x(d,i,j) ) - sum(j$(arcs(i,j) or arcs(j,i)), x(d,j,i)) - (sum(j,assign(j,d))-1) +
    root(d,i)*(-node_num) =g= (-node_num);
    
non_root_balance_1(d,i)..
    sum(j$(arcs(i,j) or arcs(j,i)), x(d,i,j) ) - sum(j$(arcs(i,j) or arcs(j,i)), x(d,j,i)) - (-1) +
    (assign_1_root_0(i,d))*(node_num) =l= node_num;
    
non_root_balance_2(d,i)..
    sum(j$(arcs(i,j) or arcs(j,i)), x(d,i,j) ) - sum(j$(arcs(i,j) or arcs(j,i)), x(d,j,i)) - (-1)=g= 0;

*------------------------------vote calculattion constraint------------------------------
ppl_constr_lo(d)..
    sum(i, assign(i,d)*sum(P,num(i,P))) =g= Lower;
    
ppl_constr_up(d)..
    sum(i, assign(i,d)*sum(P,num(i,P))) =l= Upper;
    
decide_win_rep(d)..
    sum(i, assign(i,d)*(num(i,'republicans') - num(i,'democrats'))) - (totalPeople)*z(d) =l= 0;
    
decide_win_rep2(d)..
    sum(i, assign(i,d)*(num(i,'republicans') - num(i,'democrats'))) + (-totalPeople-1)*z(d) =g= -totalPeople ;

abs_obj1..
    abs_t =g= (DISTRICT_NUM-sum(d,z(d))) - ratio_R2D*sum(d,z(d));
abs_obj2..
    abs_t =g= -((DISTRICT_NUM-sum(d,z(d))) - ratio_R2D*sum(d,z(d)));
    
dif_pop1(d)..
    max_pop =g= sum(i, assign(i,d)*sum(P,num(i,P)));
dif_pop2(d)..
    min_pop =l= sum(i, assign(i,d)*sum(P,num(i,P)));
    


model spanning_tree /all/;

*keep track of solving time - start time
scalar starttime;
starttime = jnow;

solve spanning_tree using mip minimizing obj;

*keep track of solving time - end time
scalar elapsed;
elapsed = (jnow - starttime)*24*3600;


* some parameter used for statistical use
parameter
    afterWinLoss(nodes)
    tempWinLoss(nodes,district)
;

tempWinLoss(i,d)$(assign.l(i,d) + z.l(d) = 2) = 1;
afterWinLoss(i)$(sum(d,tempWinLoss(i,d)) = 1) = 1;


set gerryHeader /result1,result2/;
set gerryHeader2 /result1,RorD/; 
set new_votes_header /num_votes,forRep/;
$onExternalOutput
table assign_result(nodes,district,gerryHeader) 'assigned';
table assign_result2(nodes,district,gerryHeader2) 'assigned';
table assign_result3(nodes,district,gerryHeader2) 'assigned';
parameter rep_district_num Number of Republicans Districts;
parameter dem_district_num Number of Democrats Districts;
parameter runtime_used Total Runtime;
parameter pop_each_D(district) population;
$offExternalOutput
assign_result(nodes,d,'result1') = assign.l(nodes,d);
assign_result2(nodes,d,'result1') = assign.l(nodes,d);
assign_result2(nodes,d,'RorD')$(assign_result(nodes,d,'result1')=1 and afterWinLoss(nodes)=1) = 1;
assign_result2(nodes,d,'RorD')$(assign_result(nodes,d,'result1')=1 and afterWinLoss(nodes)=0) = -1;
assign_result3(nodes,d,'result1') = assign.l(nodes,d);
assign_result3(nodes,d,'RorD')$(assign_result(nodes,d,'result1')=1 and afterWinLoss(nodes)=1) = 1;
assign_result3(nodes,d,'RorD')$(assign_result(nodes,d,'result1')=1 and afterWinLoss(nodes)=0) = -1;


rep_district_num = sum(d,z.l(d));
dem_district_num = DISTRICT_NUM-sum(d,z.l(d));

runtime_used = spanning_tree.resusd;

pop_each_D(d) = sum((i,P),num(i,P)*assign.l(i,d));

*write some experiment results into and .out file if necessary
$ontext
file da /gerry_mander_fairness_%state%.out/;
da.ap = 1;
put da;
put /'initial_point%num% -------------'/;
put /'original votes:',original_win/;
put /'final votes:',total_district_won/;
put /'best possible solution:',spanning_tree.objest/;
put /'solving time:',elapsed/;
putclose da;
$offtext
