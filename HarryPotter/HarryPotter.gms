
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

set n 'training set' /1*100/;
*training data
parameter
X_MH(n) 'magic heritage',
X_E(n) 'education'
;
alias(n,n1,n2,n3);
X_MH(n)=0.1*ceil(n.val/10)-0.05;
X_E(n)=0.1*(n.val-floor(n.val/10)*10)-0.05;
display X_E,X_MH;
*Training data dithered with a Guassian
X_MH(n)=X_MH(n)+0.03*normal(0,1);
X_E(n)=X_E(n)+0.03*normal(0,1);

*the noiseless 'desired' label obeys y_E=sign(X_E-0.5)
parameter y_E(n);
y_E(n)$(X_E(n)-0.5 eq 0)=0;
y_E(n)$(X_E(n)-0.5 gt 0)=1;
y_E(n)$(X_E(n)-0.5 lt 0)=-1;
*Contamination
*The historically based rule is
parameter y_Con(n);
y_Con(n)=y_E(n);
y_Con(n)$((X_E(n) lt (4*sqr(X_MH(n)-0.5)+0.5))
 and (X_MH(n) lt 0.5) )=-1;
 


$ontext
% w is the debugging optimization variable, the special case for delta in
% the binary classification case.
$offtext


variables w(n);
parameter w_true(n)
;
w.l(n)=1e-5;
w.lo(n)=0;
w.up(n)=1;
w_true(n)=0;
w_true(n)$(y_Con(n) ne y_E(n))=1;

*alpha's are the dual parameters in kernel logistic regression to be learned.
parameter K(n,*) 'Kernel function';
K(n,n1)=-(sqr(X_MH(n))+sqr(X_E(n)))-(sqr(X_MH(n1))+sqr(X_E(n1)))+
2*(X_MH(n)*X_MH(n1)+X_E(n)*X_E(n1));
K(n,n1)=exp(K(n,n1)/(2*sigma*sigma));
K(n,'101')=1;

*Binary kernel logistic ridge regression
variables alpha(*),obj,log_l(n),log_l2(n),h(n),h2(n);
equations defobj,deflog_l(n),defh(n),deflog_l2(n),defh2(n);
defh(n)..
h(n) =e= -y_Con(n)*(sum(n1,K(n,n1)*alpha(n1))+K(n,'101')*alpha('101'));

defh2(n)..
h2(n) =e= y_Con(n)*(sum(n1,K(n,n1)*alpha(n1))+K(n,'101')*alpha('101'));

deflog_l(n)..
log_l(n) =e= log(1+exp(h(n)))*sign(h(n))*(sign(h(n))-1)/2+log(2)*(1+sign(h(n)))*(1-sign(h(n)))+(log(1+exp(-h(n)))+h(n))*sign(h(n))*(sign(h(n))+1)/2;

deflog_l2(n)..
log_l2(n) =e= log(1+exp(h2(n)))*sign(h2(n))*(sign(h2(n))-1)/2+log(2)*(1+sign(h2(n)))*(1-sign(h2(n)))+(log(1+exp(-h2(n)))+h2(n))*sign(h2(n))*(sign(h2(n))+1)/2;

defobj..
obj =e= lam/2*sum(n,sum(n1,K(n,n1)*alpha(n)*alpha(n1)))
    + 1/card(n)*sum(n,(1-w.l(n))*log_l(n)+w.l(n)*log_l2(n));

model Kernel_train /defobj,deflog_l,defh,deflog_l2,defh2/;
alpha.l(n)=0.001;
solve Kernel_train using dnlp minimizing obj;
display alpha.l;

*generated trusted data--------------------
set Header /true,false/,
aspect /Heritage,education/
;
table Trust_data(Header,aspect)
      heritage   education
true  0.5        0.4
false 0.2        0.6
;

parameter Trust_label(Header) /true 1,false -1/;
parameter c(header) /set.header 100/;

*Generating contour by kernel logistic regression
parameter Z(n,n) 'label of testing data (0.01:0.01:1,0.01:0.01,1)',
temp(n,n,n)  'temporary value',
e(n,n), d(n,n)  'mesh grid'
;
e(n,n1)=0.01*n1.val;
d(n,n1)=0.01*n.val;
temp(n,n1,n2)=-(sqr(x_MH(n2))+sqr(x_E(n2)))-(sqr(e(n,n1))+sqr(d(n,n1)))
+2*(e(n,n1)*x_MH(n2)+d(n,n1)*x_E(n2));
temp(n,n1,n2)=exp(temp(n,n1,n2)/(2*sigma*sigma));
Z(n,n1)=sum(n2,temp(n,n1,n2)*alpha.l(n2))+alpha.l('101');
display Z;

scalar budget /100/,gamma /0/;
parameter K_tilde(Header,*);
alias(Header,Header2);
K_tilde(Header,n)=-sum(aspect,sqr(trust_data(Header,aspect)))-(sqr(X_MH(n))+sqr(X_E(n)))
+2*(trust_data(Header,'heritage')*X_MH(n)+trust_data(Header,'education')*X_E(n));
K_tilde(Header,n)=exp(K_tilde(Header,n)/(2*sigma*sigma));
K_tilde(Header,'101')=1;


variables log_l3(Header),h3(Header),obj2;
equations defobj2,deflog_l3(Header),defh3(Header);

defh3(Header)..
h3(Header) =e= -trust_label(Header)*(sum(n,K_tilde(Header,n)*alpha.l(n))+K_tilde(Header,'101')*alpha.l('101'));

deflog_l3(Header)..
log_l3(Header) =e= log(1+exp(h3(Header)))*sign(h3(Header))*(sign(h3(Header))-1)/2+log(2)*(1+sign(h3(Header)))*(1-sign(h3(Header)))+
(log(1+exp(-h3(Header)))+h3(Header))*sign(h3(Header))*(sign(h3(Header))+1)/2;

defobj2..
obj2 =e= gamma/card(n)*sum(n,w(n)) + 1/card(n)*sum(n,(1-w(n))*log_l.l(n)+w(n)*log_l2.l(n))
    +1/card(Header)*sum(Header,c(Header)*log_l3(Header));
    
model Kernel_duti /defobj2,deflog_l3,defh3/;
solve Kernel_duti using dnlp minimizing obj2;
set g /g1*g40/;
parameter ranking(n);
ranking(n)=card(g);
gamma=1;
scalar num /1/,
threshold /0.5/;
while(num gt 0,
gamma=gamma*2;
solve Kernel_duti using dnlp minimizing obj2;
num=sum(n$(w.l(n) gt 0),1);
);
num=0;
loop(g$(num < budget),
gamma=gamma/2;
if(ord(g)=card(g),gamma=0;);
solve Kernel_duti using dnlp minimizing obj2;
solve Kernel_train using dnlp minimizing obj;
ranking(n)$(ranking(n) eq card(g) and w.l(n)>threshold)=ord(g)-w.l(n);
num=sum(n$(ranking(n) ne card(g)) ,1);
);



