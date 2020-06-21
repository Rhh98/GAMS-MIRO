<h2>Contents</h2>
<ul>
<li><a href="#introduction">Introduction</a></li>
<li><a href="#problem">Problem Statement</a></li>
<li><a href="#math">Mathematical Model</a></li>
<li><a href="#applet">JAVA Applet</a></li>
<li><a href="#result">Output</a></li>
<li><a href="#references">References</a></li>
</ul>


<a id="introduction"></a>
<h2> Introduction </h2> 
<p>In the manufacturing field material handling is a necessary but costly activity. Increased material handling will create extra costs due to labor, machine and time requirements while possibly causing quality defects and increasing shop floor lead time. That is why often in practice the shop floor layouts are redesigned to minimize material handling related costs. Though making layout changes on the shop floor and moving machines also have associated costs. These costs are incurred since the production needs to be paused and labor hours are required to make the necessary changes to the layout. </p>

<p> This real life layout redesign decision can be modeled and solved as an optimization problem. The objective would be to minimize all costs including cost of making layout changes and cost of material handling. Figure 1 shows the general layout of any manufacturing facility  </p>

<img src="http://neos-dev-1.neos-server.org/guide/sites/default/files/layout_1.jpg" alt="Facility Layout">

<p><a href="#top">Back to the top</a></p>
<hr>
<a id="problem"></a>
<h2> Problem Statement </h2> 
<p> A facility layout optimization model is presented that consists of four machines: CNC, Mill, Drill, and Punch. These machines are the most common machines in any manufacturing facility. There are also a set of three products with pre-specified routings as shown below:</p>
<ul>
<li>P1: Receiving -> CNC -> Drill -> Punch -> Shipping</li>
<li>P2: Receiving -> Mill -> Drill -> Punch -> Shipping</li>
<li>P3: Receiving -> CNC -> Drill -> Mill -> Punch -> Shipping</li>
</UL>

<p> The Objetive function, decision variables and constraints are presented below: </p>
<h3> <u> Objective Function and Decision Variables</u> </h3>
<p>The objective function is to minimize the total cost of material handling and cost of layout changes. The material handling cost is calculated using Euclidean distances between the locations of work centers and the routing that needs to be followed by each product family times the cost associated for a unit of movement. The cost of changes in the layout is calculated by summing the cost associated with moving each machine over the set of machines that are moved. Cost of moving a machine is assumed to be \$300/distance and cost of material handling is \$100/distance</p>
<p>The decision of moving a machine or not is made and the new location of a machine is calculated by the optimization program. 
</p>

<h3> <u> Assumptions and Constraints </u></h3>
<p>Lower left corner each machine is assumed to be the co-ordinates of the machine. The constraints as shown below:</p>
<ol>
<li><b>Minimum Distance Constraint:</b>  In a manufacturing setting due to quality reasons, specific work centers should not be adjacent to one another. Thus a minimum distance between two work centers can be specified by the user and used as a constraint in redesigning the layout. </li>
<li><b>Location Constraint:</b> Each work center has a constraint for its location and movement in the floor space which is defined by rectangular region. </li>
</oL>

<p><a href="#top">Back to the top</a></p>
<hr>
<a id="math"></a>
<h2> Mathematical Model </h2>
<h3><i><b> Sets:</b></i><h3>
<p>
$P:$ Set of products
$M:$ Set of machines
$S:$ Set of Shipping and Receiving 
$N=M\cup S$ 
</p>
<h3><i> <b>Parameters:</b></i><h3>
<p>
$a_{p,n_1,n_2}:$ Binary variable representing routing of product $p$ between $n_1$ and $n_2$, $p \in P, n_1,n_2 \in N$
$xo_{n_1}$ Initial x-coordinate of $n_1$, $n_1 \in N$
$yo_{n_1}$ Initial y-coordinate of $n_1$, $n_1 \in N$
$CM_m:$ Cost of moving machine $m$ per unit distance, $m \in M$
$CH_p:$ Cost of material handling per unit distance for product $p$, $p \in P$
$MD_{m_1,m_2}:$ Minimum distance between machine $m_1$ and $m_2$, $m_1,m_2 \in M$
$c:$ Constant distance maintained between any machines
$x1_m:$ Lower x-coordinate for machine $m$ location, $m \in M$
$y1_m:$ Lower y-coordinate for machine $m$ location, $m \in M$
$x2_m:$ Upper x-coordinate for machine $m$ location, $m \in M$
$y2_m:$ Upper y-coordinate for machine $m$ location, $m \in M$
</p>

<h3><i> <b>Decision Variables:</b></i><h3>
<p>
$x_m:$ Final x-coordinate of machine $m$, $m \in M$
$y_m:$ Final y-coordinate of machine $m$, $m \in M$
</p>
<hr>
<h3><i><b> Objective Function:</b></i><h3>
<p>
\begin{equation*}
TC = min\{\sum_{m \in M}CM_m\sqrt{(x_m-xo_m)^2+(y_m-yo_m)^2} + \sum_{p \in P} \sum_{n_1 \in N} \sum_{n_2 \in N}a_{p,n_1,n_2}CH_p\sqrt{(x_{n_1}-x_{n_2})^2+(y_{n_1}-y_{n_2})^2}\}
\end{equation*}
</p>

<h3><i><b> Shipping and Receiving Constraint:</b></i><h3>
<p>
\begin{eqnarray*}
x_{s} &=& xo_s; \forall s \in S \\
y_{s} &=& yo_s; \forall s \in S \\
\end{eqnarray*}
</p>

<h3><i> <b>Minimum Distance Constraint:</b></i><h3>
<p>
\begin{equation*}
\sqrt{(x_{m_1}-x_{m_2})^2+(y_{m_1}-y_{m_2})^2} \geq MD_{m_1,m_2} +c; \forall m_1,m_2 \in M, m_1 \neq m_2
\end{equation*}
</p>

<h3><i><b> Location Constraint:</b></i><h3>
<p>
\begin{eqnarray*}
x_m &\geq& x1_m; \forall m \in M \\
y_m &\geq& y1_m; \forall m \in M \\
x_m &\leq& x2_m; \forall m \in M \\
y_m &\leq& y2_m; \forall m \in M \\
\end{eqnarray*}
</p>

<p><a href="#top">Back to the top</a></p>
<hr>
<a id="applet"></a>
<h2> JAVA Applet </h2>
<p> The applet takes the inputs from the user and solves the mixed integer non-linear programing model (MINLP) using baron solver.<p>

<h3><u> User Inputs </u>
<p>
<ul>
<li>Initial co-ordinates of each machine</li>
<li>Minimum distance between machines</li>
<li>Location constraint for a machine (based on the rectangular region)</li>
</UL>
</p>

<h3><u> Output Status </u>
<p>
<ul>
<li><b>Not Optimized:</b> Initial status of the applet</li>
<li><b>Optimized:</b> Machines placed at optimal position along with a green notification at bottom</li>
<li><b>Infeasible:</b> Status change if the problem is infeasible</li>
</UL>
</p>

<Body>
<applet archive="http://neos-dev-1.neos-server.org/guide/sites/default/files/SignedLayout_0.jar,http://neos-dev-1.neos-server.org/guide/sites/default/files/casestudies/Commons-logging-1.1.jar,http://neos-dev-1.neos-server.org/guide/sites/default/files/casestudies/Ws-commons-util-1.0.2.jar,http://neos-dev-1.neos-server.org/guide/sites/default/files/casestudies/Xmlrpc-client-3.1.3.jar,http://neos-dev-1.neos-server.org/guide/sites/default/files/casestudies/Xmlrpc-common-3.1.3.jar" code="mainGame.Starting" height="610" width="800"></applet>

<p><a href="#top">Back to the top</a></p>
<hr>
<a id="result"></a>
<h2> Output </h2>
<h3><u> Initial Layout</u><h3>
<p>
<ul>
<li><b> Co-ordinates:</b> CNC: (100,200), Drill: (200,100), Mill: (300,100), Punch: (100,300) </li>
<li><b> Min Distance:</b> CNC - Mill: 50, CNC - Drill: 50, CNC - Punch: 50 </li>
<li><b> Location:</b> Entire facility for all the machines</li>
<li><b> Goal:</b> Optimize the given layout</li>
<li><b> Status:</b> Currently not optimized</li>
</ul>
</p>
<img src="http://i39.tinypic.com/35ba8g5.png" alt="Initial Layout">
<h3><u> Final Layout</u><h3>
<p>
<ul>
<li><b>  New Co-ordinates:</b> CNC: (155,207), Drill: (200,273), Mill: (228,264), Punch: (221,293) </li>
<li><b> Min Distance:</b> CNC - Mill: 50, CNC - Drill: 50, CNC - Punch: 50 </li>
<li><b> Location:</b> Entire facility for all the machines</li>
<li><b> Status:</b>Optimized</li>
</ul>
</p>
<img src="http://i39.tinypic.com/2z6fjg9.png" alt="Final Layout">

<p><a href="#top">Back to the top</a></p>
<hr>
<a id="references"></a>
<h2><b>References</b></h2>
<p> <oL><Li> Course ISYE 635 slides, Tools and Enviroments for Optimization,  Spring 2013 </li>
</ol>
<p><a href="#top">Back to the top</a></p>
<hr>
