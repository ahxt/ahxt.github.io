#import "/content/blog.typ": *
#import "/src/3rd_party/mathyml/lib.typ" as mathyml
#import mathyml.prelude:*

#show: main.with(
  title: "LLM Tech Report",
  desc: "LLM Tech Report",
  date: "2025-06-08",
  tags: (
    "rl",
    "llms",
  ),
)

#outline(title: none, depth: 1)

= dots.llm1 (06/06/2025)
- #link("https://arxiv.org/pdf/2506.05767")[pdf], #link("https://huggingface.co/rednote-hilab/dots.llm1.inst")[huggingface]
- MoE that activates 14 billion parameters out of 142 billion parameters
- pretrained on 11.2T high-quality tokens
- adopt a sparse DeepSeekMoE framework
- classic MHA combined with QK-Norm
- auxiliary-loss-free strategy, which introduces a bias term for each expert, added to the corresponding affinity scores to determine the top-k routing
- post-training: SFT using 400K instances
- 1F1B based all-to-all communication and computation overlap solution


= Qwen3 Embedding (06/05/2025)
- #link("https://arxiv.org/pdf/")[pdf], #link("https://huggingface.co/")[huggingface]
- TBD



= OpenThoughts (06/05/2025)
- #link("https://arxiv.org/pdf/2506.04178v2")[pdf], #link("https://huggingface.co/open-thoughts/OpenThinker3-7B")[huggingface]
- We use OpenMath-2-Math as our sole math question source, CodeGolf and OpenCodeReasoning as our code question sources, and StackExchangePhysics and OrganicChemistryPDFs as our science question sources.
- We use difficulty-based filtering with GPT-4o-mini for code questions, and response length filtering with GPT-4.1-mini for math and science questions.
- Our final pipeline uses 16× answers per question for all domains. It uses exact deduplication for math and science and no deduplication for code.
- We do not perform answer filtering because no filtering strategy outperformed the baseline, which uses all the answers.
- Across all domains, using QwQ-32B as a teacher model outperforms all other teacher models, yielding an average accuracy improvement of 1.9% and 2.6% over using DeepSeek-R1 as a teacher for code and math
- OpenThinker3-7B is the best open-data reasoning model at the 7B scale, regardless of optimization algorithm choice (SFT, RL, or both)



= MiMo-VL (06/04/2025)
- #link("https://arxiv.org/pdf/2506.03569v1")[pdf], #link("https://huggingface.co/collections/XiaomiMiMo/mimo-vl-68382ccacc7c2875500cd212")[huggingface]
- A four-stage pre-training phase 
  - 1) projector warmup: freeze the ViT and LLM, Image-Caption Pairs
  - 2) vision-language alignment: ViT is then unfrozen, + Interleaved Data
  - 3) general multimodal pre-training: all parameters are trainable
  - 4)long-context SFT
- three components: 1) a ViT encoder, 2) a MLP projector (3) MiMo-7B-Base
- RLVF
  - verifiable STEM questions from open-source communities and proprietary K-12 collections
  - bounding box predictions
- GRPO: single-step policy updates following response rollout, eliminating the need for a clipped surrogate training objective


= Qwen 3 (05/14/2025)
- #link("https://arxiv.org/pdf/2505.09388v1")[pdf], #link("https://huggingface.co/collections/Qwen/qwen3-67dd247413f0e2e4f653967f")[huggingface]
- 6 dense models Qwen3-0.6B, Qwen3-1.7B, Qwen3-4B, Qwen3-8B, Qwen3-14B, and Qwen3-32B 
- 2 MoE models, Qwen3-30B-A3B and Qwen3-235B-A22B
- Qwen3-235B-A22B, has a total of 235B parameters with 22B activated ones
- we remove QKV-bias used in Qwen2 and introduce QK-Norm to ensure stable training for Qwen3
- The Qwen3 MoE models have 128 total experts with 8 activated experts per token.  Qwen3-MoE design excludes shared experts
- pretrain a total of 36 trillion tokens
- Qwen2.5-VL, PDF-like documents, amounting to trillions in total.
- employ Qwen2.5, Qwen2.5-Math, and Qwen2.5-Coder models to synthesize trillions of text tokens, including textbooks, question-answering, instructions, and code snippets, covering dozens of domains
- Pre-training Stage: (S1) General Stage: 30 trillion tokens, (S2) Reasoning Stage: 5T higher-quality tokens on STEM, coding, reasoning, and synthetic data, (S3) Long Context Stage: increase the base frequency from 10,000 to 1,000,000



