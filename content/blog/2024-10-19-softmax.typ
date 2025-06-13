#import "/content/blog.typ": *
#import "/src/3rd_party/mathyml/lib.typ" as mathyml
#import mathyml.prelude:*

#show: main.with(
  title: "Softmax and its triton implementation",
  desc: "implementing softmax using triton",
  date: "2024-10-19",
  author: "Xiaotian Han",
  tags: ("coding",),
)

#outline(title: none, depth: 1)


= Background

The softmax function is a fundamental operation in deep learning that converts vectors of real numbers into probability distributions. This blog post explores the softmax function's implementation and optimization using Triton, a programming framework for efficient GPU computations.

#block(
  fill: luma(240),
  inset: 10pt,
  radius: 4pt,
  [
    *TL;DR* \
    - dive into softmax, from math to implementation, from vector to matrix. \
    - torch and triton implementations, with reference code and speed comparison.
  ]
)

The *softmax function* transforms an input vector into a *probability distribution* where all elements sum to 1.

== softmax - vector form

$ bold(o)_i = "softmax"(bold(x)_i) = (e^(bold(x)_i))/(sum_(j=1)^d e^(bold(x)_j)) $

where:
- $bold(x) in RR^d$: input vector.
- $bold(o) in RR^d$: output vector, probability distribution.

= Gradient of softmax (vector form)

We will compute gradients $(partial L)/(partial bold(x))$ given $(partial L)/(partial bold(o))$, where $L$ is loss function, $bold(o)$ is softmax output.

== Jacobian matrix

softmax is a vector function, the Jacobian matrix is the matrix of all partial derivatives:

$ (partial bold(o))/(partial bold(x)) = bold(J) =
mat(
  (partial bold(o)_1)/(partial bold(x)_1), (partial bold(o)_1)/(partial bold(x)_2), ..., (partial bold(o)_1)/(partial bold(x)_d);
  (partial bold(o)_2)/(partial bold(x)_1), (partial bold(o)_2)/(partial bold(x)_2), ..., (partial bold(o)_2)/(partial bold(x)_d);
  "⋮", "⋮", "⋱", "⋮";
  (partial bold(o)_d)/(partial bold(x)_1), (partial bold(o)_d)/(partial bold(x)_2), ..., (partial bold(o)_d)/(partial bold(x)_d)
) $

For softmax, the derivative has two cases:

1. when $i = j$, consider $bold(o)_i = (e^(bold(x)_i))/(sum_(j=1)^d e^(bold(x)_j))$, the derivative is:
   $ (partial bold(o)_i)/(partial bold(x)_i) = bold(o)_i (1 - bold(o)_i) $

2. similarly, when $i != j$:
  $ (partial bold(o)_i)/(partial bold(x)_j) = -bold(o)_i bold(o)_j $

Thus, $(i,j)$-th element in Jacobian matrix will be:

$ bold(J)_(i j) = bold(o)_i (delta_(i j) - bold(o)_j) $

where $bold(J)$ has shape $[d times d]$ and $delta_(i j)$ is the Kronecker delta, which is 1 if $i = j$ and 0 otherwise.

In matrix form, the Jacobian of the softmax is:

$ bold(J) = "diag"(bold(o)) - bold(o) bold(o)^T $

where:
- $bold(o)$ is the output of softmax, the shape is $[d]$.
- $"diag"(bold(o))$ is a diagonal matrix of $bold(o)$, the shape is $[d times d]$.
- $bold(o) bold(o)^T$ is the outer product of $bold(o)$ with itself, the shape is $[d times d]$.

== gradient of $(partial L)/(partial bold(x))$

Given $(partial L)/(partial bold(o))$, we can compute $(partial L)/(partial bold(x))$ using the Jacobian matrix:

$ (partial L)/(partial bold(x)) = (partial bold(o))/(partial bold(x)) dot (partial L)/(partial bold(o)) = bold(J)^T dot (partial L)/(partial bold(o)) $

where $(partial L)/(partial bold(o))$ has shape $[d]$, $bold(J)^T$ has shape $[d times d]$, and $(partial L)/(partial bold(x))$ has shape $[d]$.

