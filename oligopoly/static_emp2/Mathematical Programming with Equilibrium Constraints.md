<h1>Mathematical Programming with Equilibrium Constraints</h1>
<p> Mathematical programs with equilibrium constraints (MPEC) refer to a class of constrained optimization problems with variational inequalities as constraints on the optimization problem.  In general an MPEC consists of two sets of variables: x &isin; <b>R</b><sup>n</sup> and y &isin; <b>R</b><sup>m</sup>.  Typically x contains the design variables and y contains the primary variables of a variational inequality that is parameterized by x.  The following are givens for a complete formulation: the "first level objective function" F : <b>R</b><sup>n+m</sup> &rarr; <b>R&#773;</b>, the joint feasible region Z &sube; <b>R</b><sup>n+m</sup>, the "second level equilibrium function" F : <b>R</b><sup>n+m</sup> &rarr; <b>R&#773;</b>, and a set-valued mapping C : <b>R</b><sup>n + m</sup> &rarr; <b>R</b><sup>m</sup> where for each 
x &isin; <b>R</b><sup>n</sup>, C(x) &sube; <b>R</b><sup>m</sup> is the constraint set. <br>
<b>DEFINITION</b> - <b>MPEC</b> : given the definition of x and y above we have, 
<center> min f( x, y ) </center>
<center> s.t. x, y &isin; Z </center>
<center> y solves (F( x, &sdot; ), C( x )) . </center>
The special case where (F( x, &sdot; ), C( x )) is equivalent to a complementarity system, the above problem can be formulated as a minimisation problem with mixed complementarity constraint : <br>
<center> min f( x, u, v, w ) </center>
<center> s.t. ( x, u, v, w ) &isin; Z , </center>
<center> H( x, u, v, w ) = 0 , </center>
<center> 0 &le; u &perp; v &ge; 0 , </center>
where (u,v,w) is the concatenation of the y variables, the slacks and multipliers of the constraints that define the set C(x), f and Z.  H is a vector-valued function that summarizes the functional constraints of the y variables
</p>

<h1>Mixed Complementarity Problem</h1>
<p>
In order for a solution to a mixed complementarity problem to be solved using General Algebraic Modeling System (GAMS) the problem must have a particular correct formulation.  A workable MCP formulation for the equilibrium problem needs to incorporate individual simplex constraints which do not render the mapping singular at the equilibrium.   The model declaration in GAMS requires that we explicitly state our complementarity associations for equations and variables.  The syntax is,
MODEL  model_name  /  equ1.var1,  equ2.var2, ... / ;
This statement will be more clear after the following sections and reference to the attached GAMS model.
Letting R&#773; := {R, &infin;, -&infin;}, denote the extended real space for the following formulation :
<b>DEFINITION</b> - <b>MCP</b> : Given a function F : R<sup>n</sup> &rarr; R<sup>n</sup> and bounds l, u &isin; R&#773;<sup>n</sup> ,
<center>find  x &isin; R<sup>n</sup> , u, v &isin; R<sup>n</sup><sub>+</sub> </center>
<center>F(x) = w - v ,</center>
<center>l &le; x &le; u ,</center>
<center>s.t. (x - l)'w = 0 ,</center>
<center> (u - v)'v = 0 .</center> 
We adopt the following notation to indicate a complementarity function / variable pair and its associated bounds :<br>
<center> f(x) &ge; 0 , x &ge; 0 , &perp; </center>
This is understood to mean that as well as satisfying the indicated constraints, we have &lang; f(x), x &rang; = 0.  We can rewrite the above condition equivalently as,
<center> x&#773;<sub>i</sub> f( x&#773;<sub>i</sub> ) = 0 &forall; i </center>
where x&#773;<sub>i</sub> satisfies the inequalities. <br>
Also note that the complementarity function does not have an objective function to be optimised but finds dual feasible pairs which satisfy complementary slackness (complementarity conditions).  We know by SPNE that all games where players always know what node of a decision tree they are at will always have at least one MS - SPNE. We have by the Lemke-Howson method that quadratic programs always terminate in a solution in the case of finite bimatrix game.  Because a zero-sum game is a special case of quadratic programs solvable as a convex LP we have that all linear simultaneous games are solvable as an LCP where Q = 0 and each $A$ corresponds to a payoff matrix; which are made nonnegative by an additive transformation.  We note that an LCP is described above and is a special case of the MCP described in this section.
</p>

