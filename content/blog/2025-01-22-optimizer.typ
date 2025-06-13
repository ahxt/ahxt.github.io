#import "/content/blog.typ": *
#import "/src/3rd_party/mathyml/lib.typ" as mathyml
#import mathyml.prelude:*

#show: main.with(
  title: "Optimizers: math, implementations and efficiency",
  desc: "From math to optimized code: implementing optimizers with PyTorch comparisons",
  date: "2025-01-22",
  author: "Xiaotian Han",
  tags: (
    "coding",
  ),
)

#outline(title: none, depth: 1)

= Background

Optimizers are essential for deep learning that control how model parameters are updated during training. This blog post explores common optimizers, their customized implementations and efficiency optimization.

The typical training loop of PyTorch is as follows:

```python
for inputs, labels in data_loader:
    outputs = model(inputs)
    loss = criterion(outputs, labels)
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()
```

What is the optimizer doing for `optimizer.zero_grad()` and `optimizer.step()`? It is really simple and straightforward, in this blog, we will implement the optimizers from scratch, and compare the performance with PyTorch built-in implementation.

#block(
  fill: luma(240),
  inset: 10pt,
  radius: 4pt,
  [
    *TL;DR* \
    - Dive into optimizers - from math to implementation, covering SGD to Adam
    - Customized optimizer implementations with reference code and performance comparisons
    - Efficiency optimization analysis: foreach operators, compile(), and low-level optimizations
  ]
)

= Optimization Algorithms (SGD, SGD with Momentum, Adam)

The goal of optimization is to find parameters $theta$ that minimize the loss function $J(theta)$. I will explore several commonly used optimizers:

Here I present notions used in the implementations as the following table:

== Notions

#table(
  columns: (auto, auto),
  [*Symbol*], [*Definition*],
  [$theta$], [Model parameters],
  [$eta$], [Learning rate],
  [$nabla_theta J$], [Gradient of loss w.r.t. parameters],
  [$v$], [Velocity (momentum)],
  [$m$], [First moment estimate],
  [$G$], [Second moment estimate],
  [$beta$], [Momentum decay rate],
  [$beta_1, beta_2$], [Adam hyperparameters],
  [$epsilon$], [Small constant for numerical stability],
)


= SGD (Stochastic Gradient Descent)

The simplest and most intuitive optimization algorithm that updates parameters by subtracting the gradient from the parameters with a learning rate. The basic formula is:

$ theta_(t+1) = theta_t - eta nabla_theta J(theta_t) $

where:
- $theta_t$ are the current parameters
- $eta$ is the learning rate
- $nabla_theta J(theta_t)$ is the gradient

= SGD with Momentum

SGD with Momentum adds momentum term to stabilize the training and accelerate the convergence, the idea is to update the velocity $v$ by adding the gradient and then update the parameters by subtracting the velocity. The basic formula is:

$ v_(t+1) = beta v_t + nabla_theta J(theta_t) $

$ theta_(t+1) = theta_t - eta v_(t+1) $

where:
- $v_t$ is the velocity
- $beta$ is the momentum coefficient

= Adam

== Background: RMSprop

RMSprop is a variant of SGD with Momentum, the basic idea is to update the second moment $v$ by adding the gradient and then update the parameters by subtracting the velocity. The basic formula is:

$ v_(t+1) = beta v_t + (1-beta)(nabla_theta J(theta_t))^2 $

$ theta_(t+1) = theta_t - (eta)/(sqrt(v_(t+1)) + epsilon) nabla_theta J(theta_t) $

where:
- $v_t$ is the velocity
- $beta$ is the momentum coefficient

Adam combines the ideas of momentum and RMSprop. The basic idea is to update the first moment $m$ and the second moment $v$ by incorporating the gradient, and then update the parameters using these moments. The basic formula is:

$ m_(t+1) = beta_1 m_t + (1-beta_1)nabla_theta J(theta_t) $
$ v_(t+1) = beta_2 v_t + (1-beta_2)(nabla_theta J(theta_t))^2 $
$ hat(m)_(t+1) = (m_(t+1))/(1-beta_1^t) $
$ hat(v)_(t+1) = (v_(t+1))/(1-beta_2^t) $
$ theta_(t+1) = theta_t - (eta)/(sqrt(hat(v)_(t+1)) + epsilon) hat(m)_(t+1) $

where:
- $m_t$ tracks mean of gradients
- $v_t$ tracks variance of gradients
- $beta_1, beta_2$ are decay rates
- $hat(m)_t, hat(v)_t$ are bias-corrected estimates

= Experimental results

I implemented the optimizers from scratch (mainly based on this #link("https://github.com/bentrevett/a-tour-of-pytorch-optimizers")[repo]), and compared the performance with PyTorch. The results are as follows:

== Customized SGD

Here's a minimal implementation of common optimizers in Python:

```python
class SGD:
    def __init__(self, model_params, lr=1e-3):
        self.model_params = list(model_params)
        self.lr = lr

    def zero_grad(self):
        for param in self.model_params:
            param.grad = None

    @torch.no_grad()
    def step(self):
        for param in self.model_params:
            param.sub_(self.lr * param.grad)
```

The learning curve of customized SGD and PyTorch's SGD are as follows. The learning curve of customized SGD is exactly the same as PyTorch's built-in SGD.

#figure(
    image("/2025-01-22-optimizer/sgd.png", width: 60%),
    caption: [SGD Comparison]
)

