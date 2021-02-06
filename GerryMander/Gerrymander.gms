$title gerrymandering model


set P  parties  / republicans, democrats/;




$onExternalInput
scalar DISTRICT_NUM 'district number'/3/;

scalar forRepub /1/;

set nodes 'fips code';


$gdxIn adjaceny_AZ.gdx
$load nodes = Dim1
alias(nodes,i,j);

table foo(nodes,nodes);
alias(nodes,i,j);
$load foo = adj

parameter num(nodes,P);
$gdxIn county_vote_AZ.gdx
$load num = vote

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
;
    
binary variable 
    assign(i,district) if i is assigned to d
    root(district,i) 1 if i s the root in d
    assign_1_root_0(i,district) if i is assigned to d and is not a root return 1
    z(district) 1 if republican win in district d
;
equation
*------------------------------connectiviy constraint------------------------------
    objective
    each_assign_one(i) each county is assigned to one district
    one_root_constr(district)
    root_constr(i,district)
    flow_district_constr_1(district,i,j)
    flow_district_constr_2(district,i,j)
    min_node_district(district)
*    max_node_district(d)
    assign_1_root_0_constr_1(i,district)
    assign_1_root_0_constr_2(i,district)
    root_balance_1(district,i)
    root_balance_2(district,i)
    non_root_balance_1(district,i)
    non_root_balance_2(district,i)
*------------------------------vote calculation constraint------------------------------
*    ppl_constr_up(d) Number of PPL should be in the interval for every district
*    ppl_constr_lo(d) Number of PPL should be in the interval for every district
    total_population(district)
    decide_win_rep(district) See if in District J republicans are the winner
    decide_win_rep2(district) See if in District J republicans are the winner
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
    
flow_district_constr_1(d,i,j)$(arcs(i,j) or arcs(j,i))..
    x(d,i,j) =l= (node_num)*(assign(i,d));
    
flow_district_constr_2(d,i,j)$(arcs(i,j) or arcs(j,i))..
    x(d,i,j) =l= (node_num)*(assign(j,d));
    
min_node_district(d)..
    sum(i,assign(i,d)) =g= 2;

*max_node_district(d)..
*    sum(i,assign(i,d)) =l= 4;


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

*ppl_constr_up(d)..
*    sum(i, assign(i,d)*sum(P,num(i,P))) =l= Upper;
*ppl_constr_lo(d)..
*    sum(i, assign(i,d)*sum(P,num(i,P))) =g= Lower;

total_population(d)..
    sum(i, assign(i,d)*sum(P,num(i,P))) =e= pop(d);
decide_win_rep(d)..
    sum(i, assign(i,d)*(num(i,'republicans') - num(i,'democrats'))) - (totalPeople)*z(d) =l= 0;
    
decide_win_rep2(d)..
    sum(i, assign(i,d)*(num(i,'republicans') - num(i,'democrats'))) + (-totalPeople-1)*z(d) =g= -totalPeople ;

objective..
    forRepub * obj =e= 100 * sum(d,pop(d)*z(d))/totalPeople;


model spanning_tree /all/;

solve spanning_tree using minlp maximizing obj;
set gerryHeader /result1,result2/;
$onExternalOutput
table assign_result(nodes,district,gerryHeader) 'assigned';
$offExternalOutput
assign_result(nodes,d,'result1') = assign.l(nodes,d);
display assign_result;