= Llama-Nemotron (05/14/2025)
- #link("https://arxiv.org/pdf/2505.00949v3")[pdf], #link("https://huggingface.co/collections/nvidia/llama-nemotron-67d92346030a2691293f200b")[huggingface]
- five stage training:
  - optimizing inference efficiency with neural architecture search (NAS) from the Llama 3 
  - knowledge distillation and continued pretraining. 
  - SFT on a mix of standard instruction data and reasoning traces from  DeepSeek-R1
  - RL on complex mathematics and STEM datasets
  - alignment phase focused on instruction following and human preference.
- neural architecture search: Attention removal and Variable FFN dimensions
- both reasoning and non-reasoning data for supervised fine-tuning
- For reasoning samples, include the system instruction "detailed thinking on", and for non-reasoning samples, we use "detailed thinking off"
- GRPO: use a rollout prompt size of 72 and sample 16 responses per prompt with temperature = 1 and top_p = 1. During training, we set global batch size as 576 and conduct 2 gradient updates per rollout.
- Accuracy rewards: serve the Llama-3.3-70B-Instruct to judge whether the policy’s predictions match the ground truth answer
- "<think>" and "</think>" tags when using "detailed thinking on" mode and check for the non-existence of thinking tags when using "detailed thinking off" mode.



= MiMo (05/12/2025)
- #link("https://arxiv.org/pdf/2505.07608v1")[pdf], #link("https://huggingface.co/collections/XiaomiMiMo/mimo-6811688ee20ba7d0682f5cb9")[huggingface]
- pre-trained on 25 trillion tokens
- MultiToken Prediction objective
- GQA, pre-RMSNorm, SwiGLU activation and RoPE, similar to Llama and Qwen
- our final SFT dataset comprises about 500K samples
- learning rate of $3 × 10^(-5)$ and batch size of 128. Samples are packed to the maximum length of 32,768 tokens during training
- two categories of verifiable problems, mathematics and code
- GRPO: Removal of KL Loss, Dynamic Sampling, Clip-Higher
- verl
- an easy data resampling strategy. maintain an easy data pool, 10% sample from this easy data pool
- 

= Seed 1.5-VL (05/11/2025)
- #link("https://arxiv.org/pdf/2505.07062v1")[pdf]
- a 532M-parameter vision encoder and a MoE LLM of 20B active parameters
- 


= Phi-4-reasoning (04/30/2025)
- #link("https://arxiv.org/pdf/2504.21318")[pdf], #link("https://huggingface.co/microsoft/Phi-4-reasoning")[huggingface]

- 14B parameters, SFT from Phi-4
- highlight the benefits of careful data curation and SFT for reasoning language models
- Phi-4 base model was pretrained using large innovative synthetic datasets specifically curated to prioritize reasoning and complex problem-solving
- Seeds database
  - are used in both SFT for Phi-4-reasoning and RL for Phi-4-reasoning-plus.
  - across STEM disciplines and coding, also incorporating general-purpose question-answer style prompts.
  - include alignment-focused data aimed at enhancing model safety, mitigating potential harms, and promoting responsible AI practices

- we found o3-mini with medium “reasoning effort” effort to have similar effect to DeepSeek-R1 when used as teachers

- rewards: length-aware correctness, incompleteness, invalid “thinking” block, repetition penalty
- We select as our RL checkpoint the model with the best observed AIME 2024 score, which is the model trained for 90 steps, over only ∼ 6k examples (and 8 trajectories of responses per example)


= Seed 1.5-thinking (04/29/2025)
- #link("https://arxiv.org/pdf/")[pdf], #link("https://huggingface.co/")[huggingface]
- TBD

= Kimi-Audio (04/25/2025)
- #link("https://arxiv.org/pdf/")[pdf], #link("https://huggingface.co/")[huggingface]
- TBD


= Trillion 7B (04/21/2025)
- #link("https://arxiv.org/pdf/2504.15431v1")[pdf], #link("https://huggingface.co/collections/trillionlabs/trillion-7b-preview-67dba4aebaeae23ec78b1b20")[huggingface]
- For post-training, we closely follow the Tülu 3 framework consisting of SFT, DPO, and RLVR.
- 2T tokens, Multi-token Prediction
- extend the RoPE base from 100,000 to 1,000,000 using the ABF


= Seedream 3.0 (04/16/2025)
- #link("https://arxiv.org/pdf/")[pdf], #link("https://huggingface.co/")[huggingface]
- TBD



= Kimi-VL (04/15/2025)
- #link("https://arxiv.org/pdf/")[pdf], #link("https://huggingface.co/")[huggingface]
- TBD



