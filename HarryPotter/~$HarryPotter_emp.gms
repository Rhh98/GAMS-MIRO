
scalar
lam 'L2 regularization weight of learner' /0.001/,
sigma 'RBF kernel bandwidth' /0.5/
;
$ontext
 ----------------------------------------
 Generate "dirty" training data. 
 that is, we will plant some "historical bias" 
 in the form of labels: the Ministry of Magic refused to hire
 muggle-born graduates with high edcuation.
 
data points are on a uniform grid, then dithered with a Guassian.
x_1=magic heritage; x_2=education
$offtext

set n 'training set' /1*100/,
aspect /Heritage,education/;
*training data
parameter
X_Train(n,aspect)  'training data'
;
alias(n,n1,n2,n3);
X_Train(n,'Heritage')=0.1*ceil(n.val/10)-0.05;
X_Train(n,'Education')=0.1*(n.val-floor(n.val/10)*10)-0.05;
display X_Train;
*Training data dithered with a Guassian
X_Train(n,'Heritage')=X_Train(n,'Heritage')+0.03*normal(0,1);
X_Train(n,'Education')=X_Train(n,'Education')+0.03*normal(0,1);

*the noiseless 'desired' label obeys y_E=sign(X_E-0.5)
parameter y_E(n);
y_E(n)$(X_Train(n,'Education')-0.5 eq 0)=0;
y_E(n)$(X_Train(n,'Education')-0.5 gt 0)=1;
y_E(n)$(X_Train(n,'Education')-0.5 lt 0)=-1;
*Contamination
*The historically based rule is
parameter y_Con(n);
y_Con(n)=y_E(n);
y_Con(n)$((X_Train(n,'Education') lt (4*sqr(X_Train(n,'Heritage')-0.5)+0.5))
 and (X_Train(n,'Heritage') lt 0.5) )=-1;
 


$ontext
% w is the debugging optimization variable, the special case for delta in
% the binary classification case.
$offtext


variables w(n);
parameter w_true(n)
;
w.l(n)=0;
w.lo(n)=0;
w.up(n)=1;
w_true(n)=0;
w_true(n)$(y_Con(n) ne y_E(n))=1;

*alpha's are the dual parameters in kernel logistic regression to be learned.
parameter K(n,n) 'Kernel function';
K(n,n1)=-(sqr(X_Train(n,'Heritage'))+sqr(X_Train(n,'Education')))-(sqr(X_Train(n1,'Heritage'))+sqr(X_Train(n1,'Education')))+
2*(X_Train(n,'Heritage')*X_Train(n1,'Heritage')+X_Train(n,'Education')*X_Train(n1,'Education'));
K(n,n1)=exp(K(n,n1)/(2*sigma*sigma));

*Binary kernel logistic ridge regression


*Lower level problem
variables alpha(*),obj,log_l(n),log_l2(n),obj_sub;
equations defobj,deflog_l(n),deflog_l2(n),defobj_sub;

defobj_sub..
obj_sub =e= lam/2*sum(n,sum(n1,K(n,n1)*alpha(n)*alpha(n1)))
    + 1/card(n)*sum(n,(1-w.l(n))*log_l(n)+w.l(n)*log_l2(n));

deflog_l(n)..
log_l(n) =e=  log(1+exp(-y_Con(n)*(sum(n1,K(n,n1)*alpha(n1))+alpha('0'))));

deflog_l2(n)..
log_l2(n) =e= log(1+exp(y_Con(n)*(sum(n1,K(n,n1)*alpha(n1))+alpha('0'))));

defobj..
obj =e= lam/2*sum(n,sum(n1,K(n,n1)*alpha(n)*alpha(n1)))
    + 1/card(n)*sum(n,(1-w(n))*log_l(n)+w(n)*log_l2(n));

alpha.l(n)=0;
model submodel /defobj_sub,deflog_l,deflog_l2/;
solve submodel using nlp minimizing obj_sub;

*generated trusted data--------------------
set Header;
;
$onexternalInput
table Trust_data(Header<,aspect)
      heritage   education
1     0.3        0.4
2     0.2        0.6
;

parameter Trust_label(Header) /1 -1,2 1/;
$offexternalInput
parameter c(header) /set.header 100/;

