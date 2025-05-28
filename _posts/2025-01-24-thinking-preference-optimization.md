---
layout: post
category: blog
title: "[Research Preview] Thinking Preference Optimization"
snippet: "enhance model reasoning by using long/short CoT as preferred/rejected examples in DPO"
tags: [LLM]
author: Wang Yang, Song Jiang, Hongye Jin, Xiaotian Han
layout: post
category: blog
katex: True
---

<div class="tip">  
TL;DR  
<ul>  
<li>We introduce a novel approach to enhance model reasoning by using long/short CoT as preferred/rejected examples in DPO.</li>
<li>Our method demonstrates that carefully curated long/short thinking data pairs can significantly boost mathematical reasoning capabilities.</li>
</ul>  
</div>

## Overview

Developing models with robust reasoning capabilities remains a key challenge in AI. While supervised fine-tuning (SFT) on extensive slow-thinking datasets is effective, we discovered that a targeted approach using a smaller dataset (5,000 examples) contrasting fast and slow thinking can yield substantial improvements.

This blog presents our methodology, including dataset curation and training details, along with empirical results demonstrating the effectiveness of our approach.

## Method

### Data Curation
Our approach utilizes two distinct dataset types:

1. **SFT Datasets**:
    - [OpenO1-SFT](https://huggingface.co/datasets/VanWang/OpenO1-SFT-Pro-Filter): 
        - Based on `O1-OPEN/OpenO1-SFT` dataset, we remove special tokens (e.g., <Thought\>) and reformat final answers into the $\box$ format using GPT-4o-mini. we also filter out non-English entries and sequences longer than 8,192 tokens. The final dataset size is approximately 80,000 examples.
    - NuminaMath-CoT:
        - Randomly select examples from `AI-MO/NuminaMath-CoT` to match the size of the OpenO1-SFT dataset, used for comparison.
    - [Sky-T1_data_17k](https://huggingface.co/datasets/VanWang/SKY-SFT): 
        - Based on `NovaSky-AI/Sky-T1_data_17k`, we remove special characters and reformat the final answer into QWQ's output style.
    
2. **[DPO Data](https://huggingface.co/datasets/VanWang/NuminaMath-CoT_O1_Qwq)**:
    - **Rejected Answers**: A random selection of 5,000 examples from `AI-MO/NuminaMath-CoT` , where the dataset’s original answers were treated as the “rejected” entries.
    - **Chosen Answers**: New answers for each problem were generated using `Qwen/QwQ-32B-Preview` model.
    - **Filtering**: Only entries where both the “chosen” and “rejected” answers were correct were included, ensuring high-quality data.

### Training
1.	SFT Training:
	- Each SFT dataset is used to train a `LLaMA-3.1-8B` model for one epoch with a learning rate of 3e-5 and a batch size of 32.
2.	DPO Training:
	- Using the 5,000 curated examples, we perform DPO training on the SFT-trained models.
	- As a baseline, we also conduct DPO training directly on `LLaMA 3.1 8B-Instruct` model.
	- All DPO training is with the beta of 0.01 and a batch size of 32.
    

## Results

- We present the results of models trained with different datasets using SFT, followed by DPO training.

### Performance on AIME, MATH500, and MATH Overall 

| **Dataset**         | **Training** | **MATH500** | **MATH Overall** | **Improvement** |
|----------------------|--------------|-------------|------------------|-----------------|
| NuminaMath-CoT       | SFT          | 0.162       | 0.25             | -               |
|                      | DPO          | 0.176       | 0.26             | +8.64% / +4.00% |
| OpenO1-SFT           | SFT          | 0.230       | 0.33             | -               |
|                      | DPO          | 0.284       | 0.40             | +23.48% / +21.21% |
| Sky-T1_data_17k      | SFT          | 0.236       | 0.33             | -               |
|                      | DPO          | 0.252       | 0.36             | +6.78% / +9.09% |

Key Observations:
- DPO training consistently improves performance across all datasets
- OpenO1-SFT shows the most significant gains (+23.48% on MATH500)
- Improvements are maintained across different difficulty levels

#### MATH Performance by Difficulty Level
To further observe the model’s performance in mathematical reasoning, we collect 100 data points for each level in MATH dataset, and test the model’s scores on datasets from different levels.

| **Dataset**         | **Training** | **MATH1** | **MATH2** | **MATH3** | **MATH4** | **MATH5** |
|----------------------|--------------|-----------|-----------|-----------|-----------|-----------|
| NuminaMath-CoT       | SFT          | 0.45      | 0.31      | 0.19      | 0.09      | 0.05      |
|                      | DPO          | 0.51      | 0.27      | 0.24      | 0.11      | 0.01      |
| OpenO1-SFT           | SFT          | 0.58      | 0.40      | 0.31      | 0.20      | 0.10      |
|                      | DPO          | 0.73      | 0.45      | 0.40      | 0.28      | 0.09      |
| Sky-T1_data_17k      | SFT          | 0.61      | 0.36      | 0.33      | 0.22      | 0.08      |
|                      | DPO          | 0.68      | 0.40      | 0.26      | 0.22      | 0.14      |



### Notes

- [Kimi 1.5](https://github.com/MoonshotAI/Kimi-k1.5/blob/main/Kimi_k1.5.pdf) model explored similar approach but focused on using short CoT as preferred examples for inference efficiency.
