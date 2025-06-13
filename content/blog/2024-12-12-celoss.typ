#import "/content/blog.typ": *
#import "/src/3rd_party/mathyml/lib.typ" as mathyml
#import mathyml.prelude:*

#show: main.with(
  title: "Cross-entropy loss and its optimization [WIP]",
  desc: "dive into cross-entropy loss and its optimization.",
  date: "2024-12-12",
  tags: (
    "coding",
    "llm",
    "optimization",
  ),
)

#outline(title: none, depth: 1)

= Background

Computing cross-entropy loss becomes significantly more challenging for LLMs. This is primarily due to the extremely large logit and label matrices involved in the calculations, which can lead to high computational costs and memory usage. Recently, several optimization strategies have been proposed to address this issue, starting from a Pytorch GitHub issue.

- #link("https://github.com/pytorch/pytorch/issues/124480")
- #link("https://github.com/mgmalek/efficient_cross_entropy")
- Liger Kernel: #link("https://github.com/linkedin/Liger-Kernel")[github], #link("https://arxiv.org/pdf/2410.10989")[arxiv]
- Cut Your Losses in Large-Vocabulary Language Models: #link("https://arxiv.org/pdf/2411.09009")[arxiv]

All these approaches share a common goal: avoiding the full materialization of the logit matrix. They achieve this by:

1.  chunking the logit matrix
2.  computating the gradient of logit in place

In this blog, I will dive into the cross entropy loss and its optimization strategies.

= Softmax Cross-Entropy

== Forward Pass

Let's begin by understanding the *forward pass* of the cross-entropy loss.

Consider:
- An input vector $bold(x) in RR^d$ representing the logits (unnormalized scores) produced by the model for each class.
- A true label $y in {0, 1, ..., d-1}$ indicating the correct class.

The *softmax function* converts the logits into probabilities:

$
bold(p)_i = (e^(bold(x)_i)) / (sum_(k=1)^d e^(bold(x)_k))
$

Here, $bold(p)_i$ represents the probability of the input belonging to class $i$.

The *cross-entropy loss* for a single instance is then defined as:

$
L = -log(bold(p)_y)
$

Expanding this, we get:

$
L = -log(bold(p)_y) = -log((e^(bold(x)_y))/(sum_(k=1)^d e^(bold(x)_k))) = -log(e^(bold(x)_y)) + log(sum_(k=1)^d e^(bold(x)_k)) = -bold(x)_y + log(sum_(k=1)^d e^(bold(x)_k))
$

== Backward Pass

In general, the gradient of the loss with respect to the input is given by

$
(diff L)/(diff bold(z)_i) = (diff L)/(diff bold(p)_j) (diff bold(p)_j)/(diff bold(z)_i)
$

=== Step 1: Compute $(diff bold(p)_j)/(diff bold(z)_i)$

The result is:
$
(diff bold(p)_j)/(diff bold(z)_i) = cases(
  bold(p)_j(1 - bold(p)_j), "if " j = i,
  -bold(p)_j bold(p)_i, "if " j != i
)
$
The full derivation for the case $j=i$ is:
$
(diff bold(p)_j) / (diff bold(z)_j)
  &= (diff ( (e^(bold(z)_j)) / (sum_(k=1)^N e^(bold(z)_k)) )) / (diff bold(z)_j) \
  &= ( (sum_(k=1)^N e^(bold(z)_k)) dot e^(bold(z)_j) - e^(bold(z)_j) e^(bold(z)_j) ) / ( (sum_(k=1)^N e^(bold(z)_k))^2 ) \
  &= ( e^(bold(z)_j) / (sum_(k=1)^N e^(bold(z)_k)) ) ( 1 - (e^(bold(z)_j)) / (sum_(k=1)^N e^(bold(z)_k)) ) \
  &= bold(p)_j (1 - bold(p)_j)
$
And for $j != i$:
$
(diff bold(p)_j) / (diff bold(z)_i)
  &= (diff ( (e^(bold(z)_j)) / (sum_(k=1)^N e^(bold(z)_k)) )) / (diff bold(z)_i) \
  &= ( -e^(bold(z)_j) dot e^(bold(z)_i) ) / ( (sum_(k=1)^N e^(bold(z)_k))^2 ) \
  &= -bold(p)_j bold(p)_i
$

=== Step 2: Compute $(diff L)/(diff bold(z)_i)$

