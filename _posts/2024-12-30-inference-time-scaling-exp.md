---
layout: post
category: blog
title: "Reproduce the inference time scaling exp" 
snippet: dive into the minimal experiment to show the inference time scaling.
tags: [paper]
author: Xiaotian Han
layout: post
category: blog
katex: True
published: true
---

- TOC
{:toc .toc}


In this blog post, I share my reproduction of [huggingface blogpost-scaling-test-time-compute](https://huggingface.co/spaces/HuggingFaceH4/blogpost-scaling-test-time-compute). The goal is to show that with more generated tokens, the performance of a smaller model can approach that of a larger model.



### Takeaways

> - **Answer Extraction**: Parsing the final answer out of raw LLM responses is often non-trivial, as different models or prompt formats can wrap the result in extra tokens.  
> - **Special Tokens**: Be mindful of tokens like `<|begin_of_text|>` that may appear in outputs for some models. 
> - **Smaller Models Benefit More**: When we sample multiple solutions, smaller models see a larger relative improvement in accuracy compared to bigger models.  
> - **Bigger Models Still Win**: Even after scaling smaller models heavily at inference, bigger models can still achieve higher absolute accuracy.  
> - **FLOPs Analysis**: Realistically, sampling many candidate solutions quickly becomes computationally expensive. ill scaling the test-time computing improve the performance in terms of flops?
> - The code is available at this [github repo](https://github.com/ahxt/scaling-test-time-compute-reproduce).

### Dataset and model

#### dataset

The dataset used in this experiment is [HuggingFaceH4/MATH-500](https://huggingface.co/datasets/HuggingFaceH4/MATH-500). It consists of 500 problems from the MATH benchmark, each containing:

```text
problem: Convert the point $(0,3)$ in rectangular coordinates to polar coordinates. Enter your answer in the form $(r,\theta),$ where $r > 0$ and $0 \le \theta < 2 \pi.$

solution: We have that $r = \sqrt{0^2 + 3^2} = 3.$ Also, if we draw the line connecting the origin and $(0,3),$ this line makes an angle of $\frac{\pi}{2}$ with the positive $x$-axis. [asy] unitsize(0.8 cm); draw((-0.5,0)--(3.5,0)); draw((0,-0.5)--(0,3.5)); draw(arc((0,0),3,0,90),red,Arrow(6)); dot((0,3), red); label("$(0,3)$", (0,3), W); dot((3,0), red); [/asy] Therefore, the polar coordinates are $\boxed{\left( 3, \frac{\pi}{2} \right)}.$

answer: \left( 3, \frac{\pi}{2} \right)
```

#### Large language models

I evaluate two models Llama and Qwen with different sizes:
- Llama
  - [Llama-3.2-1B-Instruct](https://huggingface.co/meta-llama/Llama-3.2-1B-Instruct)
  - [Llama-3.1-8B-Instruct](https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct)
- Qwen
  - [Qwen2.5-0.5B-Instruct](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct)
  - [Qwen2.5-1.5B-Instruct](https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct)
  - [Qwen2.5-3B-Instruct](https://huggingface.co/Qwen/Qwen2.5-3B-Instruct)
  - [Qwen2.5-7B-Instruct](https://huggingface.co/Qwen/Qwen2.5-7B-Instruct)
  - [Qwen2.5-14B-Instruct](https://huggingface.co/Qwen/Qwen2.5-14B-Instruct)


#### Reward model

[Llama3.1-8B-PRM-Deepseek-Data](https://huggingface.co/RLHFlow/Llama3.1-8B-PRM-Deepseek-Data)

The model is trained from meta-llama/Llama-3.1-8B-Instruct on RLHFlow/Deepseek-PRM-Data for 1 epochs. This model can be used for ORM and PRM. ORM evaluates the final solution, while PRM measures logical correctness at each computation step.

- ORM: extract the probability of $$+$$ from the assistant. It represents the outcome reward score for this answer.

```text
[
      {"role": "user", "content": "Convert the point $(0,3)$ in rectangular coordinates to polar coordinates. To convert from rectangular coordinates $(x, y)$ to polar coordinates $(r, \\theta)$, we can use the formulas\n\\[r = \\sqrt{x^2 + y^2}\\]\n\\[\\theta = \\arctan \\frac{y}{x}\\]\n\nIn this case, the rectangular coordinates are $(0,3)$, so $x = 0$ and $y = 3$. \n\nFirst, we calculate $r$:\n\\[r = \\sqrt{0^2 + 3^2} = \\sqrt{9} = 3\\]\n\nNext, we calculate $\\theta$:\n\\[\\theta = \\arctan \\frac{3}{0}\\]\nSince the tangent function is not defined for $x = 0$, we need to use a special case. When $x = 0$, $\\theta = \\frac{\\pi}{2}$ if $y > 0$, and $\\theta = \\frac{3\\pi}{2}$ if $y < 0$. In this case, $y = 3 > 0$, so $\\theta = \\frac{\\pi}{2}$.\n\nSo, the polar coordinates equivalent to $(0,3)$ are $\\boxed{(3,\\frac{\\pi}{2})}$."},
      {"role": "assistant", "content": "+"},
]
```

- PRM: computes step-wise reward scores by analyzing each interaction. extract the probability of $$+$$ from the assistant in each turn.

```text
[
      {"role": "user", "content": "Convert the point $(0,3)$ in rectangular coordinates to polar coordinates. To convert from rectangular coordinates $(x, y)$ to polar coordinates $(r, \\theta)$, we can use the formulas\n\\[r = \\sqrt{x^2 + y^2}\\]\n\\[\\theta = \\arctan \\frac{y}{x}\\]"},
      {"role": "assistant", "content": "+"},
      {"role": "user", "content": "In this case, the rectangular coordinates are $(0,3)$, so $x = 0$ and $y = 3$."},
      {"role": "assistant", "content": "+"},
      {"role": "user", "content": "In this case, $y = 3 > 0$, so $\\theta = \\frac{\\pi}{2}$."},
      {"role": "assistant", "content": "+"},
      {"role": "user", "content": "So, the polar coordinates equivalent to $(0,3)$ are $\\boxed{(3,\\frac{\\pi}{2})}$."},
      {"role": "assistant", "content": "+"}, 
]
```


#### Test-time scaling strategies

- majority voting
    - generate $$N$$ candidate solutions and pick the most frequent answer
- best of $$N$$:
    - (vanilla) generate $$N$$ candidates and pick the one with the highest score
    - (weighted) generate $$N$$ candidates and group the indentical answers, then pick the one with the highest score
- Beam search:
    - [WIP]


### Reproduce results



<div class="row">
    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/llama3_1b.png"
      description="llama3_1b"
      width="100%"
    %}
    </div>

    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/qwen2.5_0.5b.png"
      description="qwen2.5_0.5b"
      width="100%"
    %}
    </div>
</div>


<div class="row">
    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/qwen2.5_1.5b.png"
      description="qwen2.5_1.5b"
      width="100%"
    %}
    </div>

    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/qwen2.5_3b.png"
      description="qwen2.5_3b"
      width="100%"
    %}
    </div>
</div>

<div class="row">
    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/qwen2.5_7b.png"
      description="qwen2.5_7b"
      width="100%"
    %}
    </div>

    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/qwen2.5_14b.png"
      description="qwen2.5_14b"
      width="100%"
    %}
    </div>
</div>


<div class="row">
    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/qwen2.5_all.png"
      description="qwen2.5 all"
      width="60%"
    %}
    </div>
</div>

#### obersevations

> - for qwen, majority voting and weighted best-of-N achieve similar performance.
> - scaling test-time computing benefits smaller models more significantly than larger ones.
> - larger models still outperform smaller ones, even with test-time scaling.




### Performance improvement in terms of flops?

A natural question: Does scaling the test-time compute yield consistent improvements if we measure actual FLOPs cost rather than just the number of generated tokens?

Different model sizes have different computational demands. Additionally, for inference, the FLOPs for prefill (the forward pass over the prompt) and decoding (token-by-token generation) are quite different. For the PRM approach, there’s an extra overhead of the reward model forward pass. For different size of models, the inference flops may not be liner to the model size. thus I want to see if the performance improvement in terms of flops is consistent with the number of generated tokens.

- for majority voting, the total FLOPs is prefill FLOPs + decode FLOPs $$\times$$ N.
- for weighted best-of-N, the total FLOPs is prefill FLOPs + decode FLOPs $$\times$$ N + prm FLOPs $$\times$$ N.

where $$N$$ is the number of samples generated.


#### LLM FLOPs estimation

I estimated the FLOPs of the forward pass for prefill and decoding stages as follows. The equation and the anylysis are based on this paper [arXiv](https://arxiv.org/pdf/2404.11502).

During the following analysis, I use the following notations:

- $$b$$ is the batch size
- $$s$$ is the input sequence length
- $$h$$ is the hidden size
- $$h^\prime$$ is the FFN intermediate size
- $$n$$ is the number of heads
- $$d$$ is the size of each head ($$h = nd$$)

For prefill stage, the equations and corresponding FLOPs are:

$$
\begin{align*}
\textit{\textbf{Q, K, V}} &= \textbf{X}\mathbf{W}_{QKV} & 6bsh^2 \\
\textit{\textbf{Q, K}} &= \text{RoPE}(\textit{\textbf{Q, K}}) & 6bsh \\
\textit{\textbf{O}} &= \text{Attn}(\textit{\textbf{Q, K, V}}) & 4bs^2h + 4bs^2n \\
\textbf{X} &= \textbf{O}\mathbf{W}_O & 2bsh^2 \\
\textbf{X} &= \text{Add\&Norm}(\textbf{X}) & 5bsh \\
\textit{\textbf{G, U}} &= \textbf{X}[W_G, W_U] & 4bshh' \\
\textit{\textbf{D}} &= \text{Swish}(\textit{\textbf{G}}) \odot \textit{\textbf{U}} & 2bsh' \\
\textbf{X} &= \textbf{D}\mathbf{W}_D & 2bshh' \\
\textbf{X} &= \text{Add\&Norm}(\textbf{X}) & 5bsh
\end{align*}
$$


For decoding stage, the equations and corresponding FLOPs are:

$$
\begin{align*}
\mathit{q, k, v} &= \mathit{x}\mathbf{W}_{QKV} & & 6bh^2 \\
\mathit{q, k} &= \text{RoPE}(\mathit{q, k}) & & 6bh \\
\mathit{K, V} &= \text{Cache}(\mathit{k, v}) & & - \\
\mathit{o} &= \text{Attn}(\mathit{q, K, V}) & & 4bsh + 4bsn \\
\mathit{x} &= \mathit{o}\mathbf{W}_O & & 2bh^2 \\
\mathit{x} &= \text{Add\&Norm}(\mathit{x}) & & 5bh \\
\mathit{g, u} &= \mathit{x}[W_G, W_U] & & 4bhh' \\
\mathit{d} &= \text{Swish}(\mathit{g}) \odot \mathit{u} & & 2bh' \\
\mathit{x} &= \mathit{d}\mathbf{W}_D & & 2bhh' \\
\mathit{x} &= \text{Add\&Norm}(\mathit{x}) & & 5bh
\end{align*}
$$


For MATH-500 dataset, The FLOPs of the forward pass can be estimated as follows:

> - prefill FLOPs
>   - = $$6bsh^2 + 6bsh + (4bs^2h + 4bs^2n) + 2bsh^2 + 5bsh + 4bshh' + 2bsh' + 2bshh' + 5bsh$$
> - decoding FLOPs: 
>   - = $$6bh^2 + 6bh + 4bsh + 4bsn + 2bh^2 + 5bh + 4bhh' + 2bh' + 2bhh' + 5bh$$


I compute the FLOPs of the forward pass for batch size is $$1$$. Then

> - prefill FLOPs = $$8sh^2 + 16sh + 4s^2h + 4s^2n + 6shh' + 2sh'$$
> - decoding FLOPs = $$8h^2 + 16h + 4sh + 4sn + 6hh' + 2h'$$

Thus I use the following formula to compute the total FLOPs:

$$
\text{FLOPs}_{\text{prefill}}(s) \;=\;
8\,s\,h^2
\;+\; 16\,s\,h
\;+\; 4\,s^2\,h
\;+\; 4\,s^2\,n
\;+\; 6\,s\,h\,h'
\;+\; 2\,s\,h'
$$

$$
\text{FLOPs}_{\text{decode}}(s) \;=\;
8\,h^2
\;+\; 16\,h
\;+\; 4\,s\,h
\;+\; 4\,s\,n
\;+\; 6\,h\,h'
\;+\; 2\,h'
$$


$$
\text{FLOPs}_{\text{total}}
\;=\;
\text{FLOPs}_{\text{prefill}}(p_l)
\;+\;
\sum_{i=0}^{d_l - 1}
\text{FLOPs}_{\text{decode}}\bigl(p_l + i\bigr).
$$

where $$p_l$$ is the length of the problem prompt, and $$d_l$$ is the number of tokens we generate for the solution.


#### results

Below, we re-plot the same data—accuracy vs. total FLOPs—for Qwen2.5 of various sizes. The left endpoint of each curve (for majority voting) corresponds to the minimal compute cost of a greedy decoding ($$N=1$$). As the inference time move right, (ideally) smaller models with less flops can achieve similar performance to larger models with more flops.

The results are shown below:

<div class="row">
    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/qwen2.5_0.5b_flops.png"
      description="qwen2.5_0.5b"
      width="100%"
    %}
    </div>

    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/qwen2.5_3b_flops.png"
      description="qwen2.5_3b"
      width="100%"
    %}
    </div>

    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/qwen2.5_14b_flops.png"
      description="qwen2.5_14b"
      width="100%"
    %}
    </div>
