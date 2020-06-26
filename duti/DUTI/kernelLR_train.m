function alpha = kernelLR_train( K,y_train,w,lam,alpha0)
%% Binary RBF kernel logistic ridge regression
% Input:
%    K          n x n kernel matrix
%    y_train 	n x 1 label vector, taking value in {-1,+1}
%    w          n x 1 weight vector
%    lam        ridge coefficient of the learner, positive real number
%    alpha0     initialization for fminunc
% Output:
%    alpha      dual parameter




options = optimoptions('fminunc','Display','off','Algorithm','quasi-newton',...
    'SpecifyObjectiveGradient',true,'FunctionTolerance',1e-12,...
    'MaxIterations',4000,'StepTolerance',1e-9,'UseParallel',true);
alpha = fminunc(@(alpha)costKernelReg(alpha, K, y_train, w, lam),alpha0,options);

end

function [J, grad] = costKernelReg(alpha, K, y_train, w, lam)
%% Binary RBF kernel logistic ridge regression objective function
% Input:
%    alpha		(n*k) x 1 the dual parameter
%    K          n x n kernel matrix
%    y      	n x 1 label vector, taking value in {-1,+1}
%    w          n x k weight matrix
%    lam        ridge coefficient of the learner, positive real number
% Output:
%    J          the objective value
%    grad       n x 1 vector, the gradient
[n,~] = size(K);

% Compute objective and gradient
J = lam/2*sum(sum(K(:,1:n).*(alpha(1:n)*alpha(1:n)')))...
    + 1/n*((1-w)'*log_l(K,y_train,alpha)+w'*log_l(K,-y_train,alpha));
grad = lam*[K(:,1:n)*alpha(1:n);0] + ...
    1/n*((1-w)'*log_d(K,y_train,alpha)+w'*log_d(K,-y_train,alpha))';
end

function l = log_l(x,y,beta)
%% Logistic loss function ell(x,y,beta)
% y in R
% x in R^p row vector
% beta in R^p column vector
% l in R
h=-y.*(x*beta);
n = length(h);
l = zeros(n,1);
for i=1:n
if h(i)<=0
l(i) = log(1+exp(h(i)));
else 
    l(i) = log(1+exp(-h(i)))+h(i);
end
end
end

function g = log_d(x,y,beta)
%% gradient of logistic loss dl/dbeta
% y in n*1 response vector
% x in n*p data matrix
% beta in p*1 column vector
% g in n*p gradient matrix
g = -y.*x./(1+exp(y.*(x*beta)));
end
