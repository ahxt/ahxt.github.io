---
permalink: /2024fall_csds600.html
title: "2024fall_csds600"
excerpt: ""
author_profile: true
layout: default
---



# **CSDS600: Large Language Models**

Xiaotian (Max) Han

Fall 2024, M/W 3:20–4:35 PM


## **Course Description**

This course offers an in-depth exploration of large language models (LLMs). LLM has revolutionized natural language processing and even the field of artificial intelligence. This course will introduce LLMs from their foundations to practical applications, covering topics such as model architecture, system design, and various training methodologies including pre-training, fine-tuning, and instruction tuning. *This course is highly research-oriented and designed for advanced undergraduate and graduate students in computer science for research purposes*.


## **Required and Recommended Materials**

* No textbooks are required. 
* Research papers will be provided.
* Dive into Deep Learning, [https://d2l.ai/d2l-en.pdf](https://d2l.ai/d2l-en.pdf)  


## **Course Components & Grading Policy** 
*The grading policy is subject to minor change.*

Student's grades will be calculated according to the following components: 

* Paper Presentation (30%):
  * 20-min presentation on a research paper (30%)
* Class participation (10%)
  * Forms for the presentation (1% each, 10 in total)
* Final Project (60%):
  * A 2-page proposal (10%)
  * A 6-page final report (40%)
  * Project presentation (10%). 


Paper Presentation Format:
- Select a paper from the provided list
- 20-minute presentation on the selected paper
- 10-minute Q&A session
- Each student must present at least once
- Audience members will submit questions and rate the presenter using a provided form.


Final Project Format:
- 3 students in each group
- Select a topic related to LLMs
- Use ICLR2024 latex format for proposal and final report
- In-class presentation on the final project


Grading Criteria:
- Paper Presentation (30%):
   - Completeness and quality of the presentation (15%)
   - Average peer rating (15%)
- Class Participation (10%):
   - Forms submitted for each paper presentation (1% each, we will have over 10 presentations, you need to submit at least 10 forms)
- Final Project (60%):
   - Assessed the quality of the proposal, final report, and presentation.



## **Course Schedule** 

*The course schedule is subject to minor change.*

| Date        | Topic  | Papers |
| :---------- | :-------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 08/26       | Course overview, Introduction to LLMs         | -                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 08/28       | Basic deep learning, mlp, word2vec, layernorm | -                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 09/02       | (Labor Day Holiday)                           | -                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 09/04       | Langual modeling & transformers               | -                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 09/09       | LLM architecture & training                   | -                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 09/11       | Training Data                                 | [The RefinedWeb Dataset for Falcon LLM: Outperforming Curated Corpora with Web Data, and Web Data Only](https://arxiv.org/pdf/2306.01116) <br> [Dolma: an Open Corpus of Three Trillion Tokens for Language Model Pretraining Research](https://arxiv.org/pdf/2402.00159) <br> [Finetuned Language Models Are Zero-Shot Learners](https://arxiv.org/pdf/2109.01652) <br> [RedPajama-Data-v2: An open dataset with 30 trillion tokens for training large language models](https://www.together.ai/blog/redpajama-data-v2)                                                            |
| 09/16       | Evalutaion                                    | [Measuring Massive Multitask Language Understanding](https://arxiv.org/pdf/2009.03300) <br> [MMLU-Pro: A More Robust and Challenging Multi-Task Language Understanding Benchmark](https://arxiv.org/pdf/2406.01574)                                                                                                                                                                                                                                                                                                                                                                 |
| 09/18       | In-Context learnings                          | [Language Models are Few-Shot Learners](https://arxiv.org/pdf/2005.14165) <br> [In-context Learning and Induction Heads](https://arxiv.org/pdf/2209.11895) <br> [Rethinking the Role of Demonstrations: What Makes In-Context Learning Work?](https://arxiv.org/pdf/2202.12837) <br> [Transformers Learn In-Context by Gradient Descent](https://arxiv.org/pdf/2212.07677) <br> [Few-Shot Parameter-Efficient Fine-Tuning is Better and Cheaper than In-Context Learning](https://arxiv.org/pdf/2205.05638) <br> [Many-Shot In-Context Learning](https://arxiv.org/pdf/2404.11018)  |
| 09/23       | CoT & Reasoning                               | [Chain-of-thought prompting elicits reasoning in large language models](https://arxiv.org/pdf/2201.11903) <br> [Self-Consistency Improves Chain of Thought Reasoning in Language Models](https://arxiv.org/pdf/2203.11171) <br> [Towards Revealing the Mystery behind Chain of Thought: A Theoretical Perspective](https://arxiv.org/pdf/2305.15408)                                                                                                                                                                                                                                |
| 09/25       | Scaling law                                   | [Scaling Laws for Neural Language Models](https://arxiv.org/pdf/2001.08361) <br> [Data Mixing Laws: Optimizing Data Mixtures by Predicting Language Modeling Performance](https://arxiv.org/pdf/2403.16952) <br> [Training Compute-Optimal Large Language Models](https://arxiv.org/pdf/2203.15556) <br> []()                                                                                                                                                                                                                                                                       |
| 09/30       | Emergent ability                              | [Emergent Abilities of Large Language Models](https://arxiv.org/abs/2206.07682) <br> [Are Emergent Abilities of Large Language Models a Mirage?](https://arxiv.org/pdf/2304.15004)                                                                                                                                                                                                                                                                                                                                                                                                  |
| 10/02       | Positional enbedding                           | [Train Short, Test Long: Attention with Linear Biases Enables Input Length Extrapolation](https://arxiv.org/pdf/2108.12409) <br> [RoFormer: Enhanced Transformer with Rotary Position Embedding](https://arxiv.org/pdf/2104.09864) <br> [The Impact of Positional Encoding on Length Generalization in Transformers](https://arxiv.org/pdf/2305.19466) <br> [Exploring the Limits of Transfer Learning with a Unified Text-to-Text Transformer](https://arxiv.org/pdf/1910.10683)                                                                                                   |
| 10/07       | Long context ability                          | [YaRN: Efficient Context Window Extension of Large Language Models](https://arxiv.org/pdf/2309.00071) <br> [Efficient Streaming Language Models with Attention Sinks](https://arxiv.org/pdf/2309.17453) <br> [LLM Maybe LongLM: Self-Extend LLM Context Window Without Tuning](https://arxiv.org/pdf/2401.01325) <br> [LM-Infinite: Zero-Shot Extreme Length Generalization for Large Language Models](https://arxiv.org/pdf/2308.16137)                                                                                                                                            |
| 10/09       | KV cache                                      | [Efficient Memory Management for Large Language Model Serving with PagedAttention](https://arxiv.org/pdf/2309.06180) <br> [Llama 2: Open Foundation and Fine-Tuned Chat Models (Grouped-query Attention) ](https://arxiv.org/pdf/2307.09288) <br> [DeepSeek-V2: A Strong, Economical, and Efficient Mixture-of-Experts Language Model (Multi-head Latent Attention)](https://arxiv.org/pdf/2405.04434) <br> []()                                                                                                                                                                    |
| 10/14       | Efficient attention                           | [Flashattention: Fast and memory-efficient exact attention with io-awareness](https://arxiv.org/pdf/2205.14135) <br> [Flashattention-2: Faster attention with better parallelism and work partitioning](https://arxiv.org/pdf/2307.08691) <br> [Flashattention-3: Fast and accurate attention with asynchrony and low-precision](https://arxiv.org/pdf/2407.08608)          |
| 10/16       | (Fall Break)      |     |
| 10/23       | Guest Lecture     | Liger Kernel - Efficient Triton Kernels for LLM Training by Byron (Pin-Lun)Hsu |                                                                                   
| 10/21       | Efficient architecture                        | [Jamba-1.5: Hybrid Transformer-Mamba Models at Scale](https://arxiv.org/pdf/2408.12570) <br> [Transformers are SSMs: Generalized Models and Efficient Algorithms Through Structured State Space Duality](https://arxiv.org/pdf/2405.21060) <br> [RWKV: Reinventing RNNs for the Transformer Era](https://arxiv.org/pdf/2305.13048) <br> [Griffin: Mixing Gated Linear Recurrences with Local Attention for Efficient Language Models](https://arxiv.org/pdf/2402.19427)                                                                                                             |
| 10/28       | RAG                                           | [Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks](https://arxiv.org/pdf/2005.11401) <br> [Retrieval meets Long Context Large Language Models](https://arxiv.org/abs/2310.03025) <br> [From Local to Global: A Graph RAG Approach to Query-Focused Summarization](https://arxiv.org/pdf/2404.16130)  |
| 10/30       | Guest Lecture                                 | Towards A Physiology of Language Model Representations by Chi Han  |
| 11/04       | Guest Lecture                                 | LLM-Driven Autonomous Agent  by Jingfeng Yang   | |
| 10/28       | Specilized LLM                                | [Code Llama: Open Foundation Models for Code](https://arxiv.org/pdf/2308.12950) <br> [DeepSeekMath: Pushing the Limits of Mathematical Reasoning in Open Language Models](https://arxiv.org/pdf/2402.03300) <br> [BioMistral: A Collection of Open-Source Pretrained Large Language Models for Medical Domains](https://arxiv.org/pdf/2402.10373) <br> [HyenaDNA: Long-Range Genomic Sequence Modeling at Single Nucleotide Resolution](https://arxiv.org/abs/2306.15794)                                                                                                           |
| 11/25       | Guest Lecture                                 | Combating Misinformation in the Age of LLMs by Canyu Chen   |
| 12/04       | Project presentation                          |                                                             |      





 