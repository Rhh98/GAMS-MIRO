function [ranking, deltas, gamma] = duti_reg( X_train,y_train,X_trust,y_trust,c,lambda,sigma)
% Input:
%   X_train     training data,  n x d matrix
%   y_train     training label, n x 1 vector of real value
%   X_tilde     trusted items,  m x d matrix
%   y_tilde     trusted items,  m x 1 vector of real value
%   c           confidence vector of trusted items, m x 1 vector
%   lam         ridge coefficient of the learner, positive real number
%   sigma       bandwidth of RBF kernel, positive real number
%   budget      examination budget, real number <=n
% Output:
%   ranking:	bug flag ranking for prioritization, n x 1 vector, where
%               ranking(i) = (iteration number when item i first have non-zero delta.
%               Remarks:
%               In regression setting, the budget parameter is omitted since the code runs much faster.
%	deltas:		debugging solution, n x T matrix, of value in [0,1].
%               The columns are delta^(1),...,delta^(t) in the algorithm description.
%	gammas:     the corresponding L1 coefficient gamma values, 1 x T vector

n = size(X_train,1);
m = size(X_trust,1);
w = [c/m;ones(n,1)/n];
K = rbf(X_train,X_train,sigma);
K_tilde = rbf(X_trust,X_train,sigma);
B = K*inv(K+n*lambda*eye(n))-eye(n);
A = K_tilde*inv(K+n*lambda*eye(n));

% Solve the Lasso problem
[deltas,FitInfo] = lasso([A;B],[y_trust-A*y_train;-B*y_train],'Weights',w);
gamma = FitInfo.Lambda;

ranking = (size(deltas,2)+1)*ones(n,1);
for i = 1:size(deltas,2)
    ranking(deltas(:,i)~=0) = size(deltas,2)+1-i;
end
end

