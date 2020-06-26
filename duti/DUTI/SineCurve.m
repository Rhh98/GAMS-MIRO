%%%%%%%% DUTI Debugging Systematic Bugs for Kernel Ridge Regression %%%%%%%%

clear all; close all;
rng(1);
%% Set hyperparameters
lambda = 3.8e-6;
sigma = 0.7;
c_value = 100;
n=100;

% Generate training Data
% function y = sin(2*pi*x)
X_train=(2/n):(2/n):2;X_train = X_train';y_clean = sin(2*pi*X_train)+0.1*randn(n,1);

% Inject systematic bugs: flipping a bump
y_train = y_clean;y_train((n/2+1):9/10*n) = -abs(y_train((n/2+1):9/10*n));
b=y_train-y_clean;
inx_b = find(b); % index of bugs
delta_true = b~=0;

% Manually picked trusted items on the edge of the buggy region
X_trust=[0.9;1;1.1]+0.05*rand(3,1);
y_trust=sin(2*pi*X_trust);
m = length(y_trust); % number of trusted items.

%% Debug 
c = c_value*ones(m,1);
[ranking, deltas, gamma] = duti_reg( X_train,y_train,X_trust,y_trust,c,lambda,sigma);

%% Confidence Interval in ROC Curves
[x1,y1,t1,auc1] = perfcurve(delta_true,-ranking,1,'XCrit','tpr','YCrit','prec');
%% Plot PR Curves
figure;hold on;
plot(x1(:,1),y1(:,1),'Linewidth',3);
axis([0 1 0 1])
legend('DUTI','Location','Northeast');
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

%% Plot training and trusted points
figure;
hold on;
scatter(X_train,y_train,70,'b','LineWidth',2);
scatter(X_trust,y_trust,200,'r','LineWidth',2);
axis([0 2 -2 2]);
fplot(@(x) sin(2*pi*x),'--black','LineWidth',1);

hold off;
set(gca,...
    'Units','normalized',...
    'YTick',-2:2:2,...
    'XTick',0:1:2,...
    'FontUnits','points',...
    'FontWeight','normal',...
    'FontSize',25,...
    'FontName','Times')
set(gca,'PlotBoxAspectRatio',[1,1,1])

%% Flag Intensity Plot
I1 = 101-ranking;
w1 = max(I1-min(I1(I1>0))+0.05,0);
w1 = w1/max(w1);
[~,rank] = sort(w1,'descend');
X_top = X_train(rank(1:25),:);
y_top = y_train(rank(1:25));
w1_top = w1(rank(1:25));
figure;hold on;
colormap(flipud(bone));
caxis([-0.2 1])
scatter(X_top,y_top,80,w1_top,'o','LineWidth',3);
scatter(X_trust,y_trust,200,'ro','LineWidth',2);

axis([0 2 -2 2]);
fplot(@(x) sin(2*pi*x),'--black','LineWidth',1);
hold off;

set(gca,...
    'Units','normalized',...
    'YTick',-2:2:2,...
    'XTick',0:1:2,...
    'FontUnits','points',...
    'FontWeight','normal',...
    'FontSize',25,...
    'FontName','Times')
set(gca,'PlotBoxAspectRatio',[1,1,1])

%% Plot DUTI fixes
bug_vector=deltas;
index_bug=ranking;
g=1;
figure;
hold on;
scatter(X_train(rank(1:25)),y_train(rank(1:25))+bug_vector(rank(1:25),g),80,'bo','LineWidth',2);
scatter(X_trust,y_trust,200,'ro','LineWidth',2);
axis([0 2 -2 2]);
fplot(@(x) sin(2*pi*x),'--black','LineWidth',1);
hold off;

set(gca,...
    'Units','normalized',...
    'YTick',-2:2:2,...
    'XTick',0:1:2,...
    'FontUnits','points',...
    'FontWeight','normal',...
    'FontSize',25,...
    'FontName','Times')
set(gca,'PlotBoxAspectRatio',[1,1,1])
