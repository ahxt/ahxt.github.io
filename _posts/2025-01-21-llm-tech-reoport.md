---
layout: post
category: blog
title: "LLM Tech Report Notes (updated on 01/22/2025)" 
snippet: reading LLM tech reports.
tags: [coding]
author: Xiaotian Han
layout: post
category: blog
katex: True
published: true
---

- TOC
{:toc .toc}





### DeepSeek-R1 (01/20/2025)

- [pdf](https://github.com/deepseek-ai/DeepSeek-R1/blob/main/DeepSeek_R1.pdf)
- [hugetingface](https://huggingface.co/collections/deepseek-ai/deepseek-r1-678e1e131c0169c0bc89728d)

> - DeepSeek-R1-Zero: use DeepSeek-V3-Base as the base model and employ GRPO as the RL framework to improve model performance in reasoning. During training.
> - DeepSeek-R1: 
    - **(DeepSeek-V3-Base)->(DeepSeek-V3-SFT1)** cold-start SFT with thousands of data from in-context long CoT prompting + DeepSeek-R1Zero readable outputs
    - **(DeepSeek-V3-SFT1)->(DeepSeek-V3-RL)** reasoning-oriented RL like DeepSeek-R1-Zero. 
    - **(DeepSeek-V3-Base)->(DeepSeek-V3-SFT2)** two epoch fine-tuning DeepSeek-V3-Base using 600k reasoning related training samples via rejection sampling on the RL checkpoint + 200k non-reasoning training samples
    - **(DeepSeek-V3-SFT2)->(DeepSeek-R1)** After fine-tuning, an additional RL process, taking into account prompts from all scenarios.
> - Do not use ORM or PRM, use rule-based reward system: Accuracy rewards, Format rewards.
> - Emphisize that neural reward model may suffer from reward hacking in the large-scale reinforcement learning process
> - Designing a straightforward template that guides the base model to adhere to specified instructions
> - **(Interesting)** DeepSeek-R1-Zero naturally acquires the ability to solve increasingly complex reasoning tasks by leveraging extended test-time computation. This improvement is not the result of external adjustments but rather an intrinsic development within the model.
> - **(Interesting)** Behaviors such as reflection are not explicitly programmed but instead emerge as a result of the model’s interaction with the reinforcement learning environment.
> - **Aha Moment of DeepSeek-R1-Zero**: DeepSeek-R1-Zero learns to allocate more thinking time to a problem by reevaluating its initial approach.
> - DeepSeek-R1-Zero struggles with challenges like poor readability, and language mixing.
> - Distillation from DeepSeek-R1 to smaller dense models works well. This demonstrates that the reasoning patterns discovered by larger base models are crucial for improving reasoning capabilities



### Kimi K1.5 (01/20/2025)
- [pdf](https://github.com/MoonshotAI/Kimi-k1.5/blob/main/Kimi_k1.5.pdf)

> - Long-CoT Supervised Fine-Tuning
    - construct a small yet high-quality long-CoT warmup dataset
> - Reinforcement Learning
    - For verifiable problems, the reward is predefined criteria or rules. For problems with free-form ground truth, us a reward model r(x, y, y∗).
    - Length Penalty to avoid overthinking phenomenon
> Several approaches for this long2short problem, including model merging, shortest rejection sampling, DPO, and long2short RL.




### MiniMax-01 (01/15/2025)

- [pdf](https://arxiv.org/abs/2501.08313)
- [huggingface minimax-01](https://huggingface.co/MiniMaxAI/MiniMax-Text-01)


> - 456 billion parameters, 45.9 billion activations, and 32 experts, 1.5T tokens for pre-training
> - good to know that the naive linear attention $$O = Norm(Q(K^{\top}V))$$ has efficiency issues due the cumulative sum operation when consider the causal mask
> - Need to learn the detail of Lightning Attention [https://sustcsonglin.github.io/assets/pdf/talk_250117.pdf](https://sustcsonglin.github.io/assets/pdf/talk_250117.pdf)
> - Transformer-style block, with each comprises a channel mixer (an attention block, lightning attention and softmax attention) and a feature mixer (an MLP block, an MoE that incorporates multiple feed-forward networks (FFNs))
> - hybrid architecture have yielded promising results, delve deeper into its potential through two variants: hybrid-cosformer2 and hybrid-[hgrn2](https://arxiv.org/pdf/2404.07904).
> - Almost perfect long-context understanding ability, with a context window of 1M tokens



### Qwen2.5-Math-PRM (01/13/2025)

- [pdf](https://arxiv.org/pdf/2501.07301)
- [huggingface](https://hf.co/Qwen/Qwen2.5-Math-PRM-7B)

> - Commonly used Monte Carlo (MC) estimation-based data synthesis for PRMs typically yields inferior performance and generalization compared to LLM-as-a-judge and human annotation methods.
> - Reveal the potential bias in using response-level BoN evaluation alone for PRMs
> - TBD



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
