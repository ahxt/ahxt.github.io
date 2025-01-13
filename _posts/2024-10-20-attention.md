---
layout: post
category: blog
title: "Attention and its gradient"
snippet: dive into attention and its gradient.
tags: [coding]
author: Xiaotian Han
layout: post
category: blog
katex: True
---

- TOC
{:toc .toc}


### background


Untill now, the offical flashattn implementation does not support bias term.  Flexattention in `torch` is trying to support the bias term now. In this blog, I will show how to implement a minimal flashattn with trainable bias term.


<div class="tip">
TL;DR
    <ul>
    <li>Gradient-enabled bias term is required for most of protein languange model, like evoformer.</li>
    <li>Trainable bias term need to accumiluat the gradient.</li>
    </ul>
</div>



### Math

The attention with gradient-enabled bias term is defined as:

$$
\mathbf{O} = \text{softmax}\left(\frac{\mathbf{QK}^\top}{\sqrt{d}} + {\color{red}\mathbf{B}}\right)\mathbf{V}
$$

where 
- $${\color{red}\mathbf{B}}$$ is the bias term and the shape is $$(n, h, l, l)$$
- The shape of $$\mathbf{Q}, \mathbf{K}, \mathbf{V}$$ is $$(n, h, l, d)$$, 
- $$n$$ is batch size, $$h$$ is heads number, $$l$$ is sequence length, $$d$$ is hidden dimension.



 The gradient of $$\mathbf{B}$$ is accumilated during the training process. 



#### backprop derivation

Let

$$
\begin{aligned}
    \mathbf{S} &= \frac{\mathbf{QK}^\top}{\sqrt{d}} + \mathbf{B} \\
    \mathbf{A} &= \text{softmax}\left( \mathbf{S} \right) = \text{softmax}\left(\frac{\mathbf{QK}^\top}{\sqrt{d}} + \mathbf{B}\right) \\
    \mathbf{O} &= \mathbf{AV} = \text{softmax}\left( \mathbf{S} \right)\mathbf{V} = \text{softmax}\left(\frac{\mathbf{QK}^\top}{\sqrt{d}} + \mathbf{B}\right)\mathbf{V}
\end{aligned}
$$


We already have the gradient of $$\mathbf{O}$$ is $$
\frac{\partial \mathcal{L}}{\partial \mathbf{O}}
\quad ([n,\,h,\,l,\,d]).
$$

> In the following, we think of each $$(n,h)$$ slice as a separate matrix multiply.


#### gradient of $$\mathbf{V}$$ and $$\mathbf{A}$$

Since
$$
\mathbf{O} = \mathbf{AV} \quad ([n,h,l,d] = [n,h,l,l] \times [n,h,l,d])
$$, we get

$$
\frac{\partial \mathcal{L}}{\partial \mathbf{A}}=\frac{\partial \mathcal{L}}{\partial \mathbf{O}}\;\mathrm{bmm}\;(\mathbf{V}^\top), \quad ([n,h,l,l] = [n,h,l,l] \times [n,h,l,d])
$$


$$
\frac{\partial \mathcal{L}}{\partial \mathbf{V}}= \mathbf{A}^\top\;\mathrm{bmm}\;\frac{\partial \mathcal{L}}{\partial \mathbf{O}}, \quad ([n,h,l,d] = [n,h,l,l] \times [n,h,l,d])
$$



#### gradient of $$\mathbf{S}$$


It is easy to get the gradient of $$\mathbf{S}$$ based on chain rule:


<!-- $$
\frac{\partial \mathcal{L}}{\partial \mathbf{S}}  = \frac{\partial \mathbf{A}}{\partial \mathbf{S}} \cdot \frac{\partial \mathcal{L}}{\partial \mathbf{A}}  \quad ([n,h,l,l] = [n,h,l,l,l,l] \times [n,h,l,l])
$$ -->