== avoid explicit Jacobian
For the $i$-th element of $(partial L)/(partial bold(x))$, we can decompose the computation to:
$ (partial L)/(partial bold(x)_i) = bold(o)_(i)((partial L)/(partial bold(o)_i)-sum_(j=1)^d bold(o)_j (partial L)/(partial bold(o)_j)) $

This leads to an efficient vector form:

$ s_"grad"=( bold(o) * (partial L)/(partial bold(o)))_"sum" $

$ (partial L)/(partial bold(x))= bold(o) * ((partial L)/(partial bold(o))-s_"grad") $

= softmax - batch form

$bold(X)$: A *batch* of input vectors.

$ bold(X) in RR^(N times d) $

where:
- $N$ is batch size.
- $d$ is vector dimension.

== forward pass

$ bold(E) = e^bold(X) $
$ bold(s) = sum_(j=1)^d e^(bold(X)_(i j)) $
$ bold(O) = ( bold(E) )/( bold(s) ) $

where $bold(E) in RR^(N times d)$, $bold(s) in RR^(N times 1)$, $bold(O) in RR^(N times d)$.

== backward pass

We have gradient with respect to softmax output:
$ (partial L)/(partial bold(O)) in RR^(N times d) $

we compute the gradient:
$ bold(s)_"grad" = ( bold(O) * (partial L)/(partial bold(O)) )_"row_sum" in RR^(N times 1) $

where $bold(O)$ has size $[N times d]$, and $(partial L)/(partial bold(O))$ has size $[N times d]$.

$ (partial L)/(partial bold(X)) = bold(O) * ( (partial L)/(partial bold(O)) - bold(s)_"grad" ) $

where $(partial L)/(partial bold(X)) in RR^(N times d)$ and $bold(O) in RR^(N times d)$ and $bold(s)_"grad" in RR^(N times 1)$ will be broadcasted to $RR^(N times d)$.

= Implementation

In practice, we subtract the maximum value from each row before applying `exp()` to prevent numerical overflow:

== real forward pass

For input $bold(X) in RR^(N times d)$:
$ bold(X)_"max" = max(bold(X)) in RR^(N times 1) $
$ bold(E) = e^(bold(X) - bold(X)_"max") $
$ bold(s) = sum_(j=1)^d e^(bold(X)_(i j) - bold(X)_"max") $
$ bold(O) = ( bold(E) )/( bold(s) ) $

== real backward pass

we have $(partial L)/(partial bold(O)) in RR^(N times d)$ and cached $bold(O) in RR^(N times d)$
$ bold(s)_"grad" = ( bold(O) * (partial L)/(partial bold(O)) )_"row_sum" $
$ (partial L)/(partial bold(X)) = bold(O) * ( (partial L)/(partial bold(O)) - bold(s)_"grad" ) $

== a real example

give a real example to show how to implement softmax and its backward pass in pytorch and triton.

forwards pass is as follows:
$ X = mat(1.0, 2.0, 3.0; 1.0, 3.0, 5.0) $
$ X_"max" = mat(3.0; 5.0) $
$ X - X_"max" = mat(-2.0, -1.0, 0.0; -4.0, -2.0, 0.0) $
$ E = e^(X - X_"max") = mat(e^(-2.0), e^(-1.0), e^(0.0); e^(-4.0), e^(-2.0), e^(0.0)) $
$ E = mat(0.1353, 0.3679, 1.0000; 0.0183, 0.1353, 1.0000) $
$ S = mat(1.5032; 1.1536) $
$ O = E/S = mat(0.0900, 0.2447, 0.6652; 0.0159, 0.1173, 0.8668) $

backward pass is as follows:
$ d O = mat(0.1, 0.2, 0.7; 0.2, 0.3, 0.5) $
$ s_"grad" = mat(0.2036; 0.2597) $
$ d X = O * ( d O - s_"grad" ) $
$ d X = mat(-0.0381, -0.0792, 0.1173; -0.0043, -0.0202, 0.0245) $

== native pytorch implementation

