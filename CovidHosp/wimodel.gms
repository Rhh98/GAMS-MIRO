$ontext
Model for covid19 in WI at herc, d level

Use with python data setup:

python readdata.py doepfer  (or bond or prophet)
$offtext

$if not set firstday $set firstday 1
* 59 is Oct 29, 2020, 91 is Nov 30, 2020
$set firstday 61

$if not set mvfrac $set mvfrac 0.1
$if not set addbedfrac $set addbedfrac 0.2

$ontext
See hercmap and hercmapv2
herc_1 Northwest
herc_2 North Central
herc_3 Northwest
herc_4 Western
herc_5 South Central
herc_6 Fox Valley
herc_7 Southeast
$offtext

* read in from gdx
set i, day, headers;
parameter data(i,day,headers);
$gdxin resources.gdx
$load i day=d headers
$load data
$gdxin
set adj(i,i) /herc_1.(herc_2,herc_4), herc_2.(herc_3*herc_6),
	      herc_3.(herc_6,herc_7), herc_4.herc_5, herc_5.(herc_6,herc_7),
	      herc_6.herc_7,(herc_5*herc_7).acf/;
alias(i,j);
adj(j,i)$(adj(i,j) and not (sameas(j,'acf'))) = yes;

singleton set d1(day); d1(day) = yes$(day.ord eq %firstday%);
set d(day); d(day) = yes$(day.ord ge %firstday%);
alias(dk,day);

* set r resource / bed, icubed, staff, supply /;
$onExternalInput
scalar
  allowMoves / 1 /,
  sinfr "Staff infection rate" / 0.01 /,
  toacf "ACF transferral rate" / 0.01 /;
set r "Resource" / bed, icubed, staff /;
set ptype "Patient type" / cov, icu, oth, othicu /;
$offExternalInput

set sr(r) "space resources" / bed, icubed /;

parameter
  Init(r,i),
  extra(r,i);
$onExternalOutput
parameter
  patients(ptype,i,day);
$offExternalOutput

set
  bact(headers) / 'IBA_Med_Surgical', 'IBA_Neg_Flow_Iso', 'IBA_Intermediate' /,
  btot(headers) / 'Total_Med_Surgical_Beds', 'Total_Neg_Flow_Iso_Beds', 'Total_Intermediate_Beds' /;

patients('icu',i,d) = data(i,d,"Num_ICU_Covid_Patients");
patients('cov',i,d) = max(0,data(i,d,"Total_Num_Covid_Patients") - patients('icu',i,d));

* Other beds in use = Total Beds (not ICU) - Num_Covid - IBA Beds;
patients('oth',i,d) = max(0,sum(btot, data(i,d1,btot)) - patients('cov',i,d) - sum(bact, data(i,d1,bact)));
patients('othicu',i,d) = max(0,data(i,d1,'Total_ICU_Beds') - patients('icu',i,d) - data(i,d1,'IBA_ICU'));

Init('bed',i) = patients('cov',i,d1);
extra('bed',i) = patients('oth',i,d1);
Init('icubed',i) = patients('icu',i,d1);
extra('icubed',i) = patients('othicu',i,d1);
Init('staff',i) = patients('cov',i,d1) + patients('icu',i,d1);
extra('staff',i) = patients('oth',i,d1) + patients('othicu',i,d1);
extra('staff','acf') = 200;
extra('bed','acf') = 60;

variables obj;
positive variables
  alloc(r,i,day) 'number of resources in i at d',
  netincare(r,i,day) 'net number of patients',
  new(r,i,day) 'resource redeployed on d',
  moved(r,i,j,day) 'patients moved from i to j on d'
  unserved(r,i,day) 'resource overflow';

* constraints
equations
  defobj,
  req(r,i,day),
  limmovelo(r,i,i,day),
  limmoveup(r,i,i,day),
  movetoacf(i,day),
  defnet(r,i,day),
  resdef(r,i,day),
  staffdef(i,day),
  staffneed(i,day),
  deploy(r,i);

defobj..
  obj =e= sum((sr,i,d), unserved(sr,i,d))
  + 0.01*sum((sr,i,j,d)$adj(i,j), moved(sr,i,j,d))
  + 0.1*sum((r,i,day)$d(day), (card(day)+1-day.ord)*new(r,i,day));
  
defnet(sr,i,d)..
  netincare(sr,i,d) =e=
  patients('cov',i,d)$sameas(sr,'bed') +
  patients('icu',i,d)$sameas(sr,'icubed') +
  sum(adj(j,i), moved(sr,j,i,d)) - sum(adj(i,j), moved(sr,i,j,d));
  
req(sr,i,d)..
  netincare(sr,i,d) =l= 
    alloc(sr,i,d) + unserved(sr,i,d);
 
limmovelo(sr,j,i,day)$(adj(j,i) and d(day) and not sameas(i,'acf'))..
  moved(sr,j,i,day) =g= (1-%mvfrac%)*(moved(sr,j,i,day-1)-1);
  
limmoveup(sr,j,i,d)$(adj(j,i) and not sameas(i,'acf'))..
  moved(sr,j,i,d) =l= %mvfrac%*Alloc(sr,i,d);
  
movetoacf(j,d)$adj(j,'acf')..
  moved('bed',j,'acf',d) =e= toacf*Alloc('bed',j,d);

resdef(sr,i,day)$d(day)..
  alloc(sr,i,day)
  =e= Init(sr,i)$sameas(day,d1)
  + alloc(sr,i,day-1)$(not sameas(day,d1)) + new(sr,i,day);

staffdef(i,day)$d(day)..
  alloc('staff',i,day)
  =e= Init('staff',i)$sameas(day,d1) 
  + (1-sinfr)*alloc('staff',i,day-1)$(not sameas(day,d1)) + new('staff',i,day);
  
staffneed(i,d)..
  sum(sr, netincare(sr,i,d)) =l= alloc('staff',i,d);

deploy(r,i)..
  sum(d, new(r,i,d)) =l= extra(r,i);

model wic19log / all /;

moved.fx(sr,j,j,d) = 0;
if (allowMoves eq 0,
  moved.fx(sr,i,j,d) = 0;
);

$onecho > cplex.opt
lpmethod 4
* solutiontype 2
$offecho
wic19log.optfile=1;

solve wic19log using lp minimizing obj;

parameter totnewbeds(i);
totnewbeds(i) = sum((sr,d), new.l(sr,i,d));

parameter maxmoved(i,i);
maxmoved(j,i)$adj(j,i) = smax(day$(day.ord le 70), moved.l('bed',j,i,day));
maxmoved(j,i)$(adj(j,i) and maxmoved(j,i) le 1e-1) = 0;

$onExternalOutput
Parameters
  BedsAlloc(i,day),
  ICUBedsAlloc(i,day),
  PatientsInHosp(i,day),
  PatientsInICU(i,day),
  BedsAdded(i,day),
  ICUBedsAdded(i,day),
  PatientsMoved(i,j,day),
  StaffAlloc(i,day);
$offExternalOutput

set recent(day); recent(day) = yes$(day.ord gt card(day) - 40);

BedsAlloc(i,day)$recent(day) = Alloc.l('bed',i,day)/max(Alloc.l('bed',i,day),sum(btot, data(i,d1,btot))-sum(dk$(dk.ord le day.ord),new.l('staff',i,dk)));
ICUBedsAlloc(i,d)$(recent(d) and data(i,d1,'Total_ICU_Beds') gt 0) = Alloc.l('icubed',i,d)/max(Alloc.l('icubed',i,d),data(i,d1,'Total_ICU_Beds'));
PatientsInHosp(i,d)$recent(d) = netincare.l('bed',i,d);
PatientsInICU(i,d)$recent(d) = netincare.l('icubed',i,d);
BedsAdded(i,d)$recent(d) = new.l('bed',i,d);
ICUBedsAdded(i,d)$recent(d) = new.l('icubed',i,d);
PatientsMoved(i,j,d)$recent(d) = moved.l('bed',i,j,d);
StaffAlloc(i,day)$recent(day) = Alloc.l('staff',i,day);