$$
\frac{\partial \mathcal{L}}{\partial \mathbf{S}}_{ijkl} = \sum_{m,n} \frac{\partial \mathbf{A}_{ijmn}}{\partial \mathbf{S}_{ijkl}} \frac{\partial \mathcal{L}}{\partial \mathbf{A}_{ijmn}}
$$

where $$\frac{\partial \mathbf{A}}{\partial \mathbf{S}}$$ is the Jacobian of softmax function and has size $$(n,h,l,l,l,l)$$. $$ i, j, k, l $$: Indices of the target tensor $$\frac{\partial \mathcal{L}}{\partial \mathbf{S}}$$. $$ m, n $$: Summation indices, specifying contraction over these dimensions. The **$$\sum_{m, n}$$** explicitly indicates summation over the indices $$m$$ and $$n$$.
 

For efficiency, we can rewrite the above equation as:

$$
\frac{\partial \mathcal{L}}{\partial \mathbf{S}} 
=  \frac{\partial \mathcal{L}}{\partial \mathbf{A}}\odot\left(\frac{\partial \mathcal{L}}{\partial \mathbf{A}} - \left(\frac{\partial \mathcal{L}}{\partial \mathbf{A}}\cdot \mathbf{A}^\top\right)\mathbf{1}\right) \quad ([n,h,l,l] = [n,h,l,l] \odot ([n,h,l,l] \; \mathrm{bmm} \; [n,h,l,l] \cdot [n,h,l,1] ))
$$

where $$\mathbf{1} \in [n,h,l,1]$$, summation vector to normalize contributions.


#### gradient of $$\mathbf{B}$$

The gradient of $$\mathbf{B}$$ is the same as the gradient of $$\mathbf{S}$$, which is:

$$
\frac{\partial \mathcal{L}}{\partial \mathbf{B}} = \frac{\partial \mathcal{L}}{\partial \mathbf{S}}
$$

#### gradient of $$\mathbf{Q}$$, $$\mathbf{K}$$

The gradient of $$\mathbf{Q}$$ and $$\mathbf{K}$$ is:

$$
\begin{aligned}
    \frac{\partial \mathcal{L}}{\partial \mathbf{Q}} &= \frac{\partial \mathcal{L}}{\partial \mathbf{S}}\cdot \mathbf{K} \\
    \frac{\partial \mathcal{L}}{\partial \mathbf{K}} &= \frac{\partial \mathcal{L}}{\partial \mathbf{S}}\cdot \mathbf{Q}
\end{aligned}
$$


#### all gradients

$$
\begin{aligned}
    \frac{\partial \mathcal{L}}{\partial \mathbf{Q}} &= \frac{\partial \mathcal{L}}{\partial \mathbf{S}}\cdot \mathbf{K} \\
    \frac{\partial \mathcal{L}}{\partial \mathbf{K}} &= \frac{\partial \mathcal{L}}{\partial \mathbf{S}}\cdot \mathbf{Q} \\
    \frac{\partial \mathcal{L}}{\partial \mathbf{V}} &= \mathbf{A}^\top\;\mathrm{bmm}\;\frac{\partial \mathcal{L}}{\partial \mathbf{O}} \\
    \frac{\partial \mathcal{L}}{\partial \mathbf{A}} &= \frac{\partial \mathcal{L}}{\partial \mathbf{O}}\;\mathrm{bmm}\;(\mathbf{V}^\top) \\
    \frac{\partial \mathcal{L}}{\partial \mathbf{S}} &=  \frac{\partial \mathcal{L}}{\partial \mathbf{A}}\odot\left(\frac{\partial \mathcal{L}}{\partial \mathbf{A}} - \left(\frac{\partial \mathcal{L}}{\partial \mathbf{A}}\cdot \mathbf{A}^\top\right)\mathbf{1}\right) \\
    \frac{\partial \mathcal{L}}{\partial \mathbf{B}} &= \frac{\partial \mathcal{L}}{\partial \mathbf{S}}
\end{aligned}
$$





### pytorch implementation

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

output:

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