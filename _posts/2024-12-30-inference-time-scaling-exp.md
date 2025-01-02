---
layout: post
category: blog
title: "Reproduce the inference time scaling exp [WIP]" 
snippet: dive into the minimal experiment to show the inference time scaling.
tags: [llm]
author: Xiaotian Han
layout: post
category: blog
katex: True
published: true
---

- TOC
{:toc .toc}


In this blog post, I share my reproduction of [huggingface blogpost-scaling-test-time-compute](https://huggingface.co/spaces/HuggingFaceH4/blogpost-scaling-test-time-compute). The goal is to show that with more generated tokens, the performance of a smaller model can approach that of a larger model.

The code is available at this [github repo](https://github.com/ahxt/scaling-test-time-compute-reproduce).

### Takeaways

- hardest party is extracting the answer form the raw response
- handle the `<|begin_of_text|>` token carefully
- scaling test-time computing benefits smaller models more significantly than larger ones.
- larger models still outperform smaller ones, even with test-time scaling.
- scaling the test-time computing improves the performance in terms of number of generated tokens
- [WIP] will scaling the test-time computing improve the performance in terms of flops?


### dataset and model

#### dataset

The dataset used in this experiment is [HuggingFaceH4/MATH-500](https://huggingface.co/datasets/HuggingFaceH4/MATH-500). It consists of 500 problems from the MATH benchmark, each containing:

```text
problem: Convert the point $(0,3)$ in rectangular coordinates to polar coordinates. Enter your answer in the form $(r,\theta),$ where $r > 0$ and $0 \le \theta < 2 \pi.$

solution: We have that $r = \sqrt{0^2 + 3^2} = 3.$ Also, if we draw the line connecting the origin and $(0,3),$ this line makes an angle of $\frac{\pi}{2}$ with the positive $x$-axis. [asy] unitsize(0.8 cm); draw((-0.5,0)--(3.5,0)); draw((0,-0.5)--(0,3.5)); draw(arc((0,0),3,0,90),red,Arrow(6)); dot((0,3), red); label("$(0,3)$", (0,3), W); dot((3,0), red); [/asy] Therefore, the polar coordinates are $\boxed{\left( 3, \frac{\pi}{2} \right)}.$

answer: \left( 3, \frac{\pi}{2} \right)
```

#### large language models

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


#### reward model

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


#### test-time scaling strategies

- majority voting
    - generate $$N$$ candidate solutions and pick the most frequent answer
- best of $$N$$:
    - (vanilla) generate $$N$$ candidates and pick the one with the highest score
    - (weighted) generate $$N$$ candidates and group the indentical answers, then pick the one with the highest score
- Beam search:
    - [WIP]


### reproduce results



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



