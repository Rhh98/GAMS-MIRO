
set scenario twenty scenarios in our demo/scen1*scen20/
    wards
    district
    party
    popBound /high,mid,low/;
;

$onexternalinput
scalar
    objectiveChoice 1 republicans -1 democrats fairness 2 /1/  
    popBoundChoice 1 low 2 mid 3 high /3/
    compactnessWeight 0 is original objective 1 is compactness /0.9/
;
$offexternalinput



$ontext
parameter strategies(scenario<,wards<,district<);
$gdxIn low_strategy_pool.gdx
$load strategies=isolated_reassign
$gdxIn


$gdxin low_strategy_centroid.gdx
set centroid(scenario,wards,district);
$load centroid
$gdxin

$gdxin vote_data.gdx
$load party=dim2
parameter vote(wards,party);
$load vote
$gdxin

$offtext


parameter all_strategies(scenario,popBound,wards<,district<);
set all_centroid(scenario,popBound,wards,district);
$gdxIn strategies_and_centroids.gdx
$load all_strategies=all_strategies, all_centroid=all_centroid
$gdxIn

parameter all_compactness(scenario,popBound);
$gdxIn all_compactness.gdx
$load all_compactness=all_compactness
$gdxIn



parameter
        strategies(scenario,wards,district)
        centroid(scenario,wards,district)
        compactness(scenario)
;
*choose the population bound
if(popBoundChoice = 1,
    strategies(scenario,wards,district) = all_strategies(scenario,'low',wards,district);
    centroid(scenario,wards,district) = all_centroid(scenario,'low',wards,district);
    compactness(scenario) =  all_compactness(scenario,'low');
    
elseif (popBoundChoice = 2),
    strategies(scenario,wards,district) = all_strategies(scenario,'mid',wards,district);
    centroid(scenario,wards,district) = all_centroid(scenario,'mid',wards,district);
    compactness(scenario) =  all_compactness(scenario,'mid');

elseif (popBoundChoice = 3),
    strategies(scenario,wards,district) = all_strategies(scenario,'high',wards,district);
    centroid(scenario,wards,district) = all_centroid(scenario,'high',wards,district);
    compactness(scenario) =  all_compactness(scenario,'high');
    
);



alias (wards,i,j);
alias (scenario,s);
alias (district,d,dc);
alias (party,p);






$gdxin vote_data.gdx
$load party=dim2
parameter vote(wards,party);
$load vote
$gdxin

parameter real_vote(party);

real_vote(party) = card(district) * sum(wards,vote(wards,party))/sum((i,p),vote(i,p));

parameter ifRepWin(s,d);

ifRepWin(s,d) = 0;
ifRepWin(s,d)$(sum(wards,strategies(s,wards,d)*vote(wards,'REP'))>sum(wards,strategies(s,wards,d)*vote(wards,'DEM'))) = 1;

*ifRepWin(s,d)$(ifRepWin(s,d) < 0.5) = -1;
$ontext
parameter dist_i_j(i,j) distance between ward i and j
          dist(s,i,dc) distance between ward i and center dc;;
          
$gdxin distance_between_i_j.gdx
$load dist_i_j=dist
$gdxin


dist(s,i,dc) = sum(j$centroid(s,j,dc),dist_i_j(i,j));
parameter n(i);

n(i) = sum(party,vote(i,party));

parameter
    compactness(s);
    
compactness(s) = sum((i,dc)$(strategies(s,i,dc)>0.5),n(i)*dist(s,i,dc))/100000000000;
*execute_unload "low_compactness.gdx", compactness;

$offtext


free variable
    objVote
    objMax
    objMin
    objFair
;

binary variable
    choice(s)    
;

equations
    objective
    oneChoice
    maxObjFun
    minObjFun
;

objective..
    objVote =e= sum(s,(choice(s)*sum(d, ifRepWin(s,d))));
oneChoice..
    sum(s,choice(s)) =e=1;
maxObjFun..
    objMax =e= sum(s,choice(s)*((1-compactnessWeight)*sum(d, ifRepWin(s,d)) - compactnessWeight*compactness(s)));
minObjFun.. 
    objMin =e= sum(s,choice(s)*((1-compactnessWeight)*sum(d, ifRepWin(s,d)) + compactnessWeight*compactness(s)));
model strategyChoiceMax /maxObjFun, oneChoice/;
model strategyChoiceMin /minObjFun, oneChoice/;
free variable
    fairObj;

equations    
    abs1
    abs2
    fairObjFun
;


abs1..
    fairObj =g= objVote - real_vote('REP');
abs2..
    fairObj =g= -objVote + real_vote('REP');
fairObjFun..   
    objFair =e= (1-compactnessWeight)*fairObj + compactnessWeight*sum(s,choice(s)*compactness(s));
    
model strategyChoiceFair /objective, oneChoice, abs1, abs2, fairObjFun/;


if (objectiveChoice=1,
    solve strategyChoiceMax using mip maximizing objMax;
elseif (objectiveChoice=-1),
    solve strategyChoiceMin using mip minimizing objMin;
elseif (objectiveChoice=2),
    solve strategyChoiceFair using mip minimizing objFair;
);



parameter
    assigned(i,d)
    assigned_dc(s,i,d)
;
assigned_dc(s,i,d) = 0;
assigned_dc(s,i,d)$centroid(s,i,d) = 1;

set
    districtCenter(i,d)
;
assigned(i,d) = 0;
assigned(i,d)$(sum(s, choice.l(s)*strategies(s,i,d)) > 0.5) = 1;

districtCenter(i,d) = sum(s,choice.l(s) * assigned_dc(s,i,d));

scalar chosenScenario;

chosenScenario = sum(s,choice.l(s)*ord(s));

set header /'centroid','dist','winLoss','choice'/;

$onexternaloutput

parameter assignment(i,d,header);
parameter assignment_population(d,party);
parameter assignment_population2(d,party);
parameter interactive(i) store objective choice;
$offexternaloutput

assignment(i,d,header) = 0;
assignment(i,d,'dist')$(assigned(i,d)>0.5) = 1;
assignment(i,d,'centroid') = districtCenter(i,d);
assignment(i,d,'winLoss')$(assigned(i,d)>0.5 and sum(s,choice.l(s)*ifRepWin(s,d)) > 0.5) = 1;
assignment(i,d,'winLoss')$(assigned(i,d)>0.5 and sum(s,choice.l(s)*ifRepWin(s,d)) < 0.5) = -1;
assignment(i,d,'choice') = chosenScenario;

assignment_population(d,party) = sum((wards),assigned(wards,d)*vote(wards,party));

assignment_population2(d,party) = sum((wards),assigned(wards,d)*vote(wards,party));

interactive(i) = popBoundChoice;

display assignment_population;
    

    

    






