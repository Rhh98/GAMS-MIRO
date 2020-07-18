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
i                "Cournot & Stackelberg firms" /1*10/;

singleton set
leader(i)        "Stackelberg-leader"
;
set CESHeader /c ,L,beta/;
$onExternalInput
TABLE IData(i,CESHeader) "CES data for firms"
        c   L  beta
    1   5  10  1.2
    2   3  10  1
    3   8  10   .9
    4   5  10   .6
    5   1  10  1.5
    6   3  10  1
    7   7  10   .7
    8   4  10  1.1
    9   6  10   .95
   10   3  10   .75;
;
$offexternalInput

$onexternalInput
singleton set lead(i) /1/;
parameter CournotFirm(i) 'cournot or price taker (1/-1)' /set.I -1/;
$offexternalInput

set courn(I)  'cournot or price taker';
courn(I)$(CournotFirm(I)>0)=yes;

SCALARS
* gamma > 1
gamma   "Demand Elasticity"            / 1.3 /
dbar    "Reference Unit Price Demand"  / 2000 / ;
PARAMETERS
c(i)    "Firm's Unit Production Cost"
L(i)    "Labor Coefficient"
beta(i) "Supply Elasticity"
s(I)
;
c(i) = IData(i, "c") ;
L(i) = IData(i, "L") ;
beta(i) = IData(i, "beta") ;
s(I)    = (beta(I)/(1 + beta(I)))*L(I)**(1/beta(I));
alias (i,j,k) ;
NONNEGATIVE VARIABLES
q(i)   "Production Vector - for all models";
VARIABLES
prof(i) 'objective function for firm i'
p      "Market Clearing Price - Cournot & Stackelberg"
z      "Stackelberg-leader Profit" ;
EQUATIONS
defobj_Cour(i)     "define objective function for firm i in Cournot"
defp         "Total Production Definition"
;
*-------------------------------------------------------------------------------------------
* Cournot     - MPC complementarity defintion,
* Stackelberg - MPEC second level complementarity definition
$macro pr(q) ((dbar/sum(J, q(J)))**(1/gamma))

$macro TC(i,q) (c(i)*q(i) + s(i)*q(i)**((1+beta(i))/beta(i)))
defp..
         p =E= (dbar/sum(j, q(j)))**(1/gamma) ;
defobj_Cour(i)..
  z$Leader(i) + prof(i)$(not Leader(i)) =e= q(i)*{pr(q)$courn(i) + p$(not courn(i))}-TC(i,q);
*-------------------------------------------------------------------------------------------


model Cournot      / defobj_Cour,defp / ;

File myinfo /'%emp.info%'/;
put myinfo 'equilibrium';
loop(i,
   put / 'max', prof(i), q(i), defobj_Cour(i);
);
put / 'vi defp p';
putclose myinfo;

putclose myinfo;


* allow domain violations in DNLP subsolvers
option domlim = 50;
$ifi %gams.mcp% == nlpec option dnlp=conopt;


*-------------------------------------------------------------------------------------------
* Model solve and display for Cournot Case
p.l = 1 ;
q.l(i) = 1 ;
leader(I)=no;
solve Cournot using emp ;

* Cournot Quantities
display q.l, p.l ;
set CourHeader / quantity, price ,profit, gamma, dbar,cost,beta,l,courMember/;
$onexternaloutput
table resultCour(i,CourHeader);
*table resultCour2(i,CourHeader);
$offexternaloutput
resultCour(i,'quantity')=q.l(i);
resultCour(i,'price')=p.l;
resultCour(i,'profit')=q.l(i) *p.l-c(i)*q.l(i) -((beta(i)/(1+beta(i)))*L(i)**(1/beta(i)))*q.l(i)**((1+beta(i))/beta(i));
resultCour(i,'gamma')=gamma;
resultCour(i,'dbar')=dbar;
resultCour(i,'cost')=c(i);
resultCour(i,'beta')=beta(i);
resultCour(i,'l')=L(i);
resultCour(i,'courMember')=1$courn(i)-1$(not courn(i));
*resultCour2(i,CourHeader)=resultCour(i,CourHeader)
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

