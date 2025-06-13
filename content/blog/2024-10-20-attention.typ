#import "/content/blog.typ": *
#import "/src/3rd_party/mathyml/lib.typ" as mathyml
#import mathyml.prelude:*

#show: main.with(
  title: "Attention and its gradient",
  desc: "dive into attention and its gradient",
  date: "2024-10-20",
  tags: (
    "attention",
    "llms",
  ),
)

#outline(title: none, depth: 1)

= Background

Until now, the official flashattn implementation does not support bias term. Flexattention in `torch` is trying to support the bias term now. In this blog, I will show how to implement a minimal flashattn with trainable bias term.

#rect(
  fill: luma(240),
  stroke: 1pt,
  radius: 5pt,
  inset: 10pt,
  width: 100%,
)[
  *TL;DR*
  
  - Gradient-enabled bias term is required for most of protein language model, like evoformer.
  - Trainable bias term need to accumulate the gradient.
]

= Attention

The attention with gradient-enabled bias term is defined as:

$ bold(O) = "softmax"((bold(Q K)^T)/sqrt(d) + bold(B))bold(V) $

where 
- $bold(B)$ is the bias term and the shape is $(n, h, l, l)$
- The shape of $bold(Q), bold(K), bold(V)$ is $(n, h, l, d)$
- $n$ is batch size, $h$ is heads number, $l$ is sequence length, $d$ is hidden dimension.

The gradient of $bold(B)$ is accumulated during the training process.

= Backprop Derivation

Let

$ bold(S) &= (bold(Q K)^T)/sqrt(d) + bold(B) \
bold(A) &= "softmax"(bold(S)) = "softmax"((bold(Q K)^T)/sqrt(d) + bold(B)) \
bold(O) &= bold(A V) = "softmax"(bold(S))bold(V) = "softmax"((bold(Q K)^T)/sqrt(d) + bold(B))bold(V) $

We already have the gradient of $bold(O)$ is $
(partial cal(L))/(partial bold(O))
quad ([n, h, l, d]).
$

#block(
  fill: luma(250),
  stroke: (left: 4pt + blue),
  inset: 10pt,
  radius: 3pt,
)[
  In the following, we think of each $(n,h)$ slice as a separate matrix multiply.
]

== Gradient of $bold(V)$ and $bold(A)$

Since
$
bold(O) = bold(A V) quad ([n,h,l,d] = [n,h,l,l] times [n,h,l,d])
$, we get

$ (partial cal(L))/(partial bold(A)) = (partial cal(L))/(partial bold(O)) "bmm" (bold(V)^T), quad ([n,h,l,l] = [n,h,l,l] times [n,h,l,d]) $

$ (partial cal(L))/(partial bold(V)) = bold(A)^T "bmm" (partial cal(L))/(partial bold(O)), quad ([n,h,l,d] = [n,h,l,l] times [n,h,l,d]) $

== Gradient of $bold(S)$

It is easy to get the gradient of $bold(S)$ based on chain rule:

$ (partial cal(L))/(partial bold(S))_(i j k l) = sum_(m,n) (partial bold(A)_(i j m n))/(partial bold(S)_(i j k l)) (partial cal(L))/(partial bold(A)_(i j m n)) $

where $(partial bold(A))/(partial bold(S))$ is the Jacobian of softmax function and has size $(n,h,l,l,l,l)$. $i, j, k, l$: Indices of the target tensor $(partial cal(L))/(partial bold(S))$. $m, n$: Summation indices, specifying contraction over these dimensions. The $sum_(m, n)$ explicitly indicates summation over the indices $m$ and $n$.

For efficiency, we can rewrite the above equation as:

$ (partial cal(L))/(partial bold(S)) = (partial cal(L))/(partial bold(A)) * ((partial cal(L))/(partial bold(A)) - ((partial cal(L))/(partial bold(A)) dot bold(A)^T)bold(1)) quad ([n,h,l,l] = [n,h,l,l] * ([n,h,l,l] "bmm" [n,h,l,l] dot [n,h,l,1])) $

where $bold(1) in [n,h,l,1]$, summation vector to normalize contributions.

== Gradient of $bold(B)$

The gradient of $bold(B)$ is the same as the gradient of $bold(S)$, which is:

$ (partial cal(L))/(partial bold(B)) = (partial cal(L))/(partial bold(S)) $

== Gradient of $bold(Q)$, $bold(K)$

The gradient of $bold(Q)$ and $bold(K)$ is:

$ (partial cal(L))/(partial bold(Q)) &= (partial cal(L))/(partial bold(S)) dot bold(K) \
(partial cal(L))/(partial bold(K)) &= (partial cal(L))/(partial bold(S)) dot bold(Q) $

== All gradients

