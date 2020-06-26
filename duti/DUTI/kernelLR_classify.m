function f = kernelLR_classify( X,alpha,x,sigma )
% Input:
%       X = training set
%       x = test set
%       alpha = model parameters
%       sigma = kernel band width
% Output:
%       f = prediction value, sign(f) = class, while |f| = confidence.

m = size(x,1);
k = [rbf(x,X,sigma),ones(m,1)];
f = k*alpha;
end

