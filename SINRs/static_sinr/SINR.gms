set n  input and output size ;
$onexternalInput
table G(n<,*) G_ij: gain from transmitter j to receiver i
   n1  n2  n3  n4  n5
n1 1   0.1 0.2 0.1 0
n2 0.1 1   0.1 0.1 0
n3 0.2 0.1 2   0.2 0.2
n4 0.1 0.1 0.2 1   0.1
n5 0   0   0.2 0.1 1
;

scalar P transmitter power /0.5/;
parameter sigma(n) /set.n 0.01/ ;
$offexternalInput
alias(n,n1);

variables z,q(n),FixU(n,n),u(n,n),u3(n,n),FixV(n),v(n),v3(n);
Equations SmallestS(n),TransPower,ConeSU(n,n),ConeDU(n),ConeV(n),defSu3(n,n),defDu3(n),defv3(n);

defSu3(n,n1)$(not sameas(n,n1) and G(n,n1) > 0)..
u3(n,n1)=e= z+q(n1)-q(n)+log(G(n,n1)/G(n,n));

ConeSU(n,n1)$(not sameas(n,n1) and G(n,n1) > 0)..
u(n,n1) =g= FixU(n,n1)*exp(u3(n,n1)/FixU(n,n1));

defDu3(n)$(sigma(n) >0)..
u3(n,n) =e= z-q(n)+log(sigma(n)/G(n,n));

ConeDU(n)$(sigma(n) >0)..
u(n,n) =g= FixU(n,n)*exp(u3(n,n)/FixU(n,n));

defv3(n)..
v3(n) =e= q(n)-log(P);

ConeV(n)..
v(n) =g= FixV(n)*exp(v3(n)/FixV(n));

SmallestS(n)..
sum(n1$(G(n,n1)>0),u(n,n1)) =l= 1;

TransPower..
sum(n$(sigma(n) > 0),v(n)) =l= 1;

FixU.fx(n,n1)=1;
FixV.fx(n)=1;
u.lo(n,n1)=0;
v.lo(n)=0;
model MaxWorst /SmallestS,TransPower,ConeSU,ConeDU,ConeV,defSu3,defDu3,defv3/;
option nlp=mosek;
solve MaxWorst using nlp maximizing z;

set Header /MaxWorst,MaxAverage/;
$onexternalOutput
table power(n,Header) power;
table s(n,Header) SINR;
$offExternalOutput
power(n,'MaxWorst')=exp(q.l(n));
s(n,'MaxWorst')=G(n,n)*power(n,'MaxWorst')/(sum(n1$(not sameas(n,n1)),G(n,n1)*power(n1,'MaxWorst'))+sigma(n));

variables zz(n),obj;
Equations defSU2(n,n),defDU2(n),defobj;

defSu2(n,n1)$(not sameas(n,n1) and G(n,n1) > 0)..
u3(n,n1)=e= zz(n)+q(n1)-q(n)+log(G(n,n1)/G(n,n));

defDu2(n)$(sigma(n) >0)..
u3(n,n) =e= zz(n)-q(n)+log(sigma(n)/G(n,n));


defobj..
obj =e= sum(n,zz(n));

model Average /SmallestS,TransPower,ConeSU,ConeDU,ConeV,defSu2,defDu2,defv3,defobj/;
solve Average using nlp maximizing obj;
power(n,'MaxAverage')=exp(q.l(n));
s(n,'MaxAverage')=G(n,n)*power(n,'MaxAverage')/(sum(n1$(not sameas(n,n1)),G(n,n1)*power(n1,'MaxAverage'))+sigma(n));
