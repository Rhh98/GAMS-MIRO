function [ranking, deltas, gammas] = duti_cls(X_train,y_train,X_tilde,y_tilde,c,lam,sigma,budget)
%% DUTI implementation with binary RBF kernel logistic ridge regression
% Input:
%   X_train     training data,  n x d matrix
%   y_train     training label, n x 1 vector of value {-1,1}
%   X_tilde     trusted items,  m x d matrix
%   y_tilde     trusted items,  m x 1 vector of value {-1,1}
%   c           confidence vector of trusted items, m x 1 vector
%   lam         ridge coefficient of the learner, positive real number
%   sigma       bandwidth of RBF kernel, positive real number
%   budget      examination budget, real number <=n
% Output:
%   ranking     bug flag ranking for prioritization, n x 1 vector, where 
%               ranking(i) = (iteration number when item i first have delta in [1/2, 1]) + (1 - that delta value)
%		Remarks:
%		1. The last term above is for tie-breaking, though there could still be ties.
%		2. The 'ranking' is not necessarily an integer.  Still, investigate the item with the smallest ranking first.
%   deltas      debugging solution (n x T) with value in [0,1], each column is delta^(t)
%   gammas      the gamma in debugging objective O_gamma(), 1 x T vector


% Set debugging objective to be the objective for kernel logistic
% regression.
debugger = @kernel_log_debug_obj;

threshold = 0.5;% threshold for w values to treat a training point as bug
n = size(X_train,1);% training set size
m = size(X_tilde,1);% trusted set size


% prepare the RBF kernel matrix
K = [rbf(X_train,X_train,sigma),ones(n,1)];
K_tilde = [rbf(X_tilde,X_train,sigma),ones(m,1)];

% sneaky way to pass parameters to the learner A within matlab optimization
global global_alpha;
global global_w;
global global_dalphadw;
global_alpha = zeros(n+1,1);
global_w = zeros(n,1);
global_dalphadw = zeros(n+1,n);

% find out the maximum gamma_0 value that results in a nonzero w solution,
% i.e. \nabla_w at w=0 (i.e. the original dirty training data) and gamma=0.
gamma0 = 0;
w0 = zeros(n,1);
[~,grad]=debugger(w0,K,y_train,K_tilde,y_tilde,gamma0,c,lam);
gamma = 2*n*max(-grad);

% Intialize deltas matrix and gammas vector
deltas = zeros(n,1);
gammas = [];
num = 0;

% Setting up parameters for fmincon
lb = zeros(n,1);
ub = ones(n,1);
A = [];
b = [];
Aeq = [];
beq = [];
nonlcon = [];
options = optimoptions('fmincon','SpecifyObjectiveGradient',true,...
    'Display','iter','Algorithm','sqp','UseParallel',true,...
    'FunctionTolerance',1e-6,'OptimalityTolerance',1e-6,'StepTolerance',1e-6);

% Max number of iterations to run
g = 40;
ranking = (g+1)*ones(n,1);
for s = 2:(g+1)
    % Check if examination budget is met.
    if num>budget
        break;
    end
    gamma = gamma*1/2;
    % At the last interation, set gamma = 0 to get the most dense solution.
    if s == g+1
        gamma = 0;
    end
    gammas(s-1) = gamma;
    % Solve for the optimization
    deltas(:,s) = fmincon(@(w)debugger(w,K,y_train,K_tilde,y_tilde,gamma,c,lam),...
    min(deltas(:,(s-1))+1e-5,1-1e-5),A,b,Aeq,beq,lb,ub,nonlcon,options);
    % Compute and report which training point is flagged.
    ranking((deltas(:,s)>threshold)&(ranking==(g+1))) = s-1 + 1-deltas((deltas(:,s)>threshold)&(ranking==(g+1)),s);
    % Report the total number points flagged up to this iteration
    num = sum(ranking>0 & ranking ~= g+1);
end
deltas = deltas(:,2:end);

end

function [ J, grad] = kernel_log_debug_obj(w,K,y_train,K_tilde,y_tilde,gamma,c,lam)
%% DUTI debugging objective for binary RBF kernel logistic ridge regression
% Input:
%    w          n x 1 weight vector
%    K          n x n kernel matrix
%    y_train 	n x 1 training label vector, taking value in {-1,+1}
%    K_tilde    m x n kernel matrix
%    y_tilde    m x 1 trusted label vector
%    gamma      L1 coefficient
%    c          confidence vector of trusted items, m x 1 vector
%    lam        ridge coefficient of the learner, positive real number

% Output:
%    J          the objective value
%    grad       n x 1 vector, the gradient
global    global_alpha;
global global_w;
global global_dalphadw;

[m,n] = size(K_tilde); n = n-1;
% Retrain the learner with continuation initialization method
alpha0 = global_alpha + global_dalphadw*(w-global_w);
grad = lam*[K(:,1:n)*alpha0(1:n);0] + ...
    1/n*((1-w)'*log_d(K,y_train,alpha0)+w'*log_d(K,-y_train,alpha0))';
if max(abs(grad))<1e-6 && sum(isnan(alpha0))==0
    alpha = alpha0;
elseif sum(isnan(alpha0))==0
    alpha = kernelLR_train(K,y_train,w,lam,alpha0);
else
    alpha = kernelLR_train(K,y_train,w,lam,zeros(n+1,1));
end

% Compute (d alpha/d w)
dhdw = (1/n*y_train.*K)';
dhdalpha = zeros(n+1,n+1);
dhdalpha(1:n,1:n) = lam*K(:,1:n);
for i = 1:n
    dhdalpha = dhdalpha + 1/n*log_dd(K(i,:),y_train(i),alpha);
end
dalphadw = -pinv(dhdalpha)*dhdw;

% Update global variables.
global_alpha = alpha;
global_w = w;
global_dalphadw = dalphadw;

% Compute objective and gradient
J = gamma*1/n*ones(1,n)*w + 1/n*((1-w)'*log_l(K,y_train,alpha)+w'*log_l(K,-y_train,alpha))+...
    1/m*c'*log_l(K_tilde,y_tilde,alpha);
grad = gamma*1/n*ones(1,n).*sign(w)' + 1/n*(log_l(K,-y_train,alpha)-log_l(K,y_train,alpha))'+...
    1/n*sum((1-w).*log_d(K,y_train,alpha) + w.*log_d(K,-y_train,alpha),1)*dalphadw + ...
    1/m*sum(c.*log_d(K_tilde,y_tilde,alpha),1)*dalphadw;
grad=grad';
end

function g = log_d(x,y,beta)
%% gradient of logistic loss dl/dbeta
% y in n*1 response vector
% x in n*p data matrix
% beta in p*1 column vector
% g in n*p gradient matrix
g = -y.*x./(1+exp(y.*(x*beta)));
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

function h = log_dd(x,y,beta)
%% Hessian of logistic loss d^2l/dbeta^2
% y in R
% x in R^p row vector
% beta in R^p column vector
% h size p*p matrix
h = 1/(2+exp(-x*beta)+exp(x*beta))*(x'*x);
end


