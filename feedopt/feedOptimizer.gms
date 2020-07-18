*question about the objective function..

*$title Case Study : Feed optimizer
$ontext
+ Validate
+ Tile packing
+ Time window
+ Sponsored stories
+ Random testcase
+ Stochastic value
$offtext

*$offsymxref offsymlist offuelxref offuellist offupper

$if not set bH $set bH 100
$if not set bW $set bW 100
$if not set cA $set cA 750
$if not set tW $set tW 75
$if not set fD $set fD 1
$if not set rL $set rL 30


* VARIABLES

set
    BIGS    All stories available ;
$onexternalInput
set
    C       User behavior case (cannot change)/c1*c3/;
$offexternalInput

set StoryHeader /height 'Story height',width 'Story width',valc 'Story base score',time 'Time when story is available'
,sponsored 'Sponsored story'/;
$onexternalInput

table StoryInfo(BIGS<,StoryHeader)
   height  width  valc  time  sponsored  
s1 20      20     3     500   1          
s2 20      20     2     300   
;

parameter
  cscore(BIGS,C) 'Multiplier for story score at different scenarios'/s1*s2.c1*c3 3/;
scalar
     totTime   Total time/  1000 /
     bHeight   Interface height/  %bH% /
     bWidth    Interface width/  %bW% /
     checkAt   Feed retrieved time /  %cA% /
     window    Time window for freshness/  %tW% /
     oneD      'Dimension of story(1/2)' /  %fD% /
     sponsorRatio Sponsor ratio/ 0.3 /
     initRatio Initial ratio/ 0.2 /
;
$offexternalInput
set
    S(BIGS) Filtered stories
    
;
*Copy of storyinfo 
parameter
  height(BIGS) 'Stroy height'
  width2(BIGS) 'Story width'
  valc(BIGS) 'Story base score'
  time(BIGS) 'Time when story is available'
  sponsored(BIGS) 'Sponsored story';
height(BIGS)=StoryInfo(BIGS,'height');
width2(BIGS)=StoryInfo(BIGS,'width');
valc(BIGS)=StoryInfo(BIGS,'valc');
time(BIGS)=StoryINfo(BIGS,'time');
sponsored(BIGS)=StoryInfo(BIGS,'sponsored');

parameter
  data(BIGS,*),
  val(BIGS),
  width(BIGS)
;




alias(S,T);
alias(BIGS,BIGT);

positive variable
     x(BIGS,C)                 x val of story S in optimal feed
     y(BIGS,C)                 y val of story S in optimal feed
;

binary variable
     left(BIGS,BIGT,C)         S is on left of T
     top(BIGS,BIGT,C)          S is on top of T
     z(BIGS)                   S is chosen
     zc(BIGS,C)                S is chosen in case C
     check(BIGS,BIGT,C)        need to check only if both are selected
;

free variable
     value                   feed's value
;

* DATA

*execseed = 1 + gmillisec(jnow);
option seed = 42 ;




option reslim = %rL%;
$ontext
height(BIGS) = round(uniform(5,30));
width(BIGS)  = round(uniform(5,30));
valc(BIGS)    = height(BIGS)*width(BIGS)*uniform(1,3);
time(BIGS)   = round(uniform(1,totTime));
sponsored(BIGS)$(uniform(1,10) ge 7) = 1 ;
cscore(BIGS,C) = uniform(0,2);

$offtext

val(BIGS)  = valc(BIGS)*exp(1+(time(BIGS)-(checkAt-window))/totTime);

data(BIGS,"height") = height(BIGS);

width(BIGS)=width2(BIGS);


data(BIGS,"value")  = val(BIGS);
data(BIGS,"time")   = time(BIGS);

display cscore;



if ( oneD eq 1 ,
 width(BIGS) = bWidth;
);
data(BIGS,"width")  = width(BIGS);
parameter
     bigX,
     bigY
     smallM
     littleM
;

bigX = bWidth ;
bigY = bHeight ;
smallM = -1 ;

* FILTER

S(BIGS) = NO ;
S(BIGT)$(data(BIGT,"height") le bHeight
         and data(BIGT,"height") gt 0
         and data(BIGT,"width") le bWidth
         and data(BIGT,"width") gt 0
         and data(BIGT,"time") le checkAt
         and data(BIGT,"time") ge (checkAt-window) ) = YES;

display S;

* MODEL

equations
  objf,
  checkEqn(BIGS,BIGT,C),
  overlapEqn(BIGS,BIGT,C),
  horLimit(BIGS,BIGT,C),
  verLimit(BIGS,BIGT,C),
  sponsorEqn(C),
  horOrderEqn(BIGS,BIGT,C),
  verOrderEqn(BIGS,BIGT,C),
  zcEqn(BIGS,C),
  selectEqn
;

objf..
  value =E= SUM(S, z(S)*data(S,"value")) +
            SUM(C, 1/CARD(C)*(SUM(S, zc(S,C)*data(S,"value")*cscore(S,C)))) ;

zcEqn(S,C)..
  zc(S,C) =L= 1-z(S);

checkEqn(S,T,C)$(not diag(S,T))..
  z(S) + z(T) + zc(S,C) + zc(T,C) =L= check(S,T,C) + 1;

overlapEqn(S,T,C)..
  (left(S,T,C) + left(T,S,C)+ top(S,T,C) + top(T,S,C)) +
  smallM*check(S,T,C) =G= smallM + 1 ;

horLimit(S,T,C)..
  (x(S,C) - x(T,C)) + left(S,T,C)*bigX + bigX*check(S,T,C) =L=
  bigX + bigX - data(S,"width") ; 


verLimit(S,T,C)..
  (y(T,C) - y(S,C)) + top(S,T,C)*bigY  + bigY*check(S,T,C) =L=
  bigY + bigY - data(T,"height") ;

littlem = -totTime ;

horOrderEqn(S,T,C)..
  time(S) + littlem*left(S,T,C) =G= time(T) + littlem ;

verOrderEqn(S,T,C)..
  time(S) + littlem*top(S,T,C) =G= time(T) + littlem ;

sponsorEqn(C)..
  SUM(S$(sponsored(S)), z(S)+zc(S,C))  =L= sponsorRatio*SUM(S,z(S)+zc(S,C));

selectEqn..
  SUM(S, z(S)) =G= initRatio*SUM(C,1/CARD(C)*SUM(S,zc(S,C)));

model feedOptimizer / all /;
x.up(S,C)=bwidth-width(S);
y.up(S,C)=bheight-height(S);
* MIXED INTEGER PROGRAMMING
solve feedOptimizer maximizing value using mip ;

* POST PROCESS
set resHeader /type,window,value,x,y,z,time,height,width,totalwidth,totalheight,totalval,AreaCover,checkat/;
$onexternalOutput
table result(BIGS,C,resHeader) feed for all scenarios;
$offexternalOutput
result(S,C,"value")     = val(S);
result(S,C,"value")$(result(S,C,"z") eq 2 or result(S,C,"z")  eq 5 )   = cscore(S,C)*val(S);
result(S,C,"x")         = x.L(S,C);
result(S,C,"y")         = y.L(S,C);
result(S,C,"z")         = z.L(S)+zc.L(S,C)*2+sponsored(S)*3;
result(S,C,"height")    = height(S);
result(S,C,"width")     = width(S);
result(S,C,'totalwidth') =bwidth;
result(S,C,'totalheight')=bheight;
result(S,C,'totalval')=value.L;
result(S,C,'checkat')=checkat;
result(S,C,'time')=time(S);
result(S,C,'window')=window;
result(bigS,C,'areacover')$(S(BIGS))=(SUM(S$(z.L(S) > 0.1 or zc.L(S,C)> 0.1),
                   height(S)*width(S))/(bHeight*bWidth))*100;
result(S,C,'type')$(result(S,C,"z") ge 3)=3;
result(S,C,'type')$(result(S,C,"z") eq 1)=1;
result(S,C,'type')$(result(S,C,"z") eq 2)=2;
*result(S,"time")      = time(S);
$ontext
result(S,C,"x")$(Not x.L(S,C)) = EPS;
result(S,C,"y")$(Not y.L(S,C)) = EPS;
result(S,C,"z")$(Not z.L(S) and Not zc.L(S,C)) = EPS;
$offtext

display result;


display z.L;
display zc.L;

* END
