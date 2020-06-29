%%%%%%%%%%%%%%%%%%% Harry Potter Toy Example %%%%%%%%%%%%%%%%%%

close all;clear all;

% for reproducibility, fix the random seed 
rng(123);

% the learner is hard coded to be kernel logistic regression.
% learner's parameters:
lam = 1e-3; 	% L2 regularization weight of learner
sigma = 0.5; 	% RBF kernel bandwidth

% ----------------------------------------
% Generate "dirty" training data. 
% that is, we will plant some "historical bias" 
% in the form of labels: the Ministry of Magic refused to hire
% muggle-born graduates with high edcuation.

n = 100; % Training Set size

% data points are on a uniform grid, then dithered with a Guassian.
% x_1=magic heritage; x_2=education
X_train = zeros(n,2);
[e, d] = meshgrid((0.05:0.1:0.95),(0.05:0.1:0.95));
X_train(:,1) = e(:); X_train(:,2) = d(:);
X_train = X_train+0.03*randn(n,2);

% the noiseless 'desired' label obeys y = sign(x_2 - 0.5)
y_clean = sign(X_train(:,2)-0.5); 

% Contamination
% the historically biased rule is 
y_train = y_clean;
y_train((X_train(:,2)<(4*(X_train(:,1)-0.5).^2+0.5))&(X_train(:,1)<0.5)) = -1;

% ----------------------------------------
% Train kernel logistic regression on the dirty training data

% w is the debugging optimization variable, the special case for delta in
% the binary classification case.
w = zeros(n,1); 
w_true = (y_train ~= y_clean); % 1 if an item is a true bug

% alpha's are the dual parameters in kernel logistic regression to be learned.
alpha0 = zeros(n+1,1); % intialize to be all-zero vector.
test=rbf(X_train,X_train,sigma);
K = [rbf(X_train,X_train,sigma),ones(n,1)];
alpha = kernelLR_train( K,y_train,w,lam,alpha0);

%% Generate trusted data ----------------------------------------
% we manually picked these two trusted items for pedagogical purpose
X_trust = [
  0.3, 0.4;
  0.2, 0.6];
y_trust = sign(X_trust(:,2)-0.5);
m =length(y_trust);
c_value = 100;  % Confidence parameters on trusted items are set to 100.
c = c_value*ones(m,1);

%% plot training and trust data 
% Plot the decision boundary
[e,d] = meshgrid(linspace(0,1),linspace(0,1));
Z = zeros(100,100);
for i = 1:100
    for j = 1:100
	Z(i,j) = kernelLR_classify( X_train,alpha,[e(i,j),d(i,j)],sigma );
    end
end
f = figure;hold on;
axis([0 1 0 1])
scatter(X_train(y_train>0,1),X_train(y_train>0,2),70,'b+','LineWidth',2)
scatter(X_train(y_train<0,1),X_train(y_train<0,2),70,'bo','LineWidth',2)

scatter(X_trust(y_trust>0,1),X_trust(y_trust>0,2),200,'r+','LineWidth',2)
scatter(X_trust(y_trust<0,1),X_trust(y_trust<0,2),200,'ro','LineWidth',2)
contour(e,d,Z,[0,0],'-k','LineWidth',2);
xlabel('magical heritage');
ylabel('education');
axis([0 1 0 1])
hold off;
set(gca,...
'Units','normalized',...
'YTick',0:0.5:1,...
'XTick',0:0.5:1,...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',25,...
'FontName','Times')
set(gca,'PlotBoxAspectRatio',[1,1,1])



% ----------------------------------------
% Debug with DUTI 

budget = n; % flag as many bugs as necessary
[ranking, deltas, gammas] = duti_cls(X_train,y_train,X_trust,y_trust,c,lam,sigma,budget);
disp('DUTI completed');

%% Plot Precision Recall Curves
[X1,Y1,~,AUC1] = perfcurve(w_true,-ranking,1,'XCrit','tpr','YCrit','prec');
figure;hold on;
plot(X1,Y1,'LineWidth',3);
axis([0 1 0 1])
legend('DUTI','Location','Southwest');
xlabel('Recall');
ylabel('Precision');
hold off
set(gca,...
'Units','normalized',...
'YTick',0:0.5:1,...
'XTick',0:0.5:1,...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',25,...
'FontName','Times')
set(gca,'PlotBoxAspectRatio',[1,1,1])

%% flag intensity plot
w1 = max(-ranking-min(-ranking)+0.05,0);
w1 = w1/max(w1);
[~,sorted] = sort(w1,'descend');
X_top = X_train(sorted(1:15),:);
y_top = y_train(sorted(1:15));
w1_top = w1(sorted(1:15));
figure;
hold on;
colormap(flipud(bone));
caxis([0 1])
axis([0 1 0 1])
scatter(NaN,NaN,100,1,'+','LineWidth',3)
scatter(NaN,NaN,100,1,'o','LineWidth',3)
scatter(X_top(y_top>0,1),X_top(y_top>0,2),70,w1_top(y_top>0),'+','LineWidth',3)
scatter(X_top(y_top<0,1),X_top(y_top<0,2),70,w1_top(y_top<0),'o','LineWidth',3)
xlabel('magical heritage');
ylabel('education');
set(gca,...
'Units','normalized',...
'YTick',0:0.5:1,...
'XTick',0:0.5:1,...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',25,...
'FontName','Times',...
'PlotBoxAspectRatio',[1,1,1])
hold off;
