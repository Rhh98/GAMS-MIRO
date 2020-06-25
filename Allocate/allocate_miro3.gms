$ontext
Model for transporting kits to labs for testing
$offtext

$if not set prev $set prev /prv1 0.02 ,prv2 0.04, prv3 0.06/
*different prevalence level
option seed = 101;
set   coord location coordinates/ x 'latitude',y 'longititude' /;

set     prv prevalence ;

set   
      c centers  ,
      l labs  ;


$onExternalInput
parameter prv_val(prv<) prevalence setting %prev%;

parameter effic(prv) efficiency for different prevalences /prv1 0.9, prv2 0.9, prv3 0.95/;

scalar   T Maximal distance for transportation / 400 /;

parameter prv_weight(prv) importance of different prevalence to test
/prv1 1,prv2 2,prv3 4/;


$ontext
parameter prv_weight(prv)
/prv1 1,prv2 1,prv3 1,prv4 1,prv5 1/; 
$offtext

table lablocdata(l<,coord) locations of labs 
    x         y
l1 46.2803    -88.198933
l2 45.166269  -90.823687
;

table centerlocdata(c<,coord) locations of centers  
     x         y
c1   43.068039 -89.400023
c2   43.066346 -89.399723
c3   43.059693 -89.400572
c4   43.060141 -89.400869
c5   43.059289 -89.403949
c6   43.053027 -89.396262
c7   43.080097 -89.431956
c8   43.075206 -89.430384
c9   43.172779 -89.288660
c10  42.942796 -89.217877
c11  43.060646 -89.391069
c12  43.362928 -89.062184
c13  43.473625 -88.835509
c14  42.388094 -89.637222
;
$offExternalInput


$onExternalInput
parameter centerdata(c,prv) center collection /#c.prv1 500,#c.prv2 250,#c.prv3 125/;
$offExternalInput


parameter centerdata2(c,*,prv);
centerdata2(c,'bsz',prv)=1;
centerdata2(c,'kts',prv) = ceil(centerdata(c,prv)/centerdata2(c,'bsz',prv));
parameter dist(c,l) euclidean distances;
dist(c,l) = arccos(sin(lablocdata(l,'x')*pi/180)*sin(centerlocdata(c,'x')*pi/180)
+cos(lablocdata(l,'x')*pi/180)*cos(centerlocdata(c,'x')*pi/180)*
cos((lablocdata(l,'y')-centerlocdata(c,'y'))*pi/180))*6371.004;
display dist;
* s is batch size
set s batch size / 1, 2, 4, 8, 16, 32, 64 /;
set rnd round time (5 hours a time) / 5, 10, 15, 20 /;
$onExternalInput
parameter runsize(l) runsize of labs / #l 96/;
$offExternalInput

scalar offset, actrunsize;
alias(s,ss);
set metrics / total, negs, percKnown, unknown /;

parameter simres(*,*,rnd,*,metrics);
set okslots(*,*,rnd,prv);
parameter new_prev(*,*);
parameter svals(*);
svals(s) = s.val;

