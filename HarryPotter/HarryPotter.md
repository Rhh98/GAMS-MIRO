<h1>
   DUTI: Debugging using Trusted Item
</h1>

<h3>
    --Harry Potter Example
</h3>



<h2>
    Problem Statement:
</h2>

<p>
    This is a Machine learning case study. When doing machine learning with training data, training set bugs could adversely affect the result. Unfortunately, the whole training set is usually too large for manual inspection. But one may have the resources to verify a few trusted items. The trusted items themselves may not be adequate for learning, so we propose an algorithm that uses these items to identify bugs in the training set and thus improve learning. Specifically, our approach seeks the smallest
set of changes to the training set labels such that the model
learned from this corrected training set predicts labels of the
trusted items correctly.
</p>



<h2>
    Input and Output of the Model
</h2>

For the machine learning example, we will use a simple but typical one, namely "Harry Potter " example.  Suppose we have datas of several Hogwarts students. The training set data included their magical heritage ranging from 0(muggle-born) to 1(pure-blood) and their education level ranging from 0(failed school) to 1(Hermione level).  The label for these datas are whether '+1':Hired by Ministry of Magic after graduation) or -1-Not Hired.

<h3>
    Input data
</h3>

<ul>
    <li>Information of Trusted Item: "Magical heritage","Education" and label of trusted data</li>
    <li>Label changing panelty: This parameter is used to limit the number of flagged bugs. The bigger this parameter is, the less bugs will be identified.</li>
</ul>

<h3>
    Output
</h3>

<ul>
    <li>The classfier without using trusted items:
    A plot shows the training data and the trusted item with thier original label together with the boundary showing the learned classifier.</li>
    <li>New classfier using DUTI: A plot with boundary of the new classfier. Whether the training data may potentially have bugs are shown in the figure.</li>
</ul>
<h3>
    User Guide
</h3>

User can change the "Information of Trusted Item" to notably affect the result of debugging when the "Label changing panelty" is not set to a very large value such as 1000 or more.  Since in such case the new learner will almost always correctly classfy our trusted item. Hence the correctness of our used trusted item is crusial to debugging. If there are trusted label which is not correctly classfied by the current learner, then the new learner will be quite different after debugging. The "Label changing panelty" basicaly meassured how many bugs we may want to flag, or how much confidence we have about the cleaness of the training data. To be specifically, with larger value of "Label changing panelty", less bugs will we identify. However, how much influence will the change of this parameter bring has uncertainty. Basically, when this paramter is small, changing it will affect the result much. While when it is set to a very large value, changing its value may lead to the same result.




<h2>
    Math formulation
</h2>

<h3>
    Variables:
</h3>
$X$: training set data

$Y$: training set label

$n$: size of training set

$Y'$: training set label using DUTI

$\tilde{X}$: Trusted data 
$ \tilde{Y}$: Trusted label

$m$: size of trusted item set

$\mathcal{A}$: The learning algorithm

$\mathcal{l}$: The loss function

$\theta$: parameter of learner

$\omega$: weight parameter of certain label

$\Omega(\theta)$: Regularization item

$\gamma$: coefficient of weight parameter limiting change of label when debugging. Larger $\gamma$ will enforce fewer change label, i.e.  one will find fewer bugs label.



<h3>
    Formulation:
</h3>


The problem could be formulated as a bilevel optimation as:

$$
\begin{aligned}min \quad&Distance \left(Y^{\prime}, Y\right) \\\ 
   s.t.  \quad   &Predictor =\mathcal{A}\left(X, Y^{\prime}\right)\\\ 
 &Predictor (\tilde{X})=\tilde{Y} \wedge \operatorname{Predictor}(X)=Y^{\prime}\end{aligned}
$$
This is a discontinous combinatorial optimization, which is hard to solve. We relax it to a nice continous continous bilevel optimization:

$\begin{aligned} \min _{\omega \in [0,1]^n, \theta} & \frac{1}{m} \sum_{i=1}^{m} c_{i} \ell\left(\tilde{x}_{i}, \tilde{y}_{i}, \theta\right) \\ &+\frac{1}{n} \sum_{i=1}^{n}[(1-\omega) \ell\left(x_{i},y_j, \theta\right)+\omega \cdot \ell\left(x_{i},-y_j, \theta\right)]+\frac{\gamma}{n} \sum_{i=1}^{n}\omega \\ \text { s.t. } & \theta=\underset{\beta}{\operatorname{argmin}} \frac{1}{n} \sum_{i=1}^{n}  [(1-\omega) \ell\left(x_{i},y_j, \theta\right)+\omega \cdot \ell\left(x_{i},-y_j, \theta\right)]+\lambda \Omega(\beta) \end{aligned}$



<h2>
    GAMS Model
</h2>
The GAMS model can be downloaded <a href="static_harrypotter_emp/HarryPotter_emp.gms" target="_blank">here</a>.







