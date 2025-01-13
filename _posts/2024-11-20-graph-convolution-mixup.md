---
layout: post
category: blog
title: "Graph Convolution ≈ Mixup"
snippet: one of my most liked papers.
tags: [paper]
author: Xiaotian Han
layout: post
category: blog
katex: True
---

- TOC
{:toc .toc}


This might be one of my most liked papers that probably reveals the essence of graph convolution. It is published on [TMLR](https://openreview.net/forum?id=koC6zyaj73) and is selected as an Oral Presentation at LoG2024 TMLR Track. In this paper, we propose that graph convolution can be viewed as a specialized form of Mixup.

[arXiv](https://arxiv.org/pdf/2310.00183)

### TD;LR

This paper build the relationship between graph convolution and Mixup techniques. 

- Graph convolution aggregates features from neighboring samples for a specific node (sample). 
- Mixup generates new examples by averaging features and one-hot labels from multiple samples. 

The two share one commonality that information aggregation from multiple samples. We reveals that, under two mild modifications, graph convolution can be viewed as a specialized form of Mixup that is applied during both the training and testing phases if we assign the target node's label to all its neighbors




### graph convolution≈mixup

Graph Neural Networks have recently been recognized as the *de facto* state-of-the-art algorithm for graph learning. The core idea behind GNNs is neighbor aggregation, which involves combining the features of a node's neighbors. Specifically, for a target node with feature $$\mathbf{x}_i$$, one-hot label $$\mathbf{y}_i$$, and neighbor set $$\mathcal{N}_i$$, the graph convolution operation in GCN is essentially as follows:

$$
\begin{equation}
    (\tilde{\mathbf{x}}, \tilde{\mathbf{y}}) = \left(\frac{1}{|\mathcal{N}_i|} \sum_{k \in \mathcal{N}_i} \mathbf{x}_k,~~\mathbf{y}_i\right),
\end{equation} 
$$

In parallel, Mixup is proposed to train deep neural networks effectively, which also essentially generates a new sample by averaging the features and labels of multiple samples:

$$
\begin{equation}
(\tilde{\mathbf{x}}, \tilde{\mathbf{y}}) = \left(\sum_{i=1}^{N} \lambda_i\mathbf{x}_i,~~
\sum_{i=1}^{N} \lambda_i\mathbf{y}_i\right), \quad\text{s.t.}\quad \sum^{N}_{i=1} \lambda_i= 1,
\end{equation}
$$

where $$\mathbf{x}_i$$/$$\mathbf{y}_i$$ are the feature/label of sample $$i$$. Mixup typically takes two data samples ($$N=2$$).


$$(1)$$ and $$(2)$$ highlight a remarkable similarity between graph convolution and Mixup, i.e., \textit{the manipulation of data samples through averaging the features}. This similarity prompts us to investigate the relationship between these two techniques as follows:


> **Is there a connection between graph convolution and Mixup?**


In this paper, we answer this question by establishing the connection between graph convolutions and Mixup, and further understanding the graph neural networks through the lens of Mixup. We show that graph convolutions are intrinsically equivalent to Mixup by rewriting (1) as follows:

$$
\begin{equation}
\begin{split}
    (\tilde{\mathbf{x}}, \tilde{\mathbf{y}}) = \left(\frac{1}{|\mathcal{N}_i|} \sum_{k \in \mathcal{N}_i} \mathbf{x}_k, {\color{red}\mathbf{y}_i}\right) = \left( \sum_{k \in \mathcal{N}_i} \frac{1}{|\mathcal{N}_i|} \mathbf{x}_k, \sum_{k \in \mathcal{N}_i} \frac{1}{|\mathcal{N}_i|} {\color{red} \mathbf{y}_i}\right) \overset{\lambda_i=\frac{1}{|\mathcal{N}_i|}}{=} \left( \sum_{k \in \mathcal{N}_i} \lambda_i \mathbf{x}_k, \sum_{k \in \mathcal{N}_i} \lambda_i {\color{red} \mathbf{y}_i}\right),\nonumber
\end{split}
\end{equation}
$$


where $$\mathbf{x}_i$$ and $${\color{red} \mathbf{y}_i}$$ are the feature and label of the target node $$n_i$$. 

This above equation states that graph convolution is equivalent to Mixup if we assign the $${\color{red} \mathbf{y}_i}$$ to all the neighbors of node $$n_i$$ in set $$\mathcal{N}_i$$.

<div class="row">
    <div class="col">
    {% include image.html url="/assets/2024-11-20-graph-convolution-mixup/intro.png"
      description="graph convolution≈mixup"
      width="80%"
    %}
    </div>
</div>



### experiments

The experiments with the public split on Cora, CiteSeer, and Pubmed datasets and the results are shown in the following table. The results show that mlp with mixup can achieve comparable performance to the original GCN.

<div class="row">
    <div class="col">
    {% include image.html url="/assets/2024-11-20-graph-convolution-mixup/table.png"
      width="80%"
    %}
    </div>
</div>


We experimented with different data splits of train/validation/test (the training data ratio span from $$10\%-90\%$$). 

<div class="row">
    <div class="col">
    {% include image.html url="/assets/2024-11-20-graph-convolution-mixup/relabel.png"
      width="100%"
    %}
    </div>
</div>



With the test-time mixup (details in the paper), the mlps with mixup can achieve comparable performance to the original GCN.

<div class="row">
    <div class="col">
    {% include image.html url="/assets/2024-11-20-graph-convolution-mixup/testtime.png"
      width="100%"
    %}
    </div>
</div>