$
(diff L)/(diff bold(z)_i) & = sum_(j=1)^N (diff (-bold(t)_j log bold(p)_j))/(diff bold(z)_i) \
& = - sum_(j=1)^N bold(t)_j (diff (log bold(p)_j))/(diff bold(z)_i) \
& = - sum_(j=1)^N bold(t)_j 1/bold(p)_j (diff bold(p)_j)/(diff bold(z)_i) \
& = - (bold(t)_i)/(bold(p)_i) (diff bold(p)_i)/(diff bold(z)_i) - sum_(j=1, j!=i)^N (bold(t)_j)/(bold(p)_j) (diff bold(p)_j)/(diff bold(z)_i) \
& = - (bold(t)_i)/(bold(p)_i) bold(p)_i(1 - bold(p)_i) - sum_(j=1, j!=i)^N (bold(t)_j)/(bold(p)_j) (-bold(p)_j bold(p)_i) \
& = -bold(t)_i + bold(t)_i bold(p)_i + sum_(j=1, j!=i)^N bold(t)_j bold(p)_i \
& = -bold(t)_i + sum_(j=1)^N bold(t)_j bold(p)_i \
& = -bold(t)_i + bold(p)_i sum_(j=1)^N bold(t)_j \
& = -bold(t)_i + bold(p)_i \
& = bold(p)_i - bold(t)_i
$

So,
$
(diff L)/(diff bold(z)) = bold(p) - bold(t)
$

== Gradient in Matrix Form

For batch computations, it's efficient to represent gradients in matrix form.

Given:
- $bold(P) in RR^(n times d)$: Matrix of predicted probabilities for a batch of size $n$.
- $bold(Z) in RR^(n times d)$: Matrix of logits.
- $bold(Y) in RR^(n times d)$: One-hot encoded true labels.

The gradient with respect to the logits is:

$
(diff bold(P)_(i, j))/(diff bold(Z)_(i, k)) = bold(P)_(i, j) (delta_(j, k) - bold(P)_(i, k))
$

$
(diff L)/(diff bold(Z)) = bold(P) - bold(Y)
$

Normalized by batch size, the overall gradient of the loss is:

$
(diff L)/(diff bold(Z)) = 1/n (bold(P) - bold(Y))
$

= Linear-Softmax-Cross-Entropy

Cross-entropy loss is typically preceded by a *linear (fully connected) layer* and followed by a *softmax activation*. If we can fuse the linear layer and softmax activation, we may avoid the full materialization of the logit matrix.

- Input before the final linear layer: $bold(X) in RR^(n times d_"in")$
- Linear weights: $bold(W) in RR^(d_"in" times d_"out")$
- Linear bias: $bold(b) in RR^(d_"out")$
- Labels: $y in {0, 1, ..., n-1}$, representing the true classes for each instance in the batch.

== Forward Pass

With a linear transformation, the input $bold(X)$ is transformed linearly using the weights and bias:

$
bold(Z) = bold(X) bold(W) + bold(b)
$

Softmax:

$
bold(P)_(i, j) = (e^(bold(Z)_(i, j)))/(sum_(k=1)^(d_"out") e^(bold(Z)_(i, k)))
$

Cross-entropy loss is computed for each instance and then averaged over the batch:

$
L_i = -log(bold(P)_(i, y_i))
$

$
L = 1/n sum_(i=1)^n L_i
$

== Backward Pass

Gradient of $bold(Z)$:
$
(diff L)/(diff bold(Z)) = 1/n (bold(P) - bold(Y))
$

Gradient of $bold(W)$:
$
(diff L)/(diff bold(W)) = bold(X)^T (diff L)/(diff bold(Z))
$

Gradient of $bold(b)$:
$
(diff L)/(diff bold(b)) = sum_(i=1)^n (diff L)/(diff bold(Z)_i)
$

Gradient of input $bold(X)$:
$
(diff L)/(diff bold(X)) = (diff L)/(diff bold(Z)) bold(W)^T
$

== Summary of Gradients

#table(
  columns: 3,
  align: (auto, auto, auto),
  [*Parameter*], [*Formula*], [*Dimensions*],
  $bold(Z)$, $bold(Z) = bold(X) bold(W) + bold(b)$, $[n, d_("out")]$,
  $bold(P)$, $bold(P) = "softmax"(bold(Z))$, $[n, d_("out")]$,
  $L$, $L = -1/n sum log(bold(P)_(i, y_i))$, $"Scalar"$,
  $d bold(Z)$, $d bold(Z) = 1/n(bold(P) - bold(Y))$, $[n, d_("out")]$,
  $d bold(W)$, $d bold(W) = bold(X)^T d bold(Z)$, $[d_("in"), d_("out")]$,
  $d bold(b)$, $d bold(b) = "sum"(d bold(Z))$, $[d_("out")]$,
  $d bold(X)$, $d bold(X) = d bold(Z) bold(W)^T$, $[n, d_("in")]$,
)

= Optimization Strategies

- *Chunking the logit matrix*:
  Chunking over the batch can avoid materializing the full logit matrix. The logit matrix is divided into chunks over the batch size dimension, and the cross-entropy loss is computed for each chunk. The final loss is the sum of the losses of all chunks.

- *Compute the gradient of logit in place*:
  The gradient of the logit matrix is computed in place, and the gradient of the input is computed by multiplying the gradient of the logit matrix with the weight matrix.

== #link("https://github.com/mgmalek/efficient_cross_entropy")[efficient_cross_entropy]

== #link("https://github.com/linkedin/Liger-Kernel")[liger kernel]

== #link("https://arxiv.org/pdf/2411.09009")[cut your losses in large-vocabulary language models]