<h1>Solution to Cournot by Complementarity</h1>
<p>
Given the formulation above we have that a NE is satisfied by the vector q<sup>*</sup> such that, 
<center> &forall; i ,  q<sup>*</sup> &isin; <b>argmax</b><sub>q<sub>i</sub> &ge; 0</sub> q<sub>i</sub>p( q<sub>i</sub> + &Sigma;<sub>j &ne; i</sub>q<sub>j</sub><sup>*</sup>) - c<sub>i</sub>(q<sub>i</sub>) 
</center>
The KKT Conditions for our NE take the following form, <br>
<center> &forall; i ,  &nabla;c<sub>i</sub>(q<sub>i</sub>) - p(<b>Q</b>) - q<sub>i</sub>&nabla;p(<b>Q</b>) &ge; 0 ,  q<sub>i</sub> &ge; 0 , &perp;      (<b>NE</b>)    
</center>
This describes our NE conditions which are both necessary and sufficient for equilibrium.  See Ferris, Dirkse (1995) which is the source of this definition and where this problem is originally stated.  Also see the updated nash.gms (NASH, SEQ=269) which has the solution to the Cournot problem by MCP as well as the solution the the Stackelberg problem by MPEC.  Our GAMS model closely follows the description found in this paper and this model as we are describing solution to the same canonical microeconomics problem.
</p>

<h1>Solution to Bertrand by Complementarity</h1>
<p>
We assume a model formulation similar to our linear model we defined, save that we suppose continuous strategies and proportional sharing of the market.  As in the Cournot solution by complementarity our problems KKT conditions are both necessary and sufficient conditions for our optimal solution and a NE.  We define them here as,
<center>&forall; i , p<sub>i</sub> &nabla; q<sub>i</sub>( p<sub>i</sub>, p<sub>-i</sub> ) - c<sub>i</sub> ,  p<sub>i</sub>  &ge; 0  ,  &perp;  (<b>NE</b>)
</center>
We note that this is not a demonstration of the classical Bertrand model which has a discontinuous  allocation of market share as a function of firm prices.  This model does not demonstrate the Bertrand paradox because market share is no longer allocated in a Bertrand fashion.  There is no meaningful direct comparison between our Cournot model and our Bertrand model because the model formulations are not congruous. </p>

<h1>Solution to Stackelberg by Complementarity</h1>
<p>The Stackelberg game problem can be formulated as an MPEC where the second level equilibrium function is a Cournot game solved by complementarity and the first level objective function is the Stackelberg-leader's non-linear optimisation problem.  This is immediate by annalyzing the formulation of the problem as mutual best response where the Stackelberg-leader optimises by internalizing the best response dynamics of the Stackelberg-followers.  We note that this defines an SPNE because there are 2 subgames, the initial subgame of the Stackelberg-leader that contains all the following decision nodes and the Stackelberg-follower's problem where the remaining players simulataneously optimize given the leader's decision. <br><br>

We note that our MPEC formultion is only appropriate for markets with a single Stackelberg-leader.  For an expopsition of multi-leader-follower games see, Leyffer, Munson (2005).  They explain our MPEC formultaion for single-leader game and offer formulations of multi-leader-follower games as a nonlienaer complementarity problem (NCP) and as a nonlinear problem (NLP).  It is also worth noting at this point that the GAMS model types page states that work on MPEC algorithms is ongoing and their performance on more difficult problems is not as certain as other formulations.  We assert here that the single Stackelberg-leader problem is clearly an MPEC from an intuition stand point and the NLP formulation is very complicated.