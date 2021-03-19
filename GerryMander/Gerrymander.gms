$title gerrymandering model


set P  parties  / republicans, democrats/;


set nodes 'fips code';

$onExternalInput
scalar DISTRICT_NUM 'district number'/3/;

scalar forRepub /1/;

scalar low_county_num /2/;

alias(nodes,i,j);

parameter num(nodes<,P)/
$ondelim
$include vote_AZ.csv
$offdelim
/;


parameter foo(nodes,nodes)/
$ondelim
$include adjacency_AZ.csv
$offdelim
/;


$offExternalInput



set district/d1*d10/;
set sDistrict(district);
set arcs(nodes,nodes);
arcs(i,j)$(foo(i,j) = 1) = yes;

sDistrict(district)$(ord(district)<=DISTRICT_NUM) = yes;
alias(sDistrict,d);
Scalar
    Upper
    Lower
;
scalar totalPeople;
totalPeople = sum((I,P), num(I,P)) ;
Lower = 0.2 * totalPeople / card(d) ;
Upper = 3 * totalPeople / card(d) ;


scalar node_num;
node_num = card(nodes);



free variable
    obj;
nonnegative variable
    x(district,i,j) flow from i to j in district d
    pop(district)
    y(district) the product of total population of and whether it wins in district d
;
    
binary variable 
    assign(i,district) if i is assigned to d
    root(district,i) 1 if i s the root in d
    assign_1_root_0(i,district) if i is assigned to d and is not a root return 1
    z(district) 1 if republican win in district d
    both_assign(i,j,district) if both i and j are assigned to a district return 1aaa2á1q    s3
;
equation
*------------------------------connectiviy constraint------------------------------
    objective
    each_assign_one(i) each county is assigned to one district
    one_root_constr(district)
    root_constr(i,district)
    root_order_const1(i,j,district) avoid unncessary search for root
*    root_order_const2(i,j,district) avoid unncessary search for root
    avoid_root_search(i,j,district) avoid unncessary search for root
    flow_district_constr_1(district,i,j)
    flow_district_constr_2(district,i,j)
    min_node_district(district)
    assign_1_root_0_constr_1(i,district)
    assign_1_root_0_constr_2(i,district)
    root_balance_1(district,i)
    root_balance_2(district,i)
    non_root_balance_1(district,i)
    non_root_balance_2(district,i)
*------------------------------vote calculation constraint------------------------------
    total_population(district)
    decide_win_rep(district) See if in District J republicans are the winner
    decide_win_rep2(district) See if in District J republicans are the winner
    y_d_const1(district)
    y_d_const2(district)
    y_d_const3(district)
;

$ontext
------------------------------connectiviy constraint------------------------------
$offtext
each_assign_one(i)..
    sum(d, assign(i,d)) =e= 1;
    
one_root_constr(d)..
    sum(i, root(d,i)) =e= 1;
    
root_constr(i,d)..
    root(d,i) =l= assign(i,d);
    
root_order_const1(i,j,d)..
    assign(i,d) + assign(j,d) - 2*both_assign(i,j,d) =l= 1;

*root_order_const2(i,j,d)..
*    assign(i,d) + assign(j,d) - both_assign(i,j,d) =g= 1;
    
avoid_root_search(i,j,d)$(ord(i) < ord(j))..
    root(d,i) - root(d,j) + 2*both_assign(i,j,d) =l=3;
    
flow_district_constr_1(d,i,j)$(arcs(i,j) or arcs(j,i))..
    x(d,i,j) =l= (node_num)*(assign(i,d));
    
flow_district_constr_2(d,i,j)$(arcs(i,j) or arcs(j,i))..
    x(d,i,j) =l= (node_num)*(assign(j,d));
    
min_node_district(d)..
    sum(i,assign(i,d)) =g= low_county_num;

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

$ontext
------------------------------vote calculattion constraint------------------------------
$offtext

total_population(d)..
    sum(i, assign(i,d)*sum(P,num(i,P)))/totalPeople =e= pop(d);
    
decide_win_rep(d)..
    sum(i, assign(i,d)*(num(i,'republicans') - num(i,'democrats'))) - (totalPeople)*z(d) =l= 0;
    
decide_win_rep2(d)..
    sum(i, assign(i,d)*(num(i,'republicans') - num(i,'democrats'))) + (-totalPeople-1)*z(d) =g= -totalPeople ;

y_d_const1(d)..
    y(d) =l= z(d);
y_d_const2(d)..
    y(d) =l= pop(d);
y_d_const3(d)..
    pop(d) - y(d) =l= 1-z(d);

objective..
    forRepub * obj =e= 100 * sum(d,y(d));


model spanning_tree /all/;

solve spanning_tree using mip maximizing obj;

parameter afterWinLoss(nodes);

parameter tempWinLoss(nodes,district);

tempWinLoss(i,d)$(assign.l(i,d) + z.l(d) = 2) = 1;

afterWinLoss(i)$(sum(d,tempWinLoss(i,d)) = 1) = 1;

display afterWinLoss;

set gerryHeader /result1,result2/;
set gerryHeader2 /result1,RorD/;
set new_votes_header /num_votes,forRep/;
$onExternalOutput
table assign_result(nodes,district,gerryHeader) 'assigned';
table assign_result2(nodes,district,gerryHeader2) 'assigned';
table assign_result3(nodes,district,gerryHeader2) 'assigned';

$offExternalOutput
assign_result(nodes,d,'result1') = assign.l(nodes,d);
assign_result2(nodes,d,'result1') = assign.l(nodes,d);
assign_result2(nodes,d,'RorD')$(assign_result(nodes,d,'result1')=1 and afterWinLoss(nodes)=1) = 1;
assign_result2(nodes,d,'RorD')$(assign_result(nodes,d,'result1')=1 and afterWinLoss(nodes)=0) = -1;
assign_result3(nodes,d,'result1') = assign.l(nodes,d);
assign_result3(nodes,d,'RorD')$(assign_result(nodes,d,'result1')=1 and afterWinLoss(nodes)=1) = 1;
assign_result3(nodes,d,'RorD')$(assign_result(nodes,d,'result1')=1 and afterWinLoss(nodes)=0) = -1;


