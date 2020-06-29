function K = rbf( X1,X2,sigma)
%% Compute RBF kernel of two data matrices
% Inputs:
%       X1:     data matrix with training samples in rows and features in columns
%       X2:     data matrix with test samples in rows and features in columns
%       sigma:  RBF kernel bandwidth
% Output:
%       K: kernel matrix, K(i,j)=\exp(-\frac{\|Xi-Xj\|^2}{2\sigma^2}

[n,~] = size(X1);
[m,~] = size(X2);

%form RBF over the data:
nms = sum(X1'.^2,1);
mms = sum(X2'.^2,1);
D = -nms'*ones(1,m) -ones(n,1)*mms + 2*X1*X2';

K = exp(D/(2*sigma^2));

end