```python
import torch
import torch.nn.functional as F

# Custom Forward Pass (Numerically Stable Softmax)
def softmax_forward(X):
    X_max = torch.max(X, dim=1, keepdim=True)[0]  # Shape: (N, 1)
    E = torch.exp(X - X_max)                     # Shape: (N, d)
    S = torch.sum(E, dim=1, keepdim=True)        # Shape: (N, 1)
    O = E / S                                    # Shape: (N, d)
    return O

# Custom Backward Pass (Gradient Calculation)
def softmax_backward(dL_dO, O):
    s_grad = torch.sum(O * dL_dO, dim=1, keepdim=True)  # Shape: (N, 1)
    dL_dX = O * (dL_dO - s_grad)                        # Shape: (N, d)
    return dL_dX

# Example Inputs
X = torch.tensor([[1.0, 2.0, 3.0], [1.0, 3.0, 5.0]], requires_grad=True)
dL_dO = torch.tensor([[0.1, 0.2, 0.7], [0.2, 0.3, 0.5]])

# Custom Implementation - Forward
O_custom = softmax_forward(X)

# PyTorch Implementation - Forward
O_pytorch = F.softmax(X, dim=1)

# Verify Forward Output
print("Custom Softmax Output:\n", O_custom)
print("PyTorch Softmax Output:\n", O_pytorch)
print("Forward Pass Match:", torch.allclose(O_custom, O_pytorch))

# Custom Implementation - Backward
dL_dX_custom = softmax_backward(dL_dO, O_custom)

# PyTorch Automatic Gradient Calculation
O_pytorch.backward(dL_dO)  # Computes gradient using PyTorch autograd
dL_dX_pytorch = X.grad

# Verify Backward Output
print("\nCustom Gradient w.r.t Input:\n", dL_dX_custom)
print("PyTorch Gradient w.r.t Input:\n", dL_dX_pytorch)
print("Backward Pass Match:", torch.allclose(dL_dX_custom, dL_dX_pytorch))
```

output:

```bash
Custom Softmax Output:
 tensor([[0.0900, 0.2447, 0.6652],
        [0.0159, 0.1173, 0.8668]], grad_fn=<DivBackward0>)
PyTorch Softmax Output:
 tensor([[0.0900, 0.2447, 0.6652],
        [0.0159, 0.1173, 0.8668]], grad_fn=<SoftmaxBackward0>)
Forward Pass Match: True

Custom Gradient w.r.t Input:
 tensor([[-0.0381, -0.0792,  0.1173],
        [-0.0043, -0.0202,  0.0245]], grad_fn=<MulBackward0>)
PyTorch Gradient w.r.t Input:
 tensor([[-0.0381, -0.0792,  0.1173],
        [-0.0043, -0.0202,  0.0245]])
Backward Pass Match: True
```

== triton implementation

```python
from typing import Optional

import torch
import triton
import triton.language as tl


@triton.jit
def softmax_fwd_kernel(
    X,
    O,
    D: tl.constexpr,
    B: tl.constexpr
):
    i_n = tl.program_id(0)
    o_d = tl.arange(0, B)
    m_d = o_d < D

    X_max = tl.max(tl.load(X + i_n * D + o_d, mask=m_d, other=-float('inf')), 0)
    E = tl.exp(tl.load(X + i_n * D + o_d, mask=m_d, other=-float('inf')) - X_max)
    S = tl.sum(E, 0)
    P = E / S

    tl.store(O + i_n * D + o_d, P.to(O.dtype.element_ty), mask=m_d)


@triton.jit
def softmax_bwd_kernel(
    O,
    dO,
    dX,
    D: tl.constexpr,
    B: tl.constexpr
):
    i_n = tl.program_id(0)
    o_d = tl.arange(0, B)
    m_d = o_d < D

    P = tl.load(O + i_n * D + o_d, mask=m_d, other=0.)
    dP = tl.load(dO + i_n * D + o_d, mask=m_d, other=0.)
    s_grad = tl.sum(P * dP, 0)
    dX_row = P * (dP - s_grad)

    tl.store(dX + i_n * D + o_d, dX_row.to(dX.dtype.element_ty), mask=m_d)


def softmax_fwd(
    X: torch.Tensor,
    dtype: Optional[torch.dtype] = torch.float
) -> torch.Tensor:
    shape = X.shape
    X = X.view(-1, X.shape[-1])

    N, D = X.shape
    B = triton.next_power_of_2(D)

    O = torch.empty_like(X, dtype=dtype)
    softmax_fwd_kernel[(N,)](
        X=X,
        O=O,
        D=D,
        B=B
    )
    return O.view(*shape)


def softmax_bwd(
    O: torch.Tensor,
    dO: torch.Tensor,
    dtype: Optional[torch.dtype] = torch.float
) -> torch.Tensor:
    shape = O.shape
    O = O.view(-1, O.shape[-1])
    dX = torch.empty_like(O, dtype=dtype)

    N, D = O.shape
    B = triton.next_power_of_2(D)
    softmax_bwd_kernel[(N,)](
        O=O,
        dO=dO,
        dX=dX,
        D=D,
        B=B
    )
    return dX.view(*shape)

# Test code to verify correctness
import torch.nn.functional as F

# Example inputs
X = torch.tensor([[1.0, 2.0, 3.0], [1.0, 3.0, 5.0]], requires_grad=True, device='cuda')
dP = torch.tensor([[0.1, 0.2, 0.7], [0.2, 0.3, 0.5]], device='cuda')

# Forward pass
P_triton = softmax_fwd(X)
P_torch = F.softmax(X, dim=1)

# Verify forward pass
print( "P_triton:\n", P_triton)
print( "P_torch:\n", P_torch)
print("Forward Pass Match:", torch.allclose(P_triton, P_torch))

# Backward pass

dX_triton = softmax_bwd(P_triton, dP)
P_torch.backward(dP)
dX_torch = X.grad

# Verify backward pass
print( "dX_triton:\n", dX_triton)
print( "dX_torch:\n", dX_torch)
print("Backward Pass Match:", torch.allclose(dX_triton, dX_torch))
```