model Stackelberg / defobj_Cour, defp / ;

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
   put  / 'max', prof(i), q(i), defobj_Cour(i);
);
 put / 'vi defp p';
putclose myinfo;

solve Stackelberg using emp maximizing z;
resultStac(k,'StacQuantity')=q.l(k);
resultStac(k,'StacProfit')=z.l;
leader(k) = no ;
);


resultStac(i,'CourQuantity')=resultCour(i,'quantity');
resultStac(i,'CourProfit')=resultCour(i,'profit');

variables obj(i) 'Objective for sub-Stackelberg problem';
Equation obj_subStac(i);
obj_subStac(i)$(not lead(i))..
obj(i) =e= q(i)*{pr(q)$courn(i) + p$(not courn(i))}-TC(i,q);
model subStackelberg /obj_subStac,defp/;

set linfoHeader /lquantity,lprofit,nprofit,nquantity/;
*    ninfoHeader /lquantity,lprofit,nprofit,nquantity/;
    
set grid /1*21/
 nonlead(i);
 nonlead(i)$(not lead(i))=yes;
$onexternalOutput
table leader_stac_profit(i,grid,linfoheader) lead firm info,
leader_stac_quantity(i,grid,linfoheader);
*table ninfo_stac(i,grid,ninfoheader) Nonleader firm info;
$offexternalOutput
*ninfo_stac(nonlead,grid,'nquantity')=resultCour(nonlead,'quantity');
loop(grid,
p.l=1;
q.l(i)=1;
q.fx(lead)=resultCour(lead,'Quantity')*(0.45+grid.val/20);
put myinfo 'equilibrium';
loop(i$(nonlead(I)),
put /'max', obj(i),q(i),obj_subStac(i);
);
put / 'vi defp p';
putclose myinfo;
solve subStackelberg using emp;
leader_stac_profit(lead,grid,'lquantity')=q.l(lead);
leader_stac_profit(lead,grid,'lprofit')=q.l(lead) *(dbar/sum(j, q.l(j)))**(1/gamma) -c(lead)*q.l(lead) -
((beta(lead)/(1+beta(lead)))*L(lead)**(1/beta(lead)))*q.l(lead)**((1+beta(lead))/beta(lead));
leader_stac_profit(lead,grid,'nprofit')=q.l(lead) *(dbar/(q.l(lead)+sum(j$(not lead(j)), resultCour(j,'quantity'))))**(1/gamma) -c(lead)*q.l(lead) -
((beta(lead)/(1+beta(lead)))*L(lead)**(1/beta(lead)))*q.l(lead)**((1+beta(lead))/beta(lead));
*ninfo_stac(nonlead,grid,'lquantity')=sum(lead,q.l(lead));
leader_stac_profit(nonlead,grid,'lprofit')=obj.l(nonlead);
leader_stac_profit(nonlead,grid,'nprofit')= resultCour(nonlead,'quantity') *(dbar/(sum(lead,q.l(lead))+sum(j$(nonlead(j)), resultCour(j,'quantity'))))**(1/gamma)  -c(nonlead)*resultCour(nonlead,'quantity') -
((beta(nonlead)/(1+beta(nonlead)))*L(nonlead)**(1/beta(nonlead)))*resultCour(nonlead,'quantity')**((1+beta(nonlead))/beta(nonlead));
leader_stac_quantity(lead,grid,'lquantity')=q.l(lead);
leader_stac_quantity(i,grid,'nquantity')=q.l(i);
);


*-------------------------------------------------------------------------------------------

*-------------------------------------------------------------------------------------------
* CONTINUOUS BERTRAND MODEL - 2 or more firms
* Note, this model could use price elasticites to define the weights 'w' and be more
* realistic but we simply assign 'w' so as to not confuse the models.
* The prediction of the LINEAR price competition model does not have a meaningful
* comparison to the CES quantity competition models
$ontext
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

$offtext