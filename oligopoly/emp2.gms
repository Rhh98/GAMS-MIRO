$title Oligopoly : Cournot, Bertrand and Stackelberg
$ontext
Kristian Chavira,  Jung Shin,  Gerard Biehl
(oligop_MPC_MPEC.gms)
CS 635 - Case Study
We have the following economic models and associated GAMS models;
   CES & MCP  - Cournot
   CES & MPEC - Stackelberg
Linear & MCP  - Bertrand
References
Dirkse, S P, and Ferris, M C, MCPLIB: A Collection of Nonlinear Mixed
       Complementarity Problems. Optimization Methods and Software 5 (1995),
       319-345.
(NASH,SEQ=269) - GAMS MODEL LIBRARY VARIANT
- display for the Stackelberg model is due to this GAMS library model
  which was introduced in the above paper with only the Cournot model
$offtext

*-------------------------------------------------------------------------------------------
* CES - COURNOT & STACKELBERG MODEL - 2 or more

SETS
i                "Cournot & Stackelberg firms"    / 1*3 /
lead(i) /1/;

set
leader(i)        "Stackelberg-leader"
;
set CESHeader /c ,L,beta/;
$onExternalInput
TABLE fData(i,CESHeader) "CES data for firms"
   c L  beta
1  5 5  1.5
2  5 10 1.2
3  5 15 1
;
SCALARS
* gamma > 1
gamma   "Demand Elasticity"            / 1.3 /
dbar    "Reference Unit Price Demand"  / 2000 / ;
$offexternalInput
PARAMETERS
c(i)    "Firm's Unit Production Cost"
L(i)    "Labor Coefficient"
beta(i) "Supply Elasticity"
;
c(i) = fData(i, "c") ;
L(i) = fData(i, "L") ;
beta(i) = fData(i, "beta") ;
alias (i,j,k) ;
NONNEGATIVE VARIABLES
q(i)   "Production Vector - for all models";
VARIABLES
obj(i) 'objective function for firm i'
p      "Market Clearing Price - Cournot & Stackelberg"
z      "Stackelberg-leader Profit" ;
EQUATIONS
defobj_Cour(i)     "define objective function for firm i in Cournot"
defobj_Stac(i)     "define objective function for firm i in stackelberg"
prod_def         "Total Production Definition"
obj_eq           "maximised Stackleberg-leader Profit"
;
*-------------------------------------------------------------------------------------------
* Cournot     - MPC complementarity defintion,
* Stackelberg - MPEC second level complementarity definition
prod_def..
         p =E= (dbar/sum(j, q(j)))**(1/gamma) ;
defobj_Cour(i)..
 obj(i) =e= q(i) *p-c(i)*q(i) -((beta(i)/(1+beta(i)))*L(i)**(1/beta(i)))*q(i)**((1+beta(i))/beta(i))     ;

defobj_Stac(i)$(not Leader(i))..
obj(i) =e= q(i) *(dbar/sum(j, q(j)))**(1/gamma)-c(i)*q(i) -((beta(i)/(1+beta(i)))*L(i)**(1/beta(i)))*q(i)**((1+beta(i))/beta(i));
*-------------------------------------------------------------------------------------------
* Stackelberg - MPEC first level optimisation

obj_eq..
         z =E= sum(leader(i), q(i)*p - q(i)*c(i) - ((beta(i)/(1+beta(i)))*L(i)**(1/beta(i)))*q(i)**((1+beta(i))/beta(i))) ;
*-------------------------------------------------------------------------------------------

model Cournot      / defobj_Cour,prod_def / ;

File myinfo /'%emp.info%'/;
put myinfo 'equilibrium';
put 'implicit p prod_def';
loop(i,
   put / 'max', obj(i), q(i),p, defobj_Cour(i);
);

putclose myinfo;


* allow domain violations in DNLP subsolvers
option domlim = 50;
$ifi %gams.mcp% == nlpec option dnlp=conopt;


