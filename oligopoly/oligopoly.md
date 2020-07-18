<a name="Top"> </a>

<h1>Oligopolistic Markets</h1>
<center><a href="#Game Theory">Game Theory</a>&nbsp;|&nbsp;<a href="#Linear Model & Complementarity">Linear Model & Complementarity</a>&nbsp;|&nbsp;<a href="#GAMS Model Definition">GAMS Model Definition</a></center><center><a href="#Input and Output Specification">Input and Output specification</a>&nbsp;|&nbsp;<a href="#GAMS Model">GAMS Model</a>&nbsp;|<a href="#References">References</a>&nbsp;</center>

<p>An oligopoly is a market form in which a market or industry is dominated by a small number of firms, known as oligopolists. In microeconomics, there are several canonical models to describe the outcomes of olgopolistic markets.  Here we describe mathematical formulations and an associated computable model for the <b>Cournot</b> model, <b>Bertrand</b> model and the <b>Stackelberg</b> model.</p>
<hr>
<p>The <b>Cournot</b> model was proposed by Antoine Cournot in 1838 to describe an oligopolistic market where firms strategically compete over quantities.  The model assumes that firms produce imperfect substitutes, firms have market power, there is no market entry and quantities are chosen simulataneously.  The simulataneous choice assumption does not refer to time but is meant to signify that no firm has knowledge of other firms' choice before they make their own.  In the canonical model all firms have full knowledge of the function that sets the common market price, their competitor's individual cost functions and the level demand.</p>
<hr>
<p>The <b>Bertrand</b> model was proposed by Joseph Bertrand in 1883 as a criticism to the Cournot Model.  The model describes an oligopoly where firms strategically compete over prices.  The model makes the same assumptions as the Cournot model.  Bertrand noted that firms do not generally change their production quantities to compete but change their product's price level.  While it is agreed that this more closely approximates the mechanism by which a firm would compete given the presented situation, the objective function is dis-continuous, the predictions are sensitive to tie breaking rules and other non-strategic assumptions and the model does not coincide with observation.</p>
<hr>
<p>The <b>Stackelberg</b> model was proposed by Heinrich Stackelberg in 1934 to describe an oligopoly where the market has a strategic (Stackelberg) leader.  This case is identical to the Cournot model, except that the Stackelberg leader sets their quantity first and the Stackelberg follower incorporates this information into their optimisation problem.  There is an additional assumption that the Stackelberg leader has commitment power.</p>




<a name="GAMS Model Definition"></a>

<h1>GAMS Model Definitions</h1></a>