*Generating contour by kernel logistic regression
parameter Z(n,n) 'label of testing data (0.01:0.01:1,0.01:0.01,1)',
temp(n,n,n)  'temporary value',
e(n,n), d(n,n)  'mesh grid'
;
e(n,n1)=0.01*n1.val;
d(n,n1)=0.01*n.val;
temp(n,n1,n2)=-(sqr(X_Train(n2,'Heritage'))+sqr(X_Train(n2,'Education')))-(sqr(e(n,n1))+sqr(d(n,n1)))
+2*(e(n,n1)*X_Train(n2,'Heritage')+d(n,n1)*X_Train(n2,'Education'));
temp(n,n1,n2)=exp(temp(n,n1,n2)/(2*sigma*sigma));
Z(n,n1)=sum(n2,temp(n,n1,n2)*alpha.l(n2))+alpha.l('0');
display Z;


scalar budget /100/,gamma /1/;
parameter K_tilde(Header,n);
alias(Header,Header2);
K_tilde(Header,n)=-sum(aspect,sqr(trust_data(Header,aspect)))-(sqr(X_Train(n,'Heritage'))+sqr(X_Train(n,'Education')))
+2*(trust_data(Header,'heritage')*X_Train(n,'Heritage')+trust_data(Header,'education')*X_Train(n,'Education'));
K_tilde(Header,n)=exp(K_tilde(Header,n)/(2*sigma*sigma));

*outter level problem
variables log_l3(Header),obj2;
equations defobj2,deflog_l3(Header);

deflog_l3(Header)..
log_l3(Header) =e= log(1+exp(-Trust_label(Header)*(sum(n1,K_tilde(Header,n1)*alpha(n1))+alpha('0'))));
defobj2..
obj2 =e= gamma/card(n)*sum(n,w(n)) +1/card(Header)*sum(Header,c(Header)*log_l3(Header))+1/card(n)*sum(n,(1-w(n))*log_l(n)+w(n)*log_l2(n));
    
model Kernel_duti /defobj,deflog_l,deflog_l2,defobj2,deflog_l3/;
File myinfo /'%emp.info%'/;
$onecho > '%empinfo%'
bilevel w 
min obj log_l log_l2 alpha deflog_l deflog_l2 defobj 
$offecho
$ontext
$echo subsolver mosek>jams.opt
Kernel_duti.optcr=1e-1;
Kernel_duti.optfile=1;
$offtext
w.l(n)=1e-5;

solve Kernel_duti using emp minimizing obj2;

set g /g1*g40/;
parameter ranking(n);
ranking(n)=card(g)+1;
gamma=1;
scalar num /1/,
threshold /0.5/;

num=0;
$ontext
loop(g$(num < budget),
gamma=gamma/2;
if(ord(g)eq card(g),gamma=0;);
solve Kernel_duti using emp minimizing obj2;
ranking(n)$(ranking(n) eq card(g)+1 and w.l(n)>threshold)=ord(g)+1-w.l(n);
num=sum(n$(ranking(n) ne card(g)+1) ,1);
);
$offtext


*boundary and debug output
set output1Header /heritage,education,val label of training data,Zval,newz,heritage_T,education_T,label label of trust data,ranking/;
$onexternalOutput
table Output1(n,n1,Header,output1Header);
Output1(n,n1,Header,'heritage')$(ord(n1)=1 and ord(Header)=1)=X_Train(n,'heritage');
Output1(n,n1,Header,'education')$(ord(n1)=1 and ord(Header)=1)=X_Train(n,'education');
Output1(n,n1,Header,'val')$(ord(n1)=1 and ord(Header)=1)=y_Con(n);
Output1(n,n1,Header,'zval')$(ord(Header)=1)=Z(n,n1);
Output1(n,n1,Header,'heritage_T')$(ord(n1)=1 and ord(n)=1)=Trust_data(Header,'heritage');
Output1(n,n1,Header,'education_T')$(ord(n1)=1 and ord(n)=1)=Trust_data(Header,'education');
Output1(n,n1,Header,'label')$(ord(n1)=1 and ord(n)=1)=Trust_label(Header);
Output1(n,n1,Header,'ranking')$(ord(n1)=1 and ord(Header)=1)=ranking(n);
Output1(n,n1,Header,'newz')$(ord(Header)=1)=sum(n2,temp(n,n1,n2)*alpha.l(n2))+alpha.l('0');
$offexternalOutput
display ranking;
