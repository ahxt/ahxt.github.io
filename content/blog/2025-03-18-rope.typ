#import "/content/blog.typ": *
#import "/src/3rd_party/mathyml/lib.typ" as mathyml
#import mathyml.prelude:*

#show: main.with(
  title: "RoPE: Rotational Position Embedding",
  desc: "A simple and effective positional embedding for transformer models",
  date: "2025-03-18",
  tags: (
    "transformer",
    "positional-embedding",
    "paper",
  ),
)



#outline(title: none, depth: 1)


= Notation

#table(
  columns: (auto, auto),
  align: (left, left),
  // table.header(
  //   [*Notation*], [*Description*],
  // ),
  [*Notation*], [*Description*],
  $bold(q)_m$, [$m$-th query vector without positional information],
  $bold(k)_n$, [$n$-th key vector without positional information], 
  $bold(q)'_m$, [$m$-th query vector with positional information],
  $bold(k)'_n$, [$n$-th key vector with positional information],
)


= Motivations: We Pursue Relative Positional Embedding
To incorporate positional information into the attention mechanism, we need to transform the original query and key vectors. The functions $f(dot, dot)$ encode the position indices $m$ and $n$ into the query and key vectors respectively, resulting in position-aware representations $bold(q)'_m$ and $bold(k)'_n$.

$ bold(q)'_m = f(bold(q)_m, m), quad bold(k)'_n = f(bold(k)_n, n) $

Typically, the attention score between a query at position $m$ and a key at position $n$ can be represented as a function $g$ that depends on both the content vectors ($bold(q)_m$ and $bold(k)_n$) and their absolute positions ($m$ and $n$) as follows:

$ "Attn"(bold(q)'_m, bold(k)'_n) = g(bold(q)_m, bold(k)_n, m, n) $

but we want the attention score to only depend on the relative position ($m-n$) rather than absolute positions $m$ and $n$, as relative position is easier to generalize to unseen sequence lengths.


*Goal of relative positional embedding*: Thus our goal is to find a function $g$ which is only a function of $bold(q)_m$, $bold(k)_n$, and $m-n$, instead of $m$ and $n$ themselves as follows:

$ "Attn"(bold(q)'_m, bold(k)'_n) = g(bold(q)_m, bold(k)_n, m-n) $

The RoPE is a solution to this goal.


= RoPE (Rotational Position Embedding)

RoPE is a positional embedding that is a function of the relative position $m-n$, which rotates the query and key vectors and then computes the attention score, which is a function of the relative position $m-n$.

The base idea of RoPE is to rotate the query and key vectors by a certain angle, thus their dot product is a function of the relative position $m-n$. RoPE used the property of rotation matrix multiplication. When we need to rotate a 2-dimensional vector $vec(x, y)$ by an angle $theta$, we can multiply a rotation matrix $mat(cos theta, -sin theta; sin theta, cos theta)$ to the vector $vec(x, y)$, to get the rotated vector $vec(x cos theta - y sin theta, x sin theta + y cos theta)$.

In the following, suppose the query and key vectors are 2-dimensional vectors. We can rotate the query and key:

$
bold(q)'_m = f(bold(q)_m, m) =
mat(
  cos m theta, -sin m theta;
  sin m theta, cos m theta
) vec(
  q_m^(1),
  q_m^(2)
)
$


$
bold(k)'_n = f(bold(k)_n, n) =
mat(
  cos n theta, -sin n theta;
  sin n theta, cos n theta
) vec(
  k_n^(1),
  k_n^(2)
)
$

The attention score is then:

$
"Attn"(bold(q)'_m, bold(k)'_n)
  &= bold(q)'_m^T dot bold(k)'_n \
  &= [ mat(cos m theta, -sin m theta; sin m theta, cos m theta) vec(q_m^(1), q_m^(2)) ]^T
     dot
     [ mat(cos n theta, -sin n theta; sin n theta, cos n theta) vec(k_n^(1), k_n^(2)) ] \
  &= mat(q_m^(1), q_m^(2))
     [
       mat(cos m theta, -sin m theta; sin m theta, cos m theta)^T
       mat(cos n theta, -sin n theta; sin n theta, cos n theta)
     ]
     vec(k_n^(1), k_n^(2)) \
  &= mat(q_m^(1), q_m^(2))
     [
       mat(cos m theta, sin m theta; -sin m theta, cos m theta)
       mat(cos n theta, -sin n theta; sin n theta, cos n theta)
     ]
     vec(k_n^(1), k_n^(2)) \
  &= mat(q_m^(1), q_m^(2))
     mat(
       cos((n - m)theta), -sin((n - m)theta);
       sin((n - m)theta), cos((n - m)theta)
     )
     vec(k_n^(1), k_n^(2)) \
  &= q_m^(1) [k_n^(1) cos((n - m)theta) - k_n^(2) sin((n-m)theta)] \
  & quad + q_m^(2) [k_n^(1) sin((n-m)theta) + k_n^(2) cos((n-m)theta)] \
  &= (q_m^(1) k_n^(1) + q_m^(2) k_n^(2)) cos((n-m)theta) + (q_m^(2) k_n^(1) - q_m^(1) k_n^(2)) sin((n-m)theta)\
  &= g(bold(q)_m, bold(k)_n, m-n)