</div>


<div class="row">
    <div class="col">
    {% include image.html url="/assets/2024-12-30-inference-time-scaling-exp/qwen2.5_flops_all.png"
      description="qwen2.5 all"
      width="60%"
    %}
    </div>
</div>



#### obersevations
<!-- > - In terms of flops, majority voting seems get better performance than weighted best-of-N. -->

> - Majority Voting seems to achieve a slightly better cost-to-performance trade-off than Weighted Best-of-N (in some cases). The overhead of scoring each candidate can become significant if  𝑁 is large.
> - Scaling for smaller models remains beneficial, but diminishing returns do appear at higher 𝑁. If you keep increasing 𝑁, you might pay a lot more FLOPs for only marginal accuracy gains.
> - Larger model vs. scaled smaller model: Even if a smaller model is heavily scaled in test-time compute, a properly sized larger model may still achieve a strictly higher accuracy while also being less or similarly expensive in total FLOPs.


### Summary

This reproduction reaffirms the main conclusion from the Hugging Face blog post: scaling test-time compute (by sampling multiple solutions and picking the best or majority) can improve accuracy, especially for smaller models. Yet, these improvements don’t entirely overcome the fundamental quality gap between smaller and larger models.

We further demonstrate how analyzing FLOPs clarifies the computational trade-offs in test-time scaling. It's not always free to sample or evaluate more solutions. Practitioners need to weigh the cost-to-benefit ratio carefully, particularly if they aim to deploy these methods at scale.