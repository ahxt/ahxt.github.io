#import "/content/blog.typ": *
#import "/src/3rd_party/mathyml/lib.typ" as mathyml
#import mathyml.prelude:*

#show: main.with(
  title: "Graph Convolution ≈ Mixup",
  desc: "Revealing the connection between graph convolution and mixup",
  date: "2024-11-20",
  tags: (
    "graph-neural-networks",
    "mixup",
    "paper",
  ),
)

#outline(title: none, depth: 1)


This might be one of my most liked papers that probably reveals the essence of graph convolution. It is published on #link("https://openreview.net/forum?id=koC6zyaj73")[TMLR] and is selected as an Oral Presentation at LoG2024 TMLR Track. In this paper, we propose that graph convolution can be viewed as a specialized form of Mixup.

#link("https://arxiv.org/pdf/2310.00183")[arXiv]

=  TL;DR

This paper builds the relationship between graph convolution and Mixup techniques.

- Graph convolution aggregates features from neighboring samples for a specific node (sample).
- Mixup generates new examples by averaging features and one-hot labels from multiple samples.

The two share one commonality that information aggregation from multiple samples. We reveal that, under two mild modifications, graph convolution can be viewed as a specialized form of Mixup that is applied during both the training and testing phases if we assign the target node's label to all its neighbors.

= Graph Convolution ≈ Mixup

Graph Neural Networks have recently been recognized as the _de facto_ state-of-the-art algorithm for graph learning. The core idea behind GNNs is neighbor aggregation, which involves combining the features of a node's neighbors. Specifically, for a target node with feature $bold(x)_i$, one-hot label $bold(y)_i$, and neighbor set $cal(N)_i$, the graph convolution operation in GCN is essentially as follows:

$ (tilde(bold(x)), tilde(bold(y))) = (1/(|cal(N)_i|) sum_(k in cal(N)_i) bold(x)_k, bold(y)_i) $ <eq:graph-conv>

In parallel, Mixup is proposed to train deep neural networks effectively, which also essentially generates a new sample by averaging the features and labels of multiple samples:

$ (tilde(bold(x)), tilde(bold(y))) = (sum_(i=1)^N lambda_i bold(x)_i, sum_(i=1)^N lambda_i bold(y)_i), "s.t." sum_(i=1)^N lambda_i = 1 $ <eq:mixup>

where $bold(x)_i$/$bold(y)_i$ are the feature/label of sample $i$. Mixup typically takes two data samples ($N=2$).

The above two equations highlight a remarkable similarity between graph convolution and Mixup, i.e., _the manipulation of data samples through averaging the features_. This similarity prompts us to investigate the relationship between these two techniques as follows:

#align(center)[
  #block(
    fill: rgb("f0f0f0"),
    inset: 8pt,
    radius: 4pt,
    [*Is there a connection between graph convolution and Mixup?*]
  )
]

In this paper, we answer this question by establishing the connection between graph convolutions and Mixup, and further understanding the graph neural networks through the lens of Mixup. We show that graph convolutions are intrinsically equivalent to Mixup by rewriting as follows:

$ (tilde(bold(x)), tilde(bold(y))) &= (1/(|cal(N)_i|) sum_(k in cal(N)_i) bold(x)_k, bold(y)_i) \
&= (sum_(k in cal(N)_i) 1/(|cal(N)_i|) bold(x)_k, sum_(k in cal(N)_i) 1/(|cal(N)_i|) bold(y)_i) \
&= (sum_(k in cal(N)_i) lambda_i bold(x)_k, sum_(k in cal(N)_i) lambda_i bold(y)_i) $

where $lambda_i = 1/(|cal(N)_i|)$, and $bold(x)_i$ and $bold(y)_i$ are the feature and label of the target node $n_i$.

This above equation states that graph convolution is equivalent to Mixup if we assign the $bold(y)_i$ to all the neighbors of node $n_i$ in set $cal(N)_i$.

#figure(
  image("/2024-11-20-graph-convolution-mixup/intro.png", width: 60%),
  caption: [Graph convolution ≈ Mixup]
)


= Experiments

The experiments with the public split on Cora, CiteSeer, and Pubmed datasets and the results are shown in the following table. The results show that MLP with mixup can achieve comparable performance to the original GCN.

#figure(
  image("/2024-11-20-graph-convolution-mixup/table.png", width: 50%),
  caption: [Performance comparison results]
)

We experimented with different data splits of train/validation/test (the training data ratio span from $10%-90%$).

#figure(
  image("/2024-11-20-graph-convolution-mixup/relabel.png", width: 100%),
  caption: [Results with different data splits]
)

With the test-time mixup (details in the paper), the MLPs with mixup can achieve comparable performance to the original GCN.

#figure(
  image("/2024-11-20-graph-convolution-mixup/testtime.png", width: 100%),
  caption: [Test-time mixup results]
)