*-------------------------------------------------------------------------------------------
* Model solve and display for Cournot Case
p.l = 1 ;
q.l(i) = 1 ;
leader(i) = no ;
solve Cournot using emp ;
* Cournot Quantities
display q.l, p.l ;
set CourHeader / quantity, price ,profit, gamma, dbar,cost,beta,l/;
$onexternaloutput
table resultCour(i,CourHeader);
table resultCour2(i,CourHeader);
$offexternaloutput
resultCour(i,'quantity')=q.l(i);
resultCour(i,'price')=p.l;
resultCour(i,'profit')=q.l(i) *p.l-c(i)*q.l(i) -((beta(i)/(1+beta(i)))*L(i)**(1/beta(i)))*q.l(i)**((1+beta(i))/beta(i));
resultCour(i,'gamma')=gamma;
resultCour(i,'dbar')=dbar;
resultCour(i,'cost')=c(i);
resultCour(i,'beta')=beta(i);
resultCour(i,'l')=L(i);
resultCour2(i,CourHeader)=resultCour(i,CourHeader)
*-------------------------------------------------------------------------------------------
* Model solve and display for Stackelberg Case
*   NOTE
*   This display procedure is due entirely to the GAMS MODEL LIBRARY (NASH,SEQ=269)
*   In the course of developing this Case Study we discovered the model posting and
*   found it to be better than anything we could formulate. So we took it
*   exactly instead of changing it so we could give credit where credit is due

* 'profit' display table
* The table has row 'i' and columns 'k'
* The "Cournot" column gives the profit of firm 'i' and the market price under Cournot
* the row indices give the firm 'i'
* The columns labeled k=[1, 2, 3] give the incidences where firm 'k' is the
* Stackelberg leader.  The rows are as before

* 'profitX' display table
* The table gives the percentage change for each column against the Cournot case
* that is 100*data(i,j)/data(i,"Cournot")

* 'quantity' procedure same as 'profit'

model Stackelberg / defobj_Stac, obj_eq,prod_def / ;
sets StacHeader /CourQuantity 'quantity when not a leader firm',StacQuantity 'quantity when as a leader firm',
                CourProfit 'profit when not a leader firm', StacProfit 'profit when as a leader firm'/;

$onexternalOutput
table resultStac(i,Stacheader) 'Difference between Cournot and Stackelberg model';
$offExternalOutput
leader(k) = no;
loop(k,
     leader(k) = yes ;
     p.l=1;
     q.l(i)=1;
put myinfo 'bilevel', q(k);
loop(i$(not Leader(i)),
   put  / 'max', obj(i), q(i), defobj_Stac(i);
);
putclose myinfo;

solve Stackelberg using emp maximizing z;
resultStac(k,'StacQuantity')=q.l(k);
resultStac(k,'StacProfit')=z.l;
leader(k) = no ;
);

resultStac(i,'CourQuantity')=resultCour(i,'quantity');
resultStac(i,'CourProfit')=resultCour(i,'profit');

Equation obj_subStac(i);
obj_subStac(i)$(not lead(i))..
obj(i) =e= q(i) *(dbar/sum(j, q(j)))**(1/gamma)-c(i)*q(i) -((beta(i)/(1+beta(i)))*L(i)**(1/beta(i)))*q(i)**((1+beta(i))/beta(i));

model subStackelberg /obj_subStac/;
set linfoHeader /lquantity,lprofit,nprofit/;
*    ninfoHeader /lquantity,lprofit,nprofit,nquantity/;
    
set grid /1*21/
 nonlead(i);
 nonlead(i)$(not lead(i))=yes;
$onexternalOutput
table linfo_stac(i,grid,linfoheader) lead firm info;
*table ninfo_stac(i,grid,ninfoheader) Nonleader firm info;
$offexternalOutput
*ninfo_stac(nonlead,grid,'nquantity')=resultCour(nonlead,'quantity');
loop(grid,
p.l=1;
q.l(i)=1;
q.fx(lead)=resultCour(lead,'Quantity')*(0.45+grid.val/20);
put myinfo 'equilibrium';
loop(i$(not lead(i)),
put /'max', obj(i),q(i),obj_subStac(i);
);
putclose myinfo;
solve subStackelberg using emp;
linfo_stac(lead,grid,'lquantity')=q.l(lead);
linfo_stac(lead,grid,'lprofit')=q.l(lead) *(dbar/sum(j, q.l(j)))**(1/gamma) -c(lead)*q.l(lead) -
((beta(lead)/(1+beta(lead)))*L(lead)**(1/beta(lead)))*q.l(lead)**((1+beta(lead))/beta(lead));
linfo_stac(lead,grid,'nprofit')=q.l(lead) *(dbar/(q.l(lead)+sum(j$(not lead(j)), resultCour(j,'quantity'))))**(1/gamma) -c(lead)*q.l(lead) -
((beta(lead)/(1+beta(lead)))*L(lead)**(1/beta(lead)))*q.l(lead)**((1+beta(lead))/beta(lead));
*ninfo_stac(nonlead,grid,'lquantity')=sum(lead,q.l(lead));
linfo_stac(nonlead,grid,'lprofit')=obj.l(nonlead);
linfo_stac(nonlead,grid,'nprofit')= resultCour(nonlead,'quantity') *(dbar/(sum(lead,q.l(lead))+sum(j$(nonlead(j)), resultCour(j,'quantity'))))**(1/gamma)  -c(nonlead)*resultCour(nonlead,'quantity') -
((beta(nonlead)/(1+beta(nonlead)))*L(nonlead)**(1/beta(nonlead)))*resultCour(nonlead,'quantity')**((1+beta(nonlead))/beta(nonlead));
);