= Tulu 3 (04/14/2025)
- #link("https://arxiv.org/pdf/2411.15124v5")[pdf], #link("https://huggingface.co/collections/allenai/tulu-3-models-673b8e0dc3512e30e7dc54f5")[huggingface]
- Stage 1: Data Curation
  - Precise Instruction Following
  - Math and Coding
  - Noncompliance and Safety
- Stage 2: Supervised Finetuning
- Stage 3: Preference Tuning
  - Direct Preference Optimization
  - We find that length-normalized DPO works best, which uses the following objective:
- Stage 4: Reinforcement Learning with Verifiable Rewards
  - $max_(pi_theta) E_(y~pi_theta(x)) [R_"RLVR"(x, y)] = [v(x, y) - beta op("KL")[pi_theta(y|x) || pi_"ref"(y|x)]$ where $v(x, y) = alpha "if correct, 0 otherwise."$ and $alpha=10$ is a hyperparameter.
  - RLVR Data: GSM8K, MATH, and IFEval
  - 30,000 prompts with ground truth labels
  - Initialize the Value model from a General RM
  - Disable Dropout
  - Train with the SFT Dataset and Shuffle Between Epochs
  - Non End-of-Sequence (EOS) Penalty
  - Advantage Whitening / Normalization
  - Starting from a Weaker Model Can Converge to the Same Verifiable Rewards.
  - OpenRLHF
- Batch Aggregation: Early during training Tülu 3, we noticed a gap in performance between SFT models trained on our OpenInstruct framework and models trained in other settings such as on TPUs. :padding tokens without taking into account gradient accumulation or distributed training setups





= Qwen2.5-Omni (03/26/2025)
- #link("https://arxiv.org/pdf/")[pdf], #link("https://huggingface.co/")[huggingface]
- TBD


= Gemma 3 (03/25/2025)
- #link("https://arxiv.org/pdf/2503.19786v1")[pdf], #link("https://huggingface.co/collections/google/gemma-3-release-67c6c6f89c4f76621268bb6d")[huggingface]

- alternate between a local sliding window self-attention and global self-attention, with 5 local layers for every global layer, the first layer is local layer.
- replace the soft-capping of Gemma 2 with QK-norm
- increase RoPE base frequency from 10k to 1M on global self-attention layers
- keep the frequency of the local layers at 10k
- 14T tokens for Gemma 3 27B, 12T for the 12B version, 4T for the 4B, and 2T tokens for the 1B
- Distillation. We sample 256 logits per token, weighted by teacher probabilities.



= Phi-4-Mini (03/07/2025)

- #link("https://arxiv.org/pdf/2503.01743")[pdf], #link("https://huggingface.co/microsoft/Phi-4-mini-instruct")[huggingface]

= Qwen2.5-VL (02/19/2025)
- #link("https://arxiv.org/pdf/")[pdf], #link("https://huggingface.co/")[huggingface]
- TBD

= Janus-Pro (01/29/2025)
- #link("https://arxiv.org/pdf/")[pdf], #link("https://huggingface.co/")[huggingface]
- TBD



= DeepSeek-R1 (01/20/2025)
- #link("https://github.com/deepseek-ai/DeepSeek-R1/blob/main/DeepSeek_R1.pdf")[pdf], #link("https://huggingface.co/collections/deepseek-ai/deepseek-r1-678e1e131c0169c0bc89728d")[huggingface]
  
- DeepSeek-R1-Zero: use DeepSeek-V3-Base as the base model and employ GRPO as the RL framework to improve model performance in reasoning. During training.
- DeepSeek-R1: 
    - *(DeepSeek-V3-Base)->(DeepSeek-V3-SFT1)* cold-start SFT with thousands of data from in-context long CoT prompting + DeepSeek-R1Zero readable outputs
    - *(DeepSeek-V3-SFT1)->(DeepSeek-V3-RL)* reasoning-oriented RL like DeepSeek-R1-Zero. 
    - *(DeepSeek-V3-Base)->(DeepSeek-V3-SFT2)* two epoch fine-tuning DeepSeek-V3-Base using 600k reasoning related training samples via rejection sampling on the RL checkpoint + 200k non-reasoning training samples
    - *(DeepSeek-V3-SFT2)->(DeepSeek-R1)* After fine-tuning, an additional RL process, taking into account prompts from all scenarios.
- Do not use ORM or PRM, use rule-based reward system: Accuracy rewards, Format rewards.
- Emphasize that neural reward model may suffer from reward hacking in the large-scale reinforcement learning process
- Designing a straightforward template that guides the base model to adhere to specified instructions
- *(Interesting)* DeepSeek-R1-Zero naturally acquires the ability to solve increasingly complex reasoning tasks by leveraging extended test-time computation. This improvement is not the result of external adjustments but rather an intrinsic development within the model.
- *(Interesting)* Behaviors such as reflection are not explicitly programmed but instead emerge as a result of the model's interaction with the reinforcement learning environment.
- *Aha Moment of DeepSeek-R1-Zero*: DeepSeek-R1-Zero learns to allocate more thinking time to a problem by reevaluating its initial approach.
  - DeepSeek-R1-Zero struggles with challenges like poor readability, and language mixing.
  - Distillation from DeepSeek-R1 to smaller dense models works well. This demonstrates that the reasoning patterns discovered by larger base models are crucial for improving reasoning capabilities

= Kimi K1.5 (01/20/2025)
- #link("https://github.com/MoonshotAI/Kimi-k1.5/blob/main/Kimi_k1.5.pdf")[pdf]
  
- Long-CoT Supervised Fine-Tuning
    - construct a small yet high-quality long-CoT warmup dataset
- Reinforcement Learning
    - For verifiable problems, the reward is predefined criteria or rules. For problems with free-form ground truth, us a reward model r(x, y, y∗).
    - Length Penalty to avoid overthinking phenomenon
    - Several approaches for this long2short problem, including model merging, shortest rejection sampling, DPO, and long2short RL.

= MiniMax-01 (01/15/2025)

- #link("https://arxiv.org/abs/2501.08313")[pdf], #link("https://huggingface.co/MiniMaxAI/MiniMax-Text-01")[huggingface minimax-01]
  
- 456 billion parameters, 45.9 billion activations, and 32 experts, 1.5T tokens for pre-training
- good to know that the naive linear attention $O = "Norm"(Q(K^top V))$ has efficiency issues due the cumulative sum operation when consider the causal mask
- Need to learn the detail of Lightning Attention #link("https://sustcsonglin.github.io/assets/pdf/talk_250117.pdf")
- Transformer-style block, with each comprises a channel mixer (an attention block, lightning attention and softmax attention) and a feature mixer (an MLP block, an MoE that incorporates multiple feed-forward networks (FFNs))
- hybrid architecture have yielded promising results, delve deeper into its potential through two variants: hybrid-cosformer2 and hybrid-#link("https://arxiv.org/pdf/2404.07904")[hgrn2].
- Almost perfect long-context understanding ability, with a context window of 1M tokens

= Qwen2.5-Math-PRM (01/13/2025)

- #link("https://arxiv.org/pdf/2501.07301")[pdf], #link("https://hf.co/Qwen/Qwen2.5-Math-PRM-7B")[huggingface]
  
- Commonly used Monte Carlo (MC) estimation-based data synthesis for PRMs typically yields inferior performance and generalization compared to LLM-as-a-judge and human annotation methods.
- Reveal the potential bias in using response-level BoN evaluation alone for PRMs
- TBD

= OLMo 2 (12/31/2024)

- #link("https://arxiv.org/pdf/2501.00656")[pdf], #link("https://huggingface.co/collections/allenai/olmo-2-674117b93ab84e98afc72edc")[huggingface olmo-2]
  
- up to 5T tokens, 95% derived from web data; 7B 13B parameters
- Reordered norm and QK-norm. $h := x + "RMSNorm"("Attention"(x)); h_"out" := h + "RMSNorm"("MLP"(x))$
- Data can be a cause of both gradient norm and loss spikes. When investigating training batches at which spikes occurred, we found a high prevalence of instances containing long, repeated n-gram sequences
- improving training stability from OLMo 2's initialization, initialize every parameter from a normal distribution with a mean of $0$ and a standard deviation of $0.02$
- decreasing the AdamW $epsilon$ from $10^(-5)$ to $10^(-8)$
- confirm the effectiveness of this approach, also known as model souping, on six different mid-training mixes
- three phases of training: SFT, preference tuning with DPO, and RLVR
- turn off weight decay for embeddings and observe that embedding norms settle in a healthy region.

= Deepseek-V3 (12/16/2024)

- #link("https://github.com/deepseek-ai/DeepSeek-V3/blob/main/DeepSeek_V3.pdf")[pdf], #link("https://huggingface.co/collections/deepseek-ai/deepseek-v3-676bc4546fb4876383c4208b")[huggingface]
  
- *multi-token prediction objective*, the acceptance rate of 2nd token prediction is 85% ~ 90%
- *knowledge distillation from DeepSeek-R1*, notably improves its reasoning performance
- *balanced expert loading* introduce a bias term for each expert to help determine the top-K routing
- *DualPipe*: overlap the computation and communication within forward and backward chunks.
- *fp8 quantization during training*: introduce a fine-grained quantization strategy for fp8
- *an efficient and lightweight training framework*, HAI-LLM. (might be the impressive engineering basis)
- numbers: 14.8T tokens for pre-training
- RMSNorm recomputation during back-propagation
- adopt the BF16 for first and second moments in the AdamW
- do not incorporate cross-sample attention masking during training
- use document packing method for data integrity
- incorporate the FIM strategy in the pre-training
- shared embedding and output head for multi-token prediction (due the DualPipe implementation)
- not use costly tensor parallelism
- suggestions on hardware design
    - higher FP8 GEMM accumulation precision
    - tile- and block-wise quantization
          - online quantization
      - transposed GEMM operations


= Qwen2.5 (12/19/2024)

- #link("https://arxiv.org/pdf/2412.15115")[pdf]
  - #link("https://huggingface.co/collections/Qwen/qwen25-66e81a666513e518adb90d9e")[huggingface]
  
  - 0.5B, 1.5B, 3B, 7B, 14B, 72B; 18T token for pre-training
- Qwen2-72B-Instruct and Qwen2-Math-72B-Instruct generate synthetic data in mathematics, code, and knowledge domains
  - increase RoPE base from 10,000 to 1,000,000 using the ABF technique
  - develop long-response datasets, capable of generating high-quality 8,192 tokens


= Phi-4 (12/12/2024)

- #link("https://arxiv.org/pdf/2412.08905")[pdf]
  
- numbers: 14B, 10T tokens
- 50 broad types, 400B-token synthetic datasets, spanning an array of topics, skills, and natures of interaction
- question-answer data contributed significantly to various capabilities, such as mathematical reasoning and academic performance
- one round of SFT, one round of DPO on data from our pivotal token search method, and one round of DPO on full length preference pairs
- 8B tokens of data for SFT, all formatted in the chatml format

= TÜLU 3 (12/06/2024)
- #link("https://arxiv.org/pdf/2411.15124")[pdf], #link("https://huggingface.co/collections/allenai/tulu-3-models-673b8e0dc3512e30e7dc54f5")[huggingface]

- synthetic data generation for target skills such as precise instruction following, math and coding
- safety SFT data was generally orthogonal to our other datasets
- changing the chat template, replacing the newlines at the end of assistant messages with an eos
- SFT performance noticeably varies based on the seed
- model soup does not always outperform the best single run
- use length-normalized DPO for tuning our preference data mixtures and generation methods
- scaling the number of unique prompts improve downstream DPO performance
- for our final DPO models we decided on using a learning rate of $2.0 times 10^(-7)$
- introduce (RLVR), a novel method for training llm on tasks with verifiable outcomes
- RLVR focus on two domains (mathematics, exact instruction following) and three evaluations (GSM8K, MATH, IFEval)

= Llama 3 (08/15/2024)

- #link("https://arxiv.org/pdf/2407.21783")[pdf], #link("https://huggingface.co/collections/meta-llama/llama-32-66f448ffc8c32f949b04c8cf")[huggingface]

- 405B parameters on 15.6T tokens using a context window of 8K tokens.
- supported context window to 128K tokens
- supervised finetuning on instruction tuning data and Direct Preference Optimization
- annealing on small amounts of high-quality code and mathematical data can boost the performance of pre-trained models on key benchmarks
- Llama 3 405B is trained on up to 16K H100 GPUs
- use fully sharded data parallelism (FSDP) for training
- design a new multi-message chat protocol which uses various special header and termination tokens.
- average models obtained from experiments using various versions of data or hyperparameters at each RM, SFT, or DPO stage

= OLMo (07/07/2024)

- #link("https://arxiv.org/pdf/2402.00838")[pdf], #link("https://huggingface.co/collections/allenai/olmo-suite-65aeaae8fe5b6b2122b46778")[huggingface olmo], #link("https://huggingface.co/collections/allenai/olmo-2-674117b93ab84e98afc72edc")[huggingface olmo-2]

- 1B and 7B models, 2T tokens Dolma dataset
- use up to 256 nodes on this cluster, where each node consists of 4x AMD MI250X GPUs with 128GB of memory5 and 800Gbps of interconnect
- release model weights, training data and training and evaluation code.