<h3>Cournot Model Formulation</h3>
<p>
Here we define our model for the Cournot and Stackelberg problems that we solve. The total quantity produced by the firms, <b>Q</b>, in the market are defined as,
<center> <b>Q</b> = &#x2211;<sub>i</sub><sup>N</sup> q <sub>i</sub> </center>
Our inverse demand function, p(<b>Q</b>), defines our market price at which all firms sell at and consumers purchase at.  The inverse demand function is derived from the demand curve, <b>Q</b>(p), defined as, <br>
<center><b>p</b>(Q) = (d&#773; / <b>Q</b>)<sup>1 / &gamma;</sup></center>
The total production cost, TC<sub>i</sub>(q<sub>i</sub>), for firm i.  Making a standard market assumption that the firm will be optimising when the marginal cost of a firm is equal to the price and assuming the firms supply curve is described by a Constant Elasticity of Substitution (CES) function, we have, <br>
<center>q<sub>i</sub> = L<sub>i</sub>p<sup>&beta;</sup></center>
which we note is a special case of CES known as the Cobb-Douglas function. We now have the folowing CES function describing total cost, <br>
<center>TC<sub>i</sub> = c<sub>i</sub>q<sub>i</sub> + &beta;<sub>i</sub> / (1 + &beta;<sub>i</sub>) * L<sub>i</sub><sup>1 / &beta;<sub>i</sub></sup> * q<sub>i</sub><sup>1 + &beta;<sub>i</sub> / &beta;<sub>i</sub></sup></center>
which the reader can verify gives our desired optimality condition p = MC.  Firms optimise their profit, &pi;, taking their own quantity and the quantities of the other firms have on the profit.  The profit function is defined as,
<center>&pi;<sub>i</sub> = q<sub>i</sub>p(<b>Q</b>) - TC<sub>i</sub> ,</center> 
Firms therefore optimise over the following non-linear problem (NLP), <br>
<center>max<sub>q<sub>i</sub></sub> &pi;<sub>i</sub>(<b>Q</b>) = q<sub>i</sub>(d&#773; / <b>Q</b>)<sup>1 / &gamma;</sup> - c<sub>i</sub>q<sub>i</sub> + &beta;<sub>i</sub> / (1 + &beta;<sub>i</sub>) * L<sub>i</sub><sup>1 / &beta;<sub>i</sub></sup> * q<sub>i</sub><sup>1 + &beta;<sub>i</sub> / &beta;<sub>i</sub></sup></center>
<center>s.t. <b>Q</b> = &#x2211;<sub>i</sub><sup>N</sup> q <sub>i</sub></center>
<center> q<sub>i</sub> &ge; 0 .</center>
This is a Nash Equilibrium problem, the math formualtion of the Cournot model, which is also a standard formulation of oligopoly in microeconomics. We can solve the Nash Equiibrium problem effectively using the EMP solver in GAMS. </p>

<h2>
    Stackelberg Model Formulation
</h2>


<p>
    For Stackelberg Model, since now we assume there is a leader firm who first set its strategy and then other firms incorporate with the leader firm. 
    Suppose the leader firm to be $l$, then similar to before, the leader firm $l$ wants to maximize its profit defined as:</p>

$$\pi_{l}(\mathbf{Q})=q_{l}(\overline{\mathrm{d}} / \mathbf{Q})^{1 / y}-c_{l} q_{l}+\beta_{l} /\left(1+\beta_{l}\right) L_{l}^{1 / \beta_{l}}  q_{l}^{1+\beta_{l} / \beta_{l}}$$

Different from before, for other firms, the quantity of firm $l$,  $q_l$, now is taken as a parameter when maximizing their own profits. Thus, the whole model is:

$$\begin{array} {ll} max_{q_l}  \quad &\pi_{l}(\mathbf{Q})=q_{l}(\overline{\mathrm{d}} / \mathbf{Q})^{1 / y}-c_{l} q_{l}+\beta_{l} /\left(1+\beta_{l}\right) L_{l}^{1 / \beta_{l}}  q_{l}^{1+\beta_{l} / \beta_{l}} \\ s.t.  &q_l \ge 0\\ \\  & min_{q_i} \quad \pi_{i}(\mathbf{Q})=q_{i}(\overline{\mathrm{d}} / \mathbf{Q})^{1 / y}-c_{i} q_{i}+\beta_{i} /\left(1+\beta_{i}\right) L_{i}^{1 / \beta_{i}}  q_{i}^{1+\beta_{i} / \beta_{i}}\\ & s.t. \qquad q_i \ge0\end{array} $$ 
This is a bilevel programming and can also be conveniently solved using solver emp in GAMS.






<h3>Bertrand Model</h3>

<p>Here we define our model for the Bertrand problem that we solve. The total quantity produced by the firms is defined by a perturbed version of our previous linear model,
<center><b>Q</b> = &#x2211;<sub>i</sub><sup>N</sup> w<sub>i</sub>  q<sub>i</sub></center>
<center> w<sub>i</sub> &ne; w<sub>-i</sub></center>
We have the following demand function for each firm in the case of duopoly (for ease of exposition),
<center>q<sub>i</sub> = &alpha; - &delta;<sub>1</sub>p<sub>1</sub> + &delta;<sub>2</sub> p<sub>2</sub></center>
<center>&alpha; = ( w<sub>1</sub>d&#773; +  w<sub>2</sub>d&#773;  )/ ( w<sub>1</sub><sup>2</sup> - w<sub>2</sub><sup>2</sup> )</center>
<center>&delta;<sub>i</sub> = w<sub>i</sub> / ( w<sub>1</sub><sup>2</sup> - w<sub>2</sub><sup>2</sup> )</center>
And we have the following profits for firm i, <br>
<center>&pi;<sub>i</sub> = ( p<sub>i</sub> - c<sub>i</sub>) q<sub>i</sub></center>
This is the case depisted in our graph of a continuous case Bertrand model and in our GAMS model.
</p>


<a href="Input and Output specification"></a>

<h1>
    Input and Output Specification
</h1>

<h3>
    Input for Cournot and Stackelberg model
</h3>
<ul>
    <li>leader firm: The leader firm in the Stackelberg model. There should be exactly one leader firm chosen from the "Cournot & Stackelberdg firms" parameter.</li>
    <li>CES data form firms: Give the parameter in the CES function for each firm in the "Cournot & Stackelberdg firms". The index c stands for the unit cost of the firm, L stands for the labor coefficient , beta stands for the supply elasticity.</li>
    <li>Cournot or price taker: Select whether the firm acts as a cournot member, i.e., knows exactly the relationship between price and total quantity or acts as a price taker.</li>

</ul>


<h3>
    Input for Bertrand model
</h3>


<ul>
<li>dbert Unit reference demand for the Bertrand model</li>
<li>jdata:information of the firms in Bertrand model, containing:
c-unit cost,w-production quantity</li>
</ul>


<h3>
    Output for Cournot model
</h3>
<ul>
    <li>Firm Quantity influence on other firms: A profit-quantitiy curve and a bar charts that show the variation of the profits of all firms w.r.t the quantity of a certain selected firm. When the quantity of the selected firm changes, quantities of other firms are fixed to the solution of the Nash Equilibrium. User using the app can choose which firm quantity to change and adjust the quantity of that firm.</li>
</ul>


<h3>
    Output for Stackelberg model
</h3>
<ul>
    <li>Difference between Cornot and Stackelberg model: Two bar charts comparing the result of quantity and profits between when there is a leader firm and other firms will respond based on the leader firm's decision and when there is no leader firm and each firm will give the best response.</li>
    <li>Profits w.r.t the quantity of leader firm: A barchart and a plot shows The profits of all the firms with respect to the quantity of leader firm. The pictures also shows when the leader firm are not acting as a leader firm, how the profits of other firms will change, as the orange bars and dash curves shows. User can change the quantity of the selected leader firm to see its impact.</li>
    <li>Quantities w.r.t the leader firm quantity: A bar chart and a plot show how other firms will respond to the leader firm when the leader firm change its quantity. User can change the quantity of the selected leader firm to see its impact.</li>
</ul>


More explanantions about the figure will be shown on the output page.



<h3>
    Output for Bertrand model
</h3>

<ul>
    <li>Bertrand result: Two pictures. The first shows the quantities-price curves of the two firms as the price of the firm 1 varies. The second shows the profit-price curves of the two firms as the price of the firm 1 varies.</li>
    More explanations about the pictures will be shown on the output page.
</ul>


<a name="GAMS model" ></a>

<h1>GAMS Model</h1>

<a href="static_emp2/emp2.gms" target="_blank">Download GAMS model</a>




<h1>Acknowledgements</h1>
<p>
We would like to acknowledge the spectacular instruction we receive from the dedicated faculty at UW-Madison, with special acknowledgment of Prof. Jeffrey Linderoth, Prof. Michael Ferris, Prof. Thomas Rutherford and Prof. Marzena Rostek whose instruction directly informed this case study.
</p>
<a name="References"></a>

<h1>References</h1>

1. Dirkse, S P, and Ferris, M C, MCPLIB: A Collection of Nonlinear Mixed Complementarity Problems. Optimization Methods and Software 5 (1995), 319-345.
2. Engineering and Economic Applications of Complementarity Problems by M.C. Ferris, J.S. Pang (1997).
3. GAMS Model Library : nash.gms http://www.gams.com/modlib/libhtml/nash.htm
4. GAMS Model Type Descriptions http://www.gams.com/modtype/modeltyp.htm 
5. M. C. Ferris and T. S. Munson. Complementarity problems in GAMS and the PATH solver. Journal of Economic Dynamics and Control, 24:165-188, 2000. 
6. M. C. Ferris and K. Sinapiromsaran. Formulating and solving nonlinear programs as mixed complementarity problems. In V.~H. Nguyen,  J.~J. Strodiot, and P.~Tossings, editors, Optimization, volume 481 of Lecture Notes in Economics and Mathematical Systems. Springer-Verlag, 2000 
7. Ferris, Michael C., Mangasarian, Olvi L. and Wright, Stephen J., Linear Programming with MATLAB 
8. Leyffer S., Munson T. Solving Multi-Leader-Follower Games. Mathematics and Computer Science Division (2005) 
9. Lecture Notes on CES Utility by Thomas Rutherford http://www.gamsworld.eu/mpsge/debreu/ces.pdf 
10. Lecture : An Introduction to Complementarity by Michael Ferris  http://pages.cs.wisc.edu/~ferris/talks/aussois-intro.pdf 
11. Lecture : Complementarity Problems and Applications by Michael Ferris http://pages.cs.wisc.edu/~ferris/talks/StockholmEmbed.pdf 
12. Lecture : An Extended Mathematical Programming Framework by Michael Ferris  http://pages.cs.wisc.edu/~ferris/talks/berkeley.pdf 
13. Linear Complementarity, Linear and Nonlinear Programming by Katta G. Murty http://ioe.engin.umich.edu/people/fac/books/murty 
14. An Introduction to Game Theory by Martin J. Osbourne (2004) Oxford University Press, New York, Oxford
15. Microeconomic Analysis, Second Edition by Hal R. Varian, (1984) W.W. Norton & Company - University of Michigan 
16. T. Rutherford, Extension of GAMS for complementarity problems in applied economic analysis, (1994) Journal of Economic Dynamics & Control 
17. William H. Sandholm, Population Games and Evolutionary Dynamics (2010) The MIT Press, Cambridge, Massachusetts
</p>