output:

```bash
P_triton:
 tensor([[0.0900, 0.2447, 0.6652],
        [0.0159, 0.1173, 0.8668]], device='cuda:0')
P_torch:
 tensor([[0.0900, 0.2447, 0.6652],
        [0.0159, 0.1173, 0.8668]], device='cuda:0', grad_fn=<SoftmaxBackward0>)
Forward Pass Match: True
dX_triton:
 tensor([[-0.0381, -0.0792,  0.1173],
        [-0.0043, -0.0202,  0.0245]], device='cuda:0')
dX_torch:
 tensor([[-0.0381, -0.0792,  0.1173],
        [-0.0043, -0.0202,  0.0245]], device='cuda:0')
Backward Pass Match: True
```

= Results: speed comparison

The performance comparison between PyTorch and Triton implementations reveals:

#figure(
  image("/2024-12-19-softmax/fwd.png", width: 100%),
  caption: [forward pass]
)

#figure(
  image("/2024-12-19-softmax/bwd.png", width: 100%),
  caption: [backward pass]
)

Results show

- forward pass: triton implementation is stable, while the PyTorch implementation is faster for most batch sizes but shows fluctuations for a few.
- backward pass: triton implementation outperforms the pytorch implementation across most batch sizes. (the comparison may not be entirely fair, as triton caches the output $O$, whereas pytorch's handling intermediate values is unclear.)

= Notations

#table(
  columns: 3,
  [*symbol*], [*shape*], [*definition*],
  [$bold(x)$], [$d$], [Input vector],
  [$bold(o)$], [$d$], [Output vector (probability distribution)],
  [$L$], [Scalar], [Loss function],
  [$bold(J)$], [$d times d$], [Jacobian matrix],
  [$bold(X)$], [$N times d$], [Batch of input vectors (matrix)],
  [$bold(O)$], [$N times d$], [Batch output probabilities],
  [$(partial L)/(partial bold(O))$], [$N times d$], [Gradient w.r.t. output probabilities],
  [$(partial L)/(partial bold(X))$], [$N times d$], [Gradient w.r.t. input vectors],
  [$s_"grad"$], [$N times 1$], [Summation of gradients, $s_"grad" = (bold(O) * (partial L)/(partial bold(O)))_"sum"$],
)

*Note:*
- Symbols like $x$, $bold(x)$, $bold(X)$ represent scalars, vectors, or matrices, where uppercase denotes batch forms.
- $bold(X)_(:,i)$ denotes a column vector, $bold(X)_(i,:)$ denotes a row vector, $bold(X)_(i,j)$ and denote the $(i,j)$-th element
- $bold(x)_i$ denote the $i$-th element.