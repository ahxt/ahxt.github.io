---
layout: post
category: blog
title: "LLM Tech Report Notes (updated on 01/04/2025)" 
snippet: hightlight of the tech report of Deepseek-V3.
tags: [coding]
author: Xiaotian Han
layout: post
category: blog
katex: True
published: true
---

- TOC
{:toc .toc}


### OLMo 2 (12/31/2024)

- [pdf](https://arxiv.org/pdf/2501.00656)
- [huggingface olmo-2](https://huggingface.co/collections/allenai/olmo-2-674117b93ab84e98afc72edc)


> - up to 5T tokens, 95% derived from web data; 7B 13B parameters
> - Reordered norm and QK-norm. $$h ∶= x + \text{RMSNorm}(\text{Attention}(x)); h_{out} ∶= h + \text{RMSNorm}(\text{MLP}(x))$$
> - Data can be a cause of both gradient norm and loss spikes. When investigating training batches at which
spikes occurred, we found a high prevalence of instances containing long, repeated n-gram sequences
> - improving training stability from OLMo 2’s initialization, initialize every parameter from a normal distribution with a mean of $$0$$ and a standard deviation of $$0.02$$
> - decreasing the AdamW $$\epsilon$$ from $$10^{−5}$$ to $$10^{−8}$$
> - confirm the effectiveness of this approach, also known as model souping, on six different mid-training mixes
> - three phases of training: SFT, preference tuning with DPO, and RLVR
> - turn off weight decay for embeddings and observe that embedding norms settle in a healthy region.


### Deepseek-V3 (12/16/2024)

- [pdf](https://github.com/deepseek-ai/DeepSeek-V3/blob/main/DeepSeek_V3.pdf)
- [huggingface](https://huggingface.co/collections/deepseek-ai/deepseek-v3-676bc4546fb4876383c4208b)


> - **multi-token prediction objective**, the acceptance rate of 2nd token prediction is 85% ~ 90%
> - **knowledge distillation from DeepSeek-R1**, notably improves its reasoning performance
> - **balanced expert loading** introduce a bias term for each expert to help determine the top-K routing
> - **DualPipe**: overlap the computation and communication within forward and backward chunks.
> - **fp8 quantization during training**: introduce a fine-grained quantization strategy for fp8
> - **an efficient and lightweight training framework**, HAI-LLM. (might be the impressive engeering basis)
> - numbers: 14.8T tokens for pre-training
> - RMSNorm recomputation during back-propagation
> - adopt the BF16 for first and second moments in the AdamW
> - do not incorporate cross-sample attention masking during training
> - use document packing method for data integrity
> - incorporate the FIM strategy in the pre-training
> - shared embedding and output head for multi-token prediction (due the DualPipe implementation)
> - not use costly tensor parallelism
> - suggestions on hardware design
>     - higher FP8 GEMM accumulation precision
>     - tile- and block-wise quantization
>     - online quantization
>     - transposed GEMM operations

---

### Qwen2.5 (12/19/2024)

- [pdf](https://arxiv.org/pdf/2412.15115)
- [huggingface](https://huggingface.co/collections/Qwen/qwen25-66e81a666513e518adb90d9e)


> - 0.5B, 1.5B, 3B, 7B, 14B, 72B; 18T token for pre-training
> - Qwen2-72B-Instruct and Qwen2-Math-72B-Instruct generate synthetic data in mathematics, code, and knowledge domains
> - increase RoPE base from 10,000 to 1,000,000 using the ABF technique
> - develop long-response datasets, capable of generating high-quality 8,192 tokens

---

### Phi-4 (12/12/2024)

- [pdf](https://arxiv.org/pdf/2412.08905)


> - numbers: 14B, 10T tokens
> - 50 broad types, 400B-token synthetic datasets, spanning an array of topics, skills, and natures of interaction
> - question-answer data contributed significantly to various capabilities, such as mathematical reasoning and academic performance
> - one round of SFT, one round of DPO on data from our pivotal token search method, and one round of DPO on full length preference pairs
> - 8B tokens of data for SFT, all formatted in the chatml format

---

### TÜLU 3 (12/06/2024)
- [pdf](https://arxiv.org/pdf/2411.15124)
- [huggingface](https://huggingface.co/collections/allenai/tulu-3-models-673b8e0dc3512e30e7dc54f5)


> - synthetic data generation for target skills such as precise instruction following, math and coding
> - safety SFT data was generally orthogonal to our other datasets
> - changing the chat template, replacing the newlines at the end of assistant messages with an eos
> - SFT performance noticeably varies based on the seed
> - model soup does not always outperform the best single run
> - use length-normalized DPO for tuning our preference data mixtures and generation methods
> - scaling the number of unique prompts improve downstream DPO performance
> - for our final DPO models we decided on using a learning rate of $$2.0 × 10^{-7}$$
> - introduce (RLVR), a novel method for training llm on tasks with verifiable outcomes
> - RLVR focus on two domains (mathematics, exact instruction following) and three evaluations (GSM8K, MATH, IFEval)


### Llama 3 (08/15/2024)

- [pdf](https://arxiv.org/pdf/2407.21783)
- [huggingface](https://huggingface.co/collections/meta-llama/llama-32-66f448ffc8c32f949b04c8cf)

> - 405B parameters on 15.6T tokens using a context window of 8K tokens.
> - supported context window to 128K tokens
> - supervised finetuning on instruction tuning data and Direct Preference Optimization
> - annealing on small amounts of high-quality code and mathematical data can boost the performance of pre-trained models on key benchmarks
> - Llama 3 405B is trained on up to 16K H100 GPUs
> - use fully sharded data parallelism (FSDP) for training
> - design a new multi-message chat protocol which uses various special header and termination tokens.
> - average models obtained from experiments using various versions of data or hyperparameters at each RM, SFT, or DPO stage


### OLMo (07/07/2024)

- [pdf](https://arxiv.org/pdf/2402.00838)
- [huggingface olmo](https://huggingface.co/collections/allenai/olmo-suite-65aeaae8fe5b6b2122b46778)
- [huggingface olmo-2](https://huggingface.co/collections/allenai/olmo-2-674117b93ab84e98afc72edc)


> - 1B and 7B models, 2T tokens Dolma dataset
> - use up to 256 nodes on this cluster, where each node consists of 4x AMD MI250X GPUs with 128GB of memory5 and 800Gbps of interconnect
> - release model weights, training data and training and evaluation code.