*-------------------------------------------------------------------------------------------

*-------------------------------------------------------------------------------------------
* CONTINUOUS BERTRAND MODEL - 2 or more firms
* Note, this model could use price elasticites to define the weights 'w' and be more
* realistic but we simply assign 'w' so as to not confuse the models.
* The prediction of the LINEAR price competition model does not have a meaningful
* comparison to the CES quantity competition models

SETS d  "Bertrand firms"  / 1*2 / ;
set jHeader /w 'weight',c 'cost'/;
$onexternalInput
TABLE jData(d,jHeader)
   w   c
1  15  12
2  7   11
;
SCALARS
dBert     "unit reference demand - BERTRAND"  / 1000 / ;
$offExternalInput
PARAMETERS
alpha       "calibrated Bertrand demand"
delta1      "elasticity - firm 1 price"
delta2      "elasticity - firm 2 price"
;
alpha = (dBert*jData("1","w") - dBert*jData("2","w") )/( jData("1","w")**2 - jData("2","w")**2 ) ;
delta1 = jData("1","w")/( jData("1","w")**2 - jData("2","w")**2 ) ;
delta2 = jData("2","w")/( jData("1","w")**2 - jData("2","w")**2 ) ;
NONNEGATIVE VARIABLES
 p1         "unit selling price - firm 1"
 p2         "unit selling price - firm 2"
 q1         "quantity sold - firm 1"
 q2         "quantity sold - firm 2"
 prof1      "quantity sold - firm 1"
 prof2      "quantity sold - firm 2"
;
EQUATIONS
prof1_eq    "equilibrium profit - firm 1"
prof2_eq    "equilibrium profit - firm 2"
quan1_eq    "demand for products - firm 1"
quan2_eq    "demand for products - firm 2"
;
quan1_eq..
         q1 =E= alpha - delta1*p1 + delta2*p2 ;
quan2_eq..
         q2 =E= alpha - delta1*p2 + delta2*p1 ;

prof1_eq..
         prof1 =E= p1*q1 - jData("1","c")*q1 ;
prof2_eq..
         prof2 =E= p2*q2 - jData("2","c")*q2 ;
MODEL BertrandMCP  / quan1_eq, quan2_eq, 
                     prof1_eq, prof2_eq / ;

put myinfo 'equilibrium';
put /'max',prof1,p1,q1,quan1_eq,prof1_eq;
put /'max',prof2,p2,q2,quan2_eq,prof2_eq;
putclose myinfo;
SOLVE BertrandMCP using emp ;
set BertHeader /price,quantity,profit/;
$onexternalOutput
table resultBert(d,grid,BertHeader) Quantity and profits w.r.t the price of firm 1;
$offexternalOutput
loop(grid,
resultBert(d,grid,'price')=p1.l*(1/2+grid.val/20);
resultBert('1',grid,'quantity')=alpha-delta1*resultBert('1',grid,'price')+delta2*p2.l;
resultBert('2',grid,'quantity')=alpha+delta2*resultBert('2',grid,'price')-delta1*p2.l;
resultBert('1',grid,'profit')=resultBert('1',grid,'price')*resultBert('1',grid,'quantity')-jData("1","c")*resultBert('1',grid,'quantity');
resultBert('2',grid,'profit')=p2.l*resultBert('2',grid,'quantity')-jData("2","c")*resultBert('2',grid,'quantity');
)

