<H1>
    Signal-to-Inference-plus-Noise Ratio
</h1>

<h2>
    Problem Statement
</h2>
We consider a multiple-input multiple-output (MIMO) communication system with $n$ transmitters and $n$ receivers. Each transmitter transmits with power $p_{j}$ and the gain from transmitter $j$ to receiver $i$ is $G_{i j}$. The signal power from transmitter $i$ to receiver $i$ is then
$$S_{i}=G_{i i} p_{i}$$
and the interference is
$$I_{i}=\sum_{j \neq i} G_{i j} p_{j}+\sigma_{i}$$
where $\sigma_{i}$ is an additive noise component. In this notebook we consider different strategies for optimizing the signal-to-inference-plus-noise ratio (SINR)
$$s_{i}=\frac{G_{i i} p_{i}}{\sum_{j \neq i} G_{i j} p_{j}+\sigma_{i}}$$
with a bound on the total transmitted power $\sum_{i} p_{i} \leq P$.



We have two ways of optimizing the SINR, leading to two different models.



<h3>
    Maximizing the worst SINR
</h3>

Maximize the smallest $s_{i}$
$$
\begin{aligned}
\text { maximize } & t \\\
\text { subject to } & s\_{i} \geq t \\\
& \sum_{i} p\_{i} \leq P
\end{aligned}
$$

Equivalently we can minimize the inverse,
$$
\begin{aligned}
\operatorname{minimize} & t^{-1} \\\
\text {subject to } & t \left(\sum_{j \neq i} G\_{i j}  p\_{j}+\sigma\_{i} \right) G\_{i i}^{-1} p\_{i}^{-1} \leq 1 \\\
\end{aligned}
$$

which can be rewritten as a geometric programming problem

$$
\begin{aligned}
\operatorname{minimize} & -z \\\
\text { subject to } & \log \left(\sum\_{j \neq i} e^{z+q\_{j}-q\_{i}+\log \left(G\_{i j} / G\_{i i}\right)}+e^{z-q\_{i}+\log \left(\sigma\_{i} / G\_{i j}\right)}\right) \leq 0 \\\
& \log \left(\sum_{i} e^{q\_{i}-\log P}\right) \leq 0
\end{aligned}
$$

with $p_{i}:=e^{q_{i}}$ and $t:=e^{z} .$ To rewrite the geometric program into conic form, we note that

$$
\log \left(\sum\_{i=1}^{n} e^{a\_{i}^{T} x+b\_{i}}\right) \leq 0 \quad \Longleftrightarrow \quad \sum_{i} u\_{i} \leq 1, \quad\left(u\_{i}, 1, a\_{i}^{T} x+b\_{i}\right) \in K\_{\exp }, i=1, \ldots n
$$

The $K_{exp}$ is defined as

$$
K\_{\exp }=\\{ \left(x\_{1}, x\_{2}, x\_{3}\right): x\_{1} \geq x\_{2} e^{x\_{3} / x\_{2}}, x\_{2}>0\\} \cup \\{\left(x\_{1}, 0, x\_{3}\right): x\_{1} \geq 0, x\_{3} \leq 0\\}
$$

<h3>
Maximizing average SINR
</h3>

Alternatively we can maximize the average SINR as 
$$\begin{array}{ll}
\text { maximize } & \sum\_{i} t\_{i} \\\
\text { subject to } & s\_{i} \geq t\_{i} \\\
& 0 \leq p\_{i} \leq P\_{i} \\\
& \sum_{i} p\_{i} \leq P
\end{array}$$

which corresponds to an intractable non-convex bilinear opimization problem. However, in the low-SilNR regime, we can approximate the above problem by maximizing $\sum_{i}$ logtif or equivalenty minimizing $\Pi_{i} t_{i}^{-1}$

$$\begin{array}{cl}
\operatorname{minimize} & \prod\_{i} t\_{i}^{-1} \\\
\text {subject to } & t\_{i}\left(\sum\_{j \neq i} G\_{i j} p\_{j}+\sigma\_{i}\right) G\_{i i}^{-1} p\_{i}^{-1} \leq 1 \\\
& 0 \leq p\_{i} \leq P\_{i} \\\
& \sum_{i} p\_{i} \leq P
\end{array}$$
which again corresponds to a geometric programming problem.

Similarly, we can also write this into a conic programming by replacing $t_i$ with $e^{z_i}$ and $p_i$ with $e^{q_i}$.

<h2>
Embedding GAMS Model
</h2>

GAMS model can be downloaded <a href='static_sinr/SINR.gms' target = '_blank'>here</a>.

<h2>
Reference
</h2>