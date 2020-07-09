$ontext
TSP with Pataki modifications
$offtext
$eolcom //
set city /
$include set.csv
/
;
alias(city,i,j);
set Header /l_lat,l_long,select/;
set Constraints /'Dynamic SEC', 'Positional Constraints'/;
$onexternalInput
table CityInfo(city,Header)
$onDelim
$include capitals.csv
$offDelim
;
Singleton Set Constraint(Constraints) 'selected model Constraint type' / 'Dynamic SEC' /;
$offexternalInput

set select(city) Selected capitals;
select(city)$(CityInfo(city,'select') eq 1)=yes;
scalar count /0/;
parameter OrderVal(i);
loop(select,count=count+1;OrderVal(select)=count;);

alias(select,k)
table  dist(i,j)  "distances" ;
dist(i,j)$(not sameas(i,j))=arccos(sin(CityInfo(i,'l_lat')*pi/180)*sin(CityInfo(j,'l_lat')*pi/180)
+cos(CityInfo(i,'l_lat')*pi/180)*cos(CityInfo(j,'l_lat')*pi/180)*
cos((CityInfo(j,'l_long')-CityInfo(i,'l_long'))*pi/180))*6371.004;
variables x(i,j);
binary variables x;
free variable obj;
equations defobj, assign1(j), assign2(i);

defobj..
obj =e= sum((select,k)$(not sameas(select,k)), dist(select,k) * x(select,k));

assign1(select)..
sum(k$(not sameas(select,k)), x(select,k)) =e= 1;

assign2(select)..
sum(k$(not sameas(select,k)), x(k,select)) =e= 1;
x.fx(select,select) = 0;

positive variables u(i) ;
equations mtz(i,j);
mtz(select,k)$(OrderVal(select) > 1 and OrderVal(k) > 1 )..
  u(select) - u(k) + 1 =L= (card(select) - 1) * (1 - x(select,k)) ;


Set cc    Subtour elimination cuts /c1*c500/
    c(cc) Active cuts; c(cc)=no;

Parameters
    cutcoeff(cc,i,j) coeffients for the subtour elimination cuts
    rhs(cc)          right hand side for the subtour elimination cuts;
cutcoeff(c,i,j)=0; rhs(c)=0;

Equations cut(cc) dynamic subtour elimination cuts;

cut(c).. sum((select,k), cutcoeff(c,select,k)*x(select,k)) =l= rhs(c);

model tspPC /defobj,assign1,assign2,mtz/;
model tspSEC /defobj,assign1,assign2,cut/;
option optcr=0, limrow=0, limcol=0, solprint=off;

* Solve without subtour elimination constraints
if( sameAs(constraint,'Positional Constraints'),
solve tspPC min obj using mip;
else
solve tspSEC min obj using mip);


set t            tours /t1*t25/
    ttour(i,j,t)  subtours
    from(i)      contains always one element: the from swath
    next(j)      contains always one element: the to swath
    visited(i)   flag whether a swath is already visited
    tt(t)        contains always one element: the current subtour
    curc(cc)     contains always one element: the current SE cut /c1/;
scalar goon      go on flag used to control loop /1/;




while(goon=1,
  // Start tour in first swath
  from(select) = no; tt(t) = no; ttour(i,j,t)=no; visited(i)=no;
  from(select)$(OrderVal(select) eq 1) = yes; tt('t1') = yes; x.l(i,j) = round(x.l(i,j));
  while (card(from),
     // find swath visited after swath 'from'
     next(i)=no; loop((from,select)$x.l(from,select), next(select) = yes);
     ttour(from,next,tt) = yes;   // store in table
     
     visited(from) = yes;        // mark swath 'from' as visited
     from(select) = next(select);
     if (sum(visited(next),1)>0, // if we are back at the start of the tour
       // find starting point of new subtour
       tt(t) = tt(t-1); from(select) = no;
       goon=1; loop(select$(not visited(select) and goon), from(select) = yes; goon=0);
     )
  );
  display ttour;

  if (tt('t2'), goon = 0; // just one tour -> stop
  else                    // else: introduce cut(s)
    // in case of two tours, we get complement cuts so eliminate the long tour
    if (tt('t3'),
      if (sum(ttour(select,k,'t1'),1) < sum(ttour(select,k,'t2'),1),
        ttour(select,k,'t2') = no;
      else
        ttour(select,k,'t1') = ttour(select,k,'t2');
        ttour(select,k,'t2') = no;
      );
      tt('t2') = yes;
    );
    goon = 1; loop(t$goon,
      rhs(curc)=-1;
      visited(select) = sum(ttour(select,k,t),1);
      loop(ttour(select,k,t),
        cutcoeff(curc,select,visited) = 1;
        
        rhs(curc) = rhs(curc) + 1;
      );
      c(curc) = yes;
      curc(cc) = curc(cc-1);
      goon = card(curc) and not tt(t+1);
    );
    abort$(card(curc)=0) 'set cc too small';
    solve tspSEC using mip minimizing obj;
    if (card(curc),goon=1;);
  );
);

*u.fx(select)$(OrderVal(select) eq 1) = 0;
$ontext
option optcr = 1e-3;
$onecho > cplex.opt
lpmethod 4
$offecho
tsp.optfile = 1;
$offtext
display obj.l;
set tour(i,j) ;

tour(select,select) = no;
tour(select,k)$(x.l(select,k) > 0.01) = yes ;
set TourHeader /status 'whether selected',dist 'distance',lat1 'latitude1',long1 'longitude1',lat2 'latitude2',long2 'longitude2'/;
$OnexternalOutput
table TourT(i,j,TourHeader);
TourT(select,k,'status')$tour(select,k)=1;
TourT(i,j,'status')$(not tour(i,j))=-1;
TourT(i,j,'dist')=dist(i,j);
TourT(i,j,'lat1')=CityInfo(i,'l_lat');
TourT(i,j,'long1')=CityInfo(i,'l_long');
TourT(i,j,'lat2')=CityInfo(j,'l_lat');
TourT(i,j,'long2')=CityInfo(j,'l_long');
scalar TotalCost Total Cost;
TotalCost=obj.l;
$offExternalOutput
* Just print the tour in a simple way
option tour:0:0:1 ;

display tour;