== Customized SGD with Momentum

```python
class SGDMomentum:
    def __init__(self, model_params, lr=1e-3, momentum=0.9):
        self.model_params = list(model_params)
        self.lr = lr
        self.momentum = momentum
        self.v = [torch.zeros_like(p) for p in self.model_params]

    def zero_grad(self):
        for param in self.model_params:
            param.grad = None

    @torch.no_grad()
    def step(self):
        for param, v in zip(self.model_params, self.v):
            v.mul_(self.momentum).add_(param.grad)
            param.sub_(self.lr * v)
```

The learning curve of customized SGD with Momentum and PyTorch's SGD with Momentum are as follows. The learning curve of customized SGD with Momentum matches PyTorch's SGD with Momentum.

#figure(
  image("/2025-01-22-optimizer/sgdm.png", width: 80%),
  caption: [SGD with Momentum Comparison]
)



== Customized Adam

The implementation below is the customized Adam:

```python
class Adam:
    def __init__(self, model_params, lr=1e-3, betas=(0.9, 0.999), eps=1e-8):
        self.model_params = list(model_params)
        self.lr = lr
        self.beta1, self.beta2 = betas
        self.eps = eps
        
        self.m = [torch.zeros_like(p) for p in self.model_params]  # First moment
        self.v = [torch.zeros_like(p) for p in self.model_params]  # Second moment
        self.t = 0  # Time step counter
        
    def zero_grad(self):
        for param in self.model_params:
            param.grad = None

    @torch.no_grad()
    def step(self): 
        self.t += 1
        for i, (param, m, v) in enumerate(zip(self.model_params, self.m, self.v)):
            grad = param.grad
            m.mul_(self.beta1).add_(grad, alpha=1 - self.beta1)
            v.mul_(self.beta2).addcmul_(grad, grad, value=1 - self.beta2)
            m_hat = m / (1 - self.beta1 ** self.t)
            v_hat = v / (1 - self.beta2 ** self.t)
            param.addcdiv_(m_hat, v_hat.sqrt().add_(self.eps), value=-self.lr)
```

#figure(
  image("/2025-01-22-optimizer/adam.png", width: 80%),
  caption: [Adam Comparison]
)

== All Optimizers Comparison

#figure(
  image("/2025-01-22-optimizer/optimizers.png", width: 80%),
  caption: [All Optimizers Comparison]
)

Our customized implementation produces exactly the same learning curve as PyTorch's built-in Adam optimizer. This perfect match validates that our implementation correctly reproduces the Adam, matching PyTorch's version.

= Optimizing the efficiency of optimizers

I also explore how to optimize the efficiency of optimizers. PyTorch built-in optimizers have two hyperparameters that can affect the speed:

1. `foreach` (bool): If True, use the faster foreach implementation.
2. `fused` (bool): If True, use the fused implementation if available.

In the following, I will explore how to optimize the efficiency of optimizers by using `torch.compile` (fused) and `torch._foreach_` (foreach).

== use torch.compile()

I tried to use `torch.compile`, but they didn't show significant improvements. From pytorch2.5, the `torch.compile` is introduced. It seems to be very promising and could be used to optimize the efficiency of optimizers. I compared it with the original code, and it shows significant improvements in terms of speed. 

#table(
  columns: 3,
  [*Optimizer*], [*Average Step Time (seconds)*], [*Speed Up (Times)*],
  [SGD], [0.080922], [-],
  [SGD + torch.compile], [0.060843], [1.33x],
)

The results show that `torch.compile` only is very promising and could be used to optimize the efficiency of optimizers.

== use torch._foreach_

I also tried to use `torch._foreach_` to optimize the efficiency of optimizers. Here I used a 2000 layer MLP to test the performance of the optimizers.

```python
class SGD:
    def __init__(self, model_params, lr=1e-3):
        self.model_params = list(model_params)
        self.lr = lr

    def zero_grad(self):
        for param in self.model_params:
            param.grad = None

    @torch.no_grad()
    def step(self):
        torch._foreach_sub_(self.model_params, [self.lr * p.grad for p in self.model_params])
```

After a lot of tweaks, the fastest way I can think of is the following:

```python
    @torch.no_grad()
    def step(self):
        grads = [p.grad for p in self.model_params]
        torch._foreach_mul_(grads, -self.lr)
        torch._foreach_add_(self.model_params, grads)
```

#table(
  columns: 3,
  [*Optimizer*], [*Average Step Time (seconds)*], [*Speed Up (Times)*],
  [mySGD], [0.080922], [1.00x],
  [mySGD + torch.compile], [0.060843], [1.33x],
  [mySGD + foreach], [0.053214], [1.52x],
  [mySGD + foreach + torch.compile], [0.018934], [4.27x],
  [*mySGD + (best)*], [*0.006818*], [*11.87x*],
  [torch SGD], [0.010875], [7.44x],
  [torch SGD with fused], [0.007642], [10.59x],
  [torch SGD with foreach], [0.008306], [9.74x],
)

*Run on 2000 layer MLP on T4 GPU.*

== Analysis
The results show that using `torch._foreach_` operations provides significant speedup compared to the original implementation. This is because `torch._foreach_` operations are optimized for operating on lists of tensors, reducing overhead from Python loops and enabling better parallelization.

With the `torch._foreach_mul_` and `torch._foreach_add_`, the performance of the optimizer is better than PyTorch's built-in optimizers (though more rigorous comparison is needed).

