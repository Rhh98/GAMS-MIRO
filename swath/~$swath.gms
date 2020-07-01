$Title Mission Planning for Synthetic Aperture Radar Surveillance (SWATH,SEQ=325)

$Ontext

The Microwave Radar Division of the Defence Sciences and Technology
Organisation employs synthetic aperture radar to obtain
high-resolution images of selected ground targets. It uses this
device, mounted on an aircraft, to scan up to 20 rectangular regions
called swaths to obtain images with resolutions down to one
meter. Missions consisting of a designated sequence of swaths and
flight paths are planned using mapping software. Previously DSTO had
been determining the best tours for missions by visually tracking
possible swath sequences from a starting base to an ending base. This
method was time consuming and did not guarantee optimality interms of
distance traveled. We developed optimization software tools to plan
mission tours more efficiently. DSTO can now plan missions with up to
20 swaths in a few seconds, rather than the hour it took using the
visual approach. Proposed tour lengths show an average improvement of
15 percent over those manually produced. The software incorporates
methods for dealing with the operational problems of no-fly zones and
shadowing associated with images.


Panton, D M, and Elbers, A W, Mission Planning for Synthetic Aperture
Radar Surveillance. Interfaces 29, 2 (1999), 73-88.

$Offtext

Set s          swaths                         / s0*s20 /
    n          nodes                          / n1*n4 /
    sx(s,n)    valid swath node combinations  / s0.n1, (s1*s20).set.n /
    a(s,n,s,n) arcs;
Alias (s,i,j), (n,np);
Parameter l(s,n,s,n) arc length;
$gdxin swathdat.gdx
$load l

a(sx,s,n) = l(sx,s,n);

* TSP Type model
Variable
   x(s,n,s,n)  TSP tour between nodes
   y(s,s)      TSP tour between swath
   z           objective;
Binary Variables x,y;

Equations
   defobj       Objective
   defone(s)    one entering arc per swath
   defbal(s,n)  flow balance
   defy(s,s)    TSP swath tour determined by TSP node tour;

defobj..          z =e= sum(a, l(a)*x(a));

defone(s)..       sum(a(sx,s,n), x(a)) =e= 1;

defbal(sx)..      sum(a(s,n,sx), x(a)) - sum(a(sx,s,n), x(a)) =e= 0;

defy(i,j)$(not sameas(i,j))..  y(i,j) =e= sum(a(i,n,j,np), x(a));

$if not set orgse $goto secuts
* Original subtour elimination constraint from the SWATH MIPLIB 2003 instance
Positive Variable u(s);
Equation
   se(s,s) subtour elimination;

se(i,j)$(ord(i)>1 and ord(j)>1 and not sameas(i,j))..
  u(i) - u(j) + card(s)*y(i,j) =l= card(s)-1;
u.fx('s0') = 0;
$goto solve

$label secuts
Set cc    Subtour elimination cuts /c1*c150/
    c(cc) Active cuts; c(cc)=no;

Parameters
    cutcoeff(cc,s,s) coeffients for the subtour elimination cuts
    rhs(cc)          right hand side for the subtour elimination cuts;
cutcoeff(c,s,s)=0; rhs(c)=0;

Equations cut(cc) dynamic subtour elimination cuts;

cut(c).. sum((i,j), cutcoeff(c,i,j)*y(i,j)) =l= rhs(c);

$label solve
model swath /all/;

option optcr=0, limrow=0, limcol=0, solprint=off;

* Solve without subtour elimination constraints
solve swath min z using mip;

$if set orgse $exit

set t            tours /t1*t25/
    tour(i,j,t)  subtours
    from(i)      contains always one element: the from swath
    next(j)      contains always one element: the to swath
    visited(i)   flag whether a swath is already visited
    tt(t)        contains always one element: the current subtour
    curc(cc)     contains always one element: the current SE cut /c1/;
scalar goon      go on flag used to control loop /1/;

$eolcom //
while(goon=1,
  // Start tour in first swath
  from(i) = no; tt(t) = no; tour(i,j,t)=no; visited(i)=no;
  from('s0') = yes; tt('t1') = yes; y.l(i,j) = round(y.l(i,j));
  while (card(from),
     // find swath visited after swath 'from'
     next(i)=no; loop((from,i)$y.l(from,i), next(i) = yes);
     tour(from,next,tt) = yes;   // store in table
     visited(from) = yes;        // mark swath 'from' as visited
     from(j) = next(j);
     if (sum(visited(next),1)>0, // if we are back at the start of the tour
       // find starting point of new subtour
       tt(t) = tt(t-1); from(i) = no;
       goon=1; loop(i$(not visited(i) and goon), from(i) = yes; goon=0);
     )
  );
  display tour;

  if (tt('t2'), goon = 0; // just one tour -> stop
  else                    // else: introduce cut(s)
    // in case of two tours, we get complement cuts so eliminate the long tour
    if (tt('t3'),
      if (sum(tour(i,j,'t1'),1) < sum(tour(i,j,'t2'),1),
        tour(i,j,'t2') = no;
      else
        tour(i,j,'t1') = tour(i,j,'t2');
        tour(i,j,'t2') = no;
      );
      tt('t2') = yes;
    );
    goon = 1; loop(t$goon,
      rhs(curc)=-1;
      visited(i) = sum(tour(i,j,t),1);
      loop(tour(i,j,t),
        cutcoeff(curc,i,visited) = 1;
        rhs(curc) = rhs(curc) + 1;
      );
      c(curc) = yes;
      curc(cc) = curc(cc-1);
      goon = card(curc) and not tt(t+1);
    );
    abort$(card(curc)=0) 'set cc too small';
    solve swath using mip minimizing z; goon = 1;
  );
);
