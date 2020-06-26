DUTI: Training Set Debugging Using Trusted Items 
V1.0
December 2017

This package includes the implementation of DUTI and example datasets.
If using this code please cite:

Training Set Debugging using Trusted Items
Xuezhou Zhang, Xiaojin Zhu, and Stephen Wright
In The Thirty-Second AAAI Conference on Artificial Intelligence (AAAI), 2018

Author: Xuezhou Zhang
Contact: Xuezhou Zhang (zhangxz1123@cs.wisc.edu), Xiaojin Zhu (jerryzhu@cs.wisc.edu)


Usage --------------------------------------------------------------

To use DUTI to debug your training set, please follow these steps:

Step 1: Prepare your data:
	Store your training data into two matrices: X_train (n*d) and y_train (n*1).
	Store your trusted data into two matrices: X_trust (m*d) and y_trust (m*1).

Step 2: Specify kernel logistic regression/kernel ridge regression hyperparameters:
	L2 regularization weight: lambda
	RBF kernel bandwidth: sigma
	Note: In the current version of the package, the learner is hard coded to be kernel logistic regression for classification and kernel ridge regression for regression.

Step 3: Specify the trusted item confidence vector c (m*1) and debugging budget B.

Step 4: For classification, call DUTI by:

	[ranking, deltas, gammas] = duti_cls(X_train,y_train,X_trust,y_trust,c,lambda,sigma,B);

	ranking:	bug flag ranking for prioritization, n x 1 vector, where
			ranking(i) = (iteration number when item i first have delta in [1/2, 1]) + (1 - that delta value)
			Remarks:
			1. The last term above is for tie-breaking, though there could still be ties.
			2. The 'ranking' is not necessarily an integer.  Still, investigate the item with the smallest ranking first.
	deltas:		debugging solution, n x T matrix, of value in [0,1]
			The columns are delta^(1),...,delta^(t) in the algorithm description.
	gammas:      	the corresponding L1 coefficient gamma values, 1 x T vector

	For regression, call DUTI by:

	[ranking, deltas, gammas] = duti_reg(X_train,y_train,X_trust,y_trust,c,lambda,sigma);

	ranking:	bug flag ranking for prioritization, n x 1 vector, where
			ranking(i) = (iteration number when item i first have non-zero delta.
			Remarks:
			In regression setting, the budget parameter is omitted since the code runs much faster.
	deltas:		debugging solution, n x T matrix, of value in [0,1]
			The columns are delta^(1),...,delta^(t) in the algorithm description.
	gammas:      	the corresponding L1 coefficient gamma values, 1 x T vector



Files --------------------------------------------------------------

duti_cls.m	DUTI for classification (the learner is binary regularized kernel logistic regression)
                Notice that the example code runs the Harry Potter example for a single trial, whereas 
		the PR curve in the paper is the average of 100 trials. Thus, they might be different.


duti_reg.m	DUTI for regression (the learner is kernel ridge regression)
                Notice that the example code runs the Sine Curve example for a single trial, whereas 
		the PR curve in the paper is the average of 100 trials. Thus, they might be different.

HarryPotter.m	The Harry Potter toy dataset serves as a classification example to illustrate DUTI.
SineCurve.m	The Sine Curve toy dataset serves as a regression example to illustrate DUTI.


### Learners
kernelLR_train.m	training with kernel logisic regression
kernelLR_classify.m	use a trained model to classify points
rbf.m			Helper function, generates an RBF kernel matrix