$ (partial cal(L))/(partial bold(Q)) &= (partial cal(L))/(partial bold(S)) dot bold(K) \
(partial cal(L))/(partial bold(K)) &= (partial cal(L))/(partial bold(S)) dot bold(Q) \
(partial cal(L))/(partial bold(V)) &= bold(A)^T "bmm" (partial cal(L))/(partial bold(O)) \
(partial cal(L))/(partial bold(A)) &= (partial cal(L))/(partial bold(O)) "bmm" (bold(V)^T) \
(partial cal(L))/(partial bold(S)) &= (partial cal(L))/(partial bold(A)) * ((partial cal(L))/(partial bold(A)) - ((partial cal(L))/(partial bold(A)) dot bold(A)^T)bold(1)) \
(partial cal(L))/(partial bold(B)) &= (partial cal(L))/(partial bold(S)) $

= PyTorch implementation

```python
import torch

def forward(Q, K, V, B, d):
    S = torch.matmul(Q, K.transpose(-2, -1)) / torch.sqrt(torch.tensor(d, dtype=torch.float32)) + B
    A = torch.softmax(S, dim=-1)
    O = torch.matmul(A, V)
    return O, A, S

@torch.no_grad
def compute_gradients(Q, K, V, B, d, dO):
    # Compute forward pass
    S = torch.matmul(Q, K.transpose(-2, -1)) / torch.sqrt(torch.tensor(d, dtype=torch.float32)) + B
    A = torch.softmax(S, dim=-1)
    O = torch.matmul(A, V)

    # Gradient of V and A
    dA = torch.matmul(dO, V.transpose(-2, -1))
    dV = torch.matmul(A.transpose(-2, -1), dO)

    # Gradient of S using Jacobian-vector product (JVP)
    dS = dA * A - (A * dA).sum(dim=-1, keepdim=True) * A
    # dS = dA * A - torch.matmul(dA * A, A.transpose(-2, -1))

    # Gradient of B (same as dS)
    dB = dS.clone()

    # Gradient of Q and K
    dQ = torch.matmul(dS, K) / torch.sqrt(torch.tensor(d, dtype=torch.float32))
    dK = torch.matmul(dS.transpose(-2, -1), Q) / torch.sqrt(torch.tensor(d, dtype=torch.float32))

    return dQ, dK, dV, dB


# Example usage
n, h, l, d = 2, 4, 8, 16
torch.manual_seed(0)
Q = torch.randn(n, h, l, d, requires_grad=True)
K = torch.randn(n, h, l, d, requires_grad=True)
V = torch.randn(n, h, l, d, requires_grad=True)
B = torch.randn(n, h, l, l, requires_grad=True)
dO = torch.randn(n, h, l, d)

O, A, S = forward(Q, K, V, B, d)
dQ, dK, dV, dB = compute_gradients(Q, K, V, B, d, dO)

# Verify correctness with autograd
O.backward(dO, retain_graph=True)




print( V.grad[0][0][0])
print( dV[0][0][0]  )

print( B.grad[0][0][0])
print( dB[0][0][0]  )

print( Q.grad[0][0][0])
print( dQ[0][0][0]  )



assert torch.allclose(V.grad, dV, atol=1e-5), "dV mismatch"
assert torch.allclose(B.grad, dB, atol=1e-5), "dB mismatch"
assert torch.allclose(Q.grad, dQ, atol=1e-5), "dQ mismatch"
assert torch.allclose(K.grad, dK, atol=1e-5), "dK mismatch"


print("Autograd verification passed.")

print("O:", O.shape)
print("dQ:", dQ.shape)
print("dK:", dK.shape)
print("dV:", dV.shape)
print("dB:", dB.shape)
```

Output:

```bash
tensor([-0.9583, -0.7990, -0.7401,  0.4045, -1.1326, -0.8535,  0.9846,  0.8070,
        -0.6478, -0.0538,  0.6266,  1.0380, -0.9200,  0.5653,  0.9200, -0.0638])
tensor([-0.9583, -0.7990, -0.7401,  0.4045, -1.1326, -0.8535,  0.9846,  0.8070,
        -0.6478, -0.0538,  0.6266,  1.0380, -0.9200,  0.5653,  0.9200, -0.0638])
tensor([-8.4880e-02, -6.7330e-01, -5.2291e-04,  3.3246e-02, -2.7012e-02,
         5.0888e-01,  2.4558e-01, -1.9837e-03])
tensor([-8.4880e-02, -6.7330e-01, -5.2293e-04,  3.3246e-02, -2.7012e-02,
         5.0888e-01,  2.4558e-01, -1.9838e-03])
tensor([-0.1274, -0.2580,  0.2316,  0.1266, -0.3056,  0.0579, -0.2824,  0.2191,
        -0.0199,  0.2176, -0.0755, -0.1700,  0.1564,  0.2221, -0.0909,  0.0172])
tensor([-0.1274, -0.2580,  0.2316,  0.1266, -0.3056,  0.0579, -0.2824,  0.2191,
        -0.0199,  0.2176, -0.0755, -0.1700,  0.1564,  0.2221, -0.0909,  0.0172])
Autograd verification passed.
O: torch.Size([2, 4, 8, 16])
dQ: torch.Size([2, 4, 8, 16])
dK: torch.Size([2, 4, 8, 16])
dV: torch.Size([2, 4, 8, 16])
dB: torch.Size([2, 4, 8, 8])
```