$

thus we have shown that the attention score is a function of $bold(k)_n$, $bold(q)_m$, and their relative position $m-n$, not the absolute positions $m$ and $n$ themselves.


=  RoPE Implementation (Half-and-Half Pairing)


This is the method used in your Python code and in many popular implementations like LLaMA. It is chosen for its extreme efficiency with vectorized operations. Instead of pairing adjacent dimensions (which is intuitive), this method pairs the *first half of the dimensions with the second half*.

For a vector $bold(q)$ with dim$=d$:

- *Pair 0:* dimension $0$ is paired with dimension $d/2$.  $(q^0, q^(d/2))$
- *Pair 1:* dimension $1$ is paired with dimension $d/2 + 1$. $(q^1, q^(d/2 + 1))$
- ...
- *Pair $d/2-1$:* dimension $d/2-1$ is paired with dimension $d-1$. $(q^(d/2-1), q^(d-1))$

In practice, the query and key vectors are not 2-dimensional vectors, but $d$-dimensional vectors ($d%2=0$).

$
bold(q)_m = vec(
  q_m^(1),
  q_m^(2),
  dots.v,
  q_m^(d)
), quad bold(k)_n = vec(
  k_n^(1),
  k_n^(2),
  dots.v,
  k_n^(d)
)
$

we then group the query and key vectors into $d/2$ pairs, and rotate each pair by a different angle $theta_i$ ($i=1,2,dots,d/2$). Usually we make the following pairs: $[vec(q_m^(0), q_m^(d/2)), vec(k_m^(0), k_m^(d/2))], [vec(q_m^(1), q_m^(d/2+1)), vec(k_m^(1), k_m^(d/2+1))], dots, [vec(q_m^(d/2-1), q_m^(d-1)), vec(k_m^(d/2-1), k_m^(d-1))]$.



For each pair $i$ ($i=0,1,dots,d/2-1$), we rotate by an angle $theta^i = 1 / omega^((2i)/d) = 1 / 10000^((2i)/d)$, where $omega$ is a base frequency (typically $10000$), $i$ is the $i$-th dimension $i in [0, 1, 2, dots, d/2-1]$, and $d$ is the dimension of the query and key vectors. 

This means higher dimensions get rotated by larger angles, creating a spectrum of different frequencies in the positional encoding.

The rotated query vector becomes:

$
bold(q)'_m = vec(
  q_m^(1) cos(theta^(0) m) - q_m^(d/2+1) sin(theta^(0) m),
  q_m^(2) cos(theta^(2/d) m) - q_m^(d/2+2) sin(theta^(2/d) m),
  dots.v,
  q_m^(d/2) cos(theta^((d-2)/d) m) - q_m^(d) sin(theta^((d-2)/d) m),
  q_m^(1) sin(theta^(0) m) + q_m^(d/2+1) cos(theta^(0) m),
  q_m^(2) sin(theta^(2/d) m) + q_m^(d/2+2) cos(theta^(2/d) m),
  dots.v,
  q_m^(d/2) sin(theta^((d-2)/d) m) + q_m^(d) cos(theta^((d-2)/d) m)
)
= vec(
  q_m^(1) cos(theta^(0) m) - q_m^(d/2+1) sin(theta^(0) m),
  q_m^(2) cos(theta^(2/d) m) - q_m^(d/2+2) sin(theta^(2/d) m),
  dots.v,
  q_m^(d/2) cos(theta^((d-2)/d) m) - q_m^(d) sin(theta^((d-2)/d) m),
  q_m^(d/2+1) cos(theta^(0) m) + q_m^(1) sin(theta^(0) m),
  q_m^(d/2+2) cos(theta^(2/d) m) + q_m^(2) sin(theta^(2/d) m),
  dots.v,
  q_m^(d) cos(theta^((d-2)/d) m) + q_m^(d/2) sin(theta^((d-2)/d) m)
)
$

Similarly for the key vector:

$
bold(k)'_n = vec(
  k_n^(1) cos(theta^(0) n) - k_n^(d/2+1) sin(theta^(0) n),
  k_n^(2) cos(theta^(2/d) n) - k_n^(d/2+2) sin(theta^(2/d) n),
  dots.v,
  k_n^(d/2) cos(theta^((d-2)/d) n) - k_n^(d) sin(theta^((d-2)/d) n),
  k_n^(1) sin(theta^(0) n) + k_n^(d/2+1) cos(theta^(0) n),
  k_n^(2) sin(theta^(2/d) n) + k_n^(d/2+2) cos(theta^(2/d) n),
  dots.v,
  k_n^(d/2) sin(theta^((d-2)/d) n) + k_n^(d) cos(theta^((d-2)/d) n)
) = vec(
  k_n^(1) cos(theta^(0) n) - k_n^(d/2+1) sin(theta^(0) n),
  k_n^(2) cos(theta^(2/d) n) - k_n^(d/2+2) sin(theta^(2/d) n),
  dots.v,
  k_n^(d/2) cos(theta^((d-2)/d) n) - k_n^(d) sin(theta^((d-2)/d) n),
  k_n^(d/2+1) cos(theta^(0) n) + k_n^(1) sin(theta^(0) n),
  k_n^(d/2+2) cos(theta^(2/d) n) + k_n^(2) sin(theta^(2/d) n),
  dots.v,
  k_n^(d) cos(theta^((d-2)/d) n) + k_n^(d/2) sin(theta^((d-2)/d) n)
)
$

When we compute the attention score between these rotated vectors, each pair contributes a term that depends on the relative position $(m-n)$, similar to the 2D case we analyzed earlier. The different frequencies $omega^(2i/d)$ allow the model to capture position-dependent patterns at different scales.


Thus we have:

$bold(q)'_m^T dot bold(k)'_n &= [(q_m^(1) k_n^(1) + q_m^(d/2) k_n^(d/2)) cos((n-m)theta) + (q_m^(d/2) k_n^(1) - q_m^(1) k_n^(d/2)) sin((n-m)theta)] + \
& dots + [(q_m^(d/2-1) k_n^(d/2-1) + q_m^(d-1) k_n^(d-1)) cos((n-m)theta) + (q_m^(d-1) k_n^(d/2-1) - q_m^(d/2-1) k_n^(d-1)) sin((n-m)theta)] \
  &= g(bold(q)_m, bold(k)_n, m-n)
$






= Example: 

Let's walk through how the code achieves this with a concrete example where dim $=8$. The input query vector is $bold(q) = [q^0, q^1, q^2, q^3, q^4, q^5, q^6, q^7]$.


*Pairing*: The pairs will be: $(q^0, q^4), (q^1, q^5), (q^2, q^6), (q^3, q^7)$.


*Frequency*: There will be $d/2 = 4$ unique angles for a given position $m$: $theta^0, theta^1, theta^2, theta^3$. These angles are calculated based on the position $m$ and the pair index $i in [0, 1, 2, 3]$:
$ theta^i_m = 1 / 10000^((2i)/d) dot m $
where $d$ is the dimension. For example, $theta^0_m = 1 / 10000^((2*0)/8) dot m = 1 / 10000^0 dot m = 1 dot m = m$


We construct the angles for a given position $m$ as $[theta^0_m, theta^1_m, theta^2_m, theta^3_m, theta^0_m, theta^1_m, theta^2_m, theta^3_m]$.

The final `cos` and `sin` tensors will therefore have this duplicated structure. For position `m`:

  $cos_m = [cos(theta^0_m), cos(theta^1_m), cos(theta^2_m), cos(theta^3_m), cos(theta^0_m), cos(theta^1_m), cos(theta^2_m), cos(theta^3_m)]$

  $sin_m = [sin(theta^0_m), sin(theta^1_m), sin(theta^2_m), sin(theta^3_m), sin(theta^0_m), sin(theta^1_m), sin(theta^2_m), sin(theta^3_m)]$


Now, let's see how the rotation is applied to $bold(q) = [q^0, q^1, q^2, q^3, q^4, q^5, q^6, q^7]$.

We construct half-rotated query vector as $bold(q)_("rotated") = [-q^4, -q^5, -q^6, -q^7, q^0, q^1, q^2, q^3]$.

We then construct the query vector $bold(q)'_m$ as:

$bold(q)'_m = (bold(q) dot.circle cos) + (bold(q)_("rotated") dot.circle sin)$


If we let our 2D vector be $(q_0, q_4)$ and the rotation angle be $theta^0_m$, the standard 2D rotation formulas are:
- $q'_0 = q_0 cos(theta^0_m) - q_4 sin(theta^0_m)$
- $q'_4 = q_0 sin(theta^0_m) + q_4 cos(theta^0_m)$


As you can see, the code perfectly implements the 2D rotation for the pair $(q_0, q_4)$. This same logic applies simultaneously to all other pairs: $(q_1, q_5)$, $(q_2, q_6)$, $(q_3, q_7)$.

- $q'_1 = q_1 cos(theta^1_m) - q_5 sin(theta^1_m)$
- $q'_5 = q_1 sin(theta^1_m) + q_5 cos(theta^1_m)$
- $q'_2 = q_2 cos(theta^2_m) - q_6 sin(theta^2_m)$
- $q'_6 = q_2 sin(theta^2_m) + q_6 cos(theta^2_m)$
- $q'_3 = q_3 cos(theta^3_m) - q_7 sin(theta^3_m)$
- $q'_7 = q_3 sin(theta^3_m) + q_7 cos(theta^3_m)$