loop(l,
simres(l,s,'5',prv,'negs') = power(1-prv_val(prv),s.val)*runsize(l)*s.val;
simres(l,s,'5',prv,'unknown')=0;
simres(l,s,'5',prv,'unknown')$(s.val gt 1) = runsize(l)*s.val-simres(l,s,'5',prv,'negs');
simres(l,s,'5',prv,'total') = runsize(l)*s.val;
simres(l,s,'5',prv,'percKnown') = 100-simres(l,s,'5',prv,'unknown')/simres(l,s,'5',prv,'total')*100;


$ontext
* could put these in too
loop(s$(s.val le 4),
  simres(l,s,'10',metrics) = 2*simres(l,s,'5',metrics);
  simres(l,s,'10','percKnown') = simres(l,s,'5','percKnown');
  simres(l,s,'15',metrics) = 3*simres(l,s,'5',metrics);
  simres(l,s,'15','percKnown') = simres(l,s,'5','percKnown');
  simres(l,s,'20',metrics) = 4*simres(l,s,'5',metrics);
  simres(l,s,'20','percKnown') = simres(l,s,'5','percKnown');
);
$offtext
simres(l,s,'10',prv,'unknown')$(simres(l,s,'5',prv,'unknown') gt 0 and simres(l,s,'5',prv,'percKnown') < 100*effic(prv))=0;
loop((prv,s)$(simres(l,s,'5',prv,'unknown') gt 0 and simres(l,s,'5',prv,'percKnown') < 100*effic(prv)),
  new_prev(prv,s) = prv_val(prv)*simres(l,s,'5',prv,'total')/simres(l,s,'5',prv,'unknown');
  offset = s.ord - sum(ss$(simres(l,ss,'5',prv,'total') le simres(l,s,'5',prv,'unknown')), 1);
  simres(l,s,'10',prv,'total') = simres(l,s,'5',prv,'total');
  if (offset ge s.ord - 1,
    actrunsize = min(runsize(l),simres(l,s,'5',prv,'unknown'));
    simres(l,s,'10',prv,'negs') = min((1-prv_val(prv))*simres(l,s,'10',prv,'total'),simres(l,s,'5',prv,'negs') + actrunsize*(1-new_prev(prv,s)));
*The min here is not needed?  
    simres(l,s,'10',prv,'unknown') = simres(l,s,'5',prv,'unknown') - actrunsize;
  else
    simres(l,s,'10',prv,'negs') = min((1-prv_val(prv))*simres(l,s,'10',prv,'total'),simres(l,s,'5',prv,'negs') + power(1-new_prev(prv,s),svals(s-offset))*runsize(l)*svals(s-offset));
    simres(l,s,'10',prv,'unknown') = simres(l,s,'10',prv,'total') - simres(l,s,'10',prv,'negs');
  );
  simres(l,s,'10',prv,'percKnown') = 100-simres(l,s,'10',prv,'unknown')/simres(l,s,'10',prv,'total')*100;
);
simres(l,s,'15',prv,'unknown')$(simres(l,s,'10',prv,'unknown') gt 0 and simres(l,s,'10',prv,'percKnown') < 100*effic(prv))=0;
loop((prv,s)$(simres(l,s,'10',prv,'unknown') gt 0 and simres(l,s,'10',prv,'percKnown') < 100*effic(prv)),
$ontext
  if (simres(l,s,'10',prv,'percKnown') gt effic(prv),
    simres(l,s,'15',prv,metrics) = simres(l,s,'5',prv,metrics) + simres(l,s,'10',prv,metrics);
    simres(l,s,'15',prv,'percKnown') = simres(l,s,'15',prv,'negs')/simres(l,s,'15',prv,'total')*100;
    simres(l,s,'20',prv,metrics) = 2*simres(l,s,'10',prv,metrics);
    simres(l,s,'20',prv,'percKnown') = simres(l,s,'20',prv,'negs')/simres(l,s,'20',prv,'total')*100;
  else
$offtext
    new_prev(prv,s) = prv_val(prv)*simres(l,s,'10',prv,'total')/simres(l,s,'10',prv,'unknown');
    offset = s.ord - sum(ss$(simres(l,ss,'5',prv,'total') le simres(l,s,'10',prv,'unknown')), 1);
    simres(l,s,'15',prv,'total') = simres(l,s,'5',prv,'total');
    if (offset ge s.ord - 1,
      actrunsize = min(runsize(l),simres(l,s,'10',prv,'unknown'));
      simres(l,s,'15',prv,'negs') = min((1-prv_val(prv))*simres(l,s,'15',prv,'total'),simres(l,s,'10',prv,'negs') + actrunsize*(1-new_prev(prv,s)));
      simres(l,s,'15',prv,'unknown') = simres(l,s,'10',prv,'unknown') - actrunsize;
    else
      simres(l,s,'15',prv,'negs') = min((1-prv_val(prv))*simres(l,s,'15',prv,'total'),simres(l,s,'10',prv,'negs') + power(1-new_prev(prv,s),svals(s-offset))*runsize(l)*svals(s-offset));
      simres(l,s,'15',prv,'unknown') = simres(l,s,'15',prv,'total') - simres(l,s,'15',prv,'negs');
    );
    simres(l,s,'15',prv,'percKnown') = 100-simres(l,s,'15',prv,'unknown')/simres(l,s,'15',prv,'total')*100;
);

simres(l,s,'20',prv,'unknown')$(simres(l,s,'15',prv,'unknown') gt 0 and simres(l,s,'15',prv,'percKnown') < 100*effic(prv))=0;
loop((prv,s)$(simres(l,s,'15',prv,'unknown') gt 0 and simres(l,s,'15',prv,'percKnown') < 100*effic(prv)),
  new_prev(prv,s) = prv_val(prv)*simres(l,s,'15',prv,'total')/simres(l,s,'15',prv,'unknown');
  offset = s.ord - sum(ss$(simres(l,ss,'5',prv,'total') le simres(l,s,'15',prv,'unknown')), 1);
  simres(l,s,'20',prv,'total') = simres(l,s,'5',prv,'total');
  if (offset ge s.ord - 1,
    actrunsize = min(runsize(l),simres(l,s,'15',prv,'unknown'));
    simres(l,s,'20',prv,'negs') = min((1-prv_val(prv))*simres(l,s,'20',prv,'total'),simres(l,s,'15',prv,'negs') + actrunsize*(1-new_prev(prv,s)));
    simres(l,s,'20',prv,'unknown') = simres(l,s,'15',prv,'unknown') - actrunsize;
  else
    simres(l,s,'20',prv,'negs') = min((1-prv_val(prv))*simres(l,s,'20',prv,'total'),simres(l,s,'15',prv,'negs') + power(1-new_prev(prv,s),svals(s-offset))*runsize(l)*svals(s-offset));
    simres(l,s,'20',prv,'unknown') = simres(l,s,'20',prv,'total') - simres(l,s,'20',prv,'negs');
  );
  simres(l,s,'20',prv,'percKnown') = 100-simres(l,s,'20',prv,'unknown')/simres(l,s,'20',prv,'total')*100;
);
);
okslots(l,s,rnd,prv) = yes$(simres(l,s,rnd,prv,'percKnown')/100 ge effic(prv));


display simres, okslots;

parameter cap(l)
* 4 x 5 hrs slots in one day!
;


cap(l) = 4*5;

positive variables
  x(prv,c,l) kits moved from c to l of prevalence prv,
  totinl(prv,l) kits at lab l of prevalences prv,
  numBat(prv,l,s) number of batches in lab l;
  
  
integer variables
  
  numofbs(l,s,rnd,prv) number of batches of size in timeslot,
  useX(l),
  extras(l) kits left over in lab l of prevalence prv;
  extras.up(l)=runsize(l)*4;;
variables obj;
$ontext
integer variables
extraTrans(prv,l);
extraTrans.up(prv,l)=runsize(l)*4;

equation defExtraTrans(l);

defExtraTrans(l)..
sum(prv,extraTrans(prv,l)) =l= sum(okslots(l,s,rnd,prv),numofbs(l,s,rnd,prv)*runsize(l)*s.val-numBat(prv,l,s)*s.val)+runsize(l)*useX(l)-sum(prv,extras(l,prv));
$offtext

equations
  supply(prv,c), transport(prv,l), balance(prv,l), relax(l,s,prv), logEx1(l),logEx2(l)
*  ,log(l)
,log1(l), log2(l), log3(l), log4(l), log5(l), log6(l)
, defobj
 ;

supply(prv,c)..
  sum(l, x(prv,c,l)) =l= centerdata2(c,'kts',prv);

transport(prv,l)..
  totinl(prv,l) =e= sum(c, x(prv,c,l));

balance(prv,l)..
  totinl(prv,l) =e= sum(okslots(l,s,rnd,prv), numBat(prv,l,s)*s.val);
  
relax(l,s,prv)..
 numBat(prv,l,s) =l= sum(okslots(l,s,rnd,prv),numofbs(l,s,rnd,prv)*runsize(l));


* could do runsize(l)-1 here so only use the slot partially with useX
logEx1(l)..
  sum(prv,extras(l)) =l= runsize(l)*useX(l);
  
logEx2(l)..
  extras(l) =l= sum(okslots(l,s,rnd,prv),s.val*numBat(prv,l,s)*(1-simres(l,s,rnd,prv,'percKnown')/100)); 
*log(l)..
* useX(l) + sum(okslots(l,s,'5',prv), numofbs(l,s,'5',prv)) + 2*sum(okslots(l,s,'10',prv), numofbs(l,s,'10',prv)) 
* +3*sum(okslots(l,s,'15',prv), numofbs(l,s,'15',prv))+4*sum(okslots(l,s,'20',prv), numofbs(l,s,'20',prv))=l=4;


log1(l)..
 sum(okslots(l,s,'15',prv), numofbs(l,s,'15',prv)) + sum(okslots(l,s,'20',prv), numofbs(l,s,'20',prv)) =l= 1;

log2(l)..
  sum(okslots(l,s,'10',prv), numofbs(l,s,'10',prv)) + 2*sum(okslots(l,s,'20',prv), numofbs(l,s,'20',prv)) =l= 2;

log3(l)..
  useX(l)+sum(okslots(l,s,'5',prv), numofbs(l,s,'5',prv)) +
  4*sum(okslots(l,s,'20',prv), numofbs(l,s,'20',prv)) =l= 4;

log4(l)..
 useX(l)+sum(okslots(l,s,'5',prv), numofbs(l,s,'5',prv)) +
  3*sum(okslots(l,s,'15',prv), numofbs(l,s,'15',prv)) =l= 4;
$ontext
log5(l)..
  useX(l)+2*sum(okslots(l,s,'10',prv), numofbs(l,s,'10',prv))
  + 3*sum(okslots(l,s,'15',prv), numofbs(l,s,'15',prv)) =l= 4;
$offtext
log5(l)..
sum(okslots(l,s,'10',prv), numofbs(l,s,'10',prv))
  + 2*sum(okslots(l,s,'15',prv), numofbs(l,s,'15',prv)) =l= 2;
log6(l)..
 useX(l) + sum(okslots(l,s,'5',prv), numofbs(l,s,'5',prv)) +
 2*sum(okslots(l,s,'10',prv), numofbs(l,s,'10',prv)) =l= 4;
$ontext
log(l)..
useX(l) + sum(okslots(l,s,'5',prv), numofbs(l,s,'5',prv)) + 2*sum(okslots(l,s,'10',prv), numofbs(l,s,'10',prv))
+ 3*sum(okslots(l,s,'15',prv), numofbs(l,s,'15',prv))
+4*sum(okslots(l,s,'20',prv), numofbs(l,s,'20',prv)) =l= 4;
$offtext

*defobj..
*  obj =e= sum(l, sum(okslots(l,s,rnd,prv), simres(l,s,rnd,prv,'negs')*numofbs(prv,l,s,rnd)) + sum(prv,(1-prv_val(prv))*extras(prv,l)));

defobj..
obj=e= sum(l, sum(prv, prv_weight(prv)*(sum(okslots(l,s,rnd,prv),simres(l,s,rnd,prv,'percKnown')/100*s.val*numBat(prv,l,s))))+extras(l));
model vivak /all/;
useX.up(l)=4;
numofbs.up(l,s,rnd,prv) = floor(4*5/rnd.val);
*numofbs.fx(l,s,rnd,prv)$(not okslots(l,s,rnd,prv))=0;
extras.up(l)=runsize(l)*4;
x.fx(prv,c,l)$(dist(c,l) gt T) = 0;

* write option file (edit in Studio to see options in detail)
$onecho > cplex.opt
lpmethod 4
$offecho
* Turn on=1/off=0 option file for particular model
vivak.optfile = 0;
* can change solver and optfile reading in command box above

vivak.optcr = 1e-3;
solve vivak using mip max obj;

set opr /bs batchsize, rn round number, noto 'number of the operation', p prevalence,nb number of batches,ep extra position in this round,er extra round for single kits/,
    allocateHeader /  val the number of kits from c to l,latl latitude of labs, lonl longititude of labs, latc latitude of centers,
     lonc longitude of centers/
;     
*kitsClass kits for different round/normal,extra/


set numofop 'operation index' /opr1*opr4/;
$onExternalOutput
table allocate(c,l,prv,allocateHeader) 'allocate strategy';
allocate(c,l,prv,'latl')=lablocdata(l,'x');
allocate(c,l,prv,'lonl')=lablocdata(l,'y');
allocate(c,l,prv,'latc')=centerlocdata(c,'x');
allocate(c,l,prv,'lonc')=centerlocdata(c,'y');
allocate(c,l,prv,'val')=x.l(prv,c,l);
parameter kitinl(l,prv) Kits to test in labs l;
kitinl(l,prv)=sum(okslots(l,s,rnd,prv),numBat.l(prv,l,s)*s.val);
*kitinl(l,'extra','all')=sum(prv,extraTrans.l(prv,l));

table operation(l,numofop,opr) operation in lab l(batch size);

parameter unmet(c)'Kits left in centers';
unmet(c) = sum(prv,centerdata2(c,'kts',prv) - sum(l, x.l(prv,c,l)));

scalar alltest, pcplus,leftover;
alltest = sum((l,prv), totinl.l(prv,l));
leftover = round(sum(l, sum(prv, (sum(okslots(l,s,rnd,prv),(simres(l,s,rnd,prv,'unknown'))*numofbs.l(l,s,rnd,prv))))));
pcplus = sum(l, sum(prv, (sum(okslots(l,s,rnd,prv),(simres(l,s,rnd,prv,'unknown'))*numofbs.l(l,s,rnd,prv)))))/max(1e-4,alltest)*100;
$offExternalOutput
scalar opt 'count the number of operation';
loop(l, opt=0;
loop((s,rnd,prv)$(numofbs.l(l,s,rnd,prv) gt 0),
opt=opt+1;
operation(l,numofop,'bs')$(ord(numofop)=opt)=s.val;
operation(l,numofop,'rn')$(ord(numofop)=opt)=rnd.val/5;
operation(l,numofop,'noto')$(ord(numofop)=opt)=numofbs.l(l,s,rnd,prv);
operation(l,numofop,'p')$(ord(numofop)=opt)=prv_val(prv);
operation(l,numofop,'nb')$(ord(numofop)=opt)=ceil(numBat.l(prv,l,s));
operation(l,numofop,'ep')$(ord(numofop)=opt)=numofbs.l(l,s,rnd,prv)$(okslots(l,s,rnd,prv))*runsize(l)-ceil(numBat.l(prv,l,s));
);
opt=opt+1;
operation(l,numofop,'er')$(useX.l(l) gt 0 and ord(numofop)=opt)=useX.l(l);
);
display unmet;