---
layout: default
permalink: /
katex: True
---

<img class="profile-picture" src="{{site.baseurl}}/{{site.profile-picture}}">


Hi there!

I am an Assistant Professor of Computer Science at Case Western Reserve University from Fall 2024. I completed my Ph.D. at Texas A&M University. My research focuses on artificial intelligence, machine learning, data science, and, more recently, large language models (LLMs). You can contact me via [xhan (at) case.edu]().

[ google scholar ](https://scholar.google.com/citations?user=Uromx98AAAAJ)/[ $$\mathbb{X}$$ ](https://x.com/XiaotianHan1)/ [ bluesky ](https://bsky.app/profile/xhan2.bsky.social) / [github](https://github.com/ahxt) / [ cv ](/assets/Xiaotian_CV.pdf)



---

<span style="color:red">[Prospective Students]</span> I'm seeking multiple self-motivated students (Ph.D., Internship) for Fall 2025. If you're interested in LLM and AI4Sci, please email me at <a href="mailto:xhan.hire@gmail.com" target="_blank">xhan.hire@gmail.com</a> with your CV and transcripts after you submitted the application. For more details, refer to [here](/group.html).

---


# News
- *2024.12*: 🔥 Technical report of [NeuralPLexer3](https://arxiv.org/pdf/2412.10743) for biomolecular complex structure prediction is out!
- *2024.11*: 🔥 [Graph Convolution≈Mixup](https://openreview.net/forum?id=koC6zyaj73) is selected as Oral Presentation at LoG2024 TMLR Track!
- *2024.08*:  One paper on [Understanding Graph Convolution](https://openreview.net/forum?id=koC6zyaj73) accepted by TMLR!
- *2024.08*:  Excited to join Case Western Reserve University as an assistant professor!
- *2024.07*:  I am excited to start my MLsys internship at [Iambic Therapeutics](https://www.iambic.ai/)
- *2024.06*:  🔥 [LLM Maybe LongLM](https://arxiv.org/abs/2401.01325) has been selected as <span style="color:red">Spotlight (3.5%)</span> at ICML2024!
- *2024.05*:  [One paper](https://arxiv.org/pdf/2312.15194) is accepted by ACL2024!
- *2024.04*:  [LLM Maybe LongLM: Self-Extend LLM Context Window Without Tuning](https://arxiv.org/abs/2401.01325) is accepted by ICML2024!
- *2024.04*: My [LiteLLaMa](https://huggingface.co/ahxt/LiteLlama-460M-1T) has been downloaded over 230K times on HuggingFace!
- *2024.04*: Honored to receive the [Jane Street Graduate Research Fellowship Award Honorable Mention](https://www.janestreet.com/join-jane-street/programs-and-events/grf-profiles-2024/).
- *2024.03*: Implemented [Triton](https://github.com/openai/triton) based flash self-extend. Please try [FlashSelfExtend](https://github.com/datamllab/LongLM/blob/master/self_extend_patch/selfextend_flash_attn_triton.py)!
- *2024.01*: One paper on [Fairness Benchmark](https://arxiv.org/pdf/2306.09468.pdf) accepted by ICLR2024!
- *2024.01*: Our [Survey on LLMs](https://arxiv.org/abs/2304.13712) accepted by TKDD!
- *2024.01*: New preprint [LLM Maybe LongLM: Self-Extend LLM Context Window Without Tuning](https://arxiv.org/abs/2401.01325)!
- <details> <summary>More</summary>
  <ul>
    <li><em>2023.12:</em> One paper accepted by AAAI2024-SRRAI.</li>
    <li><em>2023.09:</em> One paper accepted by NeurIPS2023.</li>
    <li><em>2023.07:</em> 🔥🔥 Thrilled to release my <a href="https://huggingface.co/ahxt/LiteLlama-460M-1T">LiteLLaMa</a> on HuggingFace, try it out!</li>
    <li><em>2023.07:</em> Our paper <a href="https://arxiv.org/pdf/2303.04360.pdf">LLM for Clinical Text Mining</a> accepted by <a href="https://amia.org/education-events/amia-2023-annual-symposium">AMIA2023</a>!</li>
    <li><em>2023.05:</em> One paper accepted by TMLR, <a href="https://openreview.net/forum?id=LjDFIWWVVa">Retiring ∆DP</a>!</li>
    <li><em>2023.05:</em> Thrilled to start my internship at Amazon.</li>
    <li><em>2023.01:</em> One paper accepted by ICLR2023, <a href="https://arxiv.org/pdf/2210.00102.pdf">MLPInit</a>.</li>
    <li><em>2022.09:</em> Thrilled to start my internship at Meta, work with <a href="https://wqfcr.github.io/">Qifan Wang</a>.</li>
    <li><em>2022.07:</em> Our Paper <a href="https://arxiv.org/pdf/2202.07179.pdf">$\mathcal{G}$-Mixup</a> is awarded an Outstanding Paper Award at ICML 2022!</li>
    <li><em>2022.05:</em> Thrilled to start my internship at Snap Inc., work with <a href="http://nshah.net/">Neil Shah</a>.</li>
    <li><em>2022.05:</em> One paper accepted by ICML2022 (Oral).</li>
    <li><em>2022.01:</em> One paper accepted by ICLR2022.</li>
    <li><em>2022.01:</em> One paper accepted by TheWebConf2022.</li>
    <li><em>2020.05:</em> One paper accepted by RecSys2020.</li>
  </ul>

  </details>


# Blogs

<!-- > - 01/21/2025 » [LLM Tech Report Notes (updated on 01/21/2025)](/blog/2025-01-21-llm-tech-reoport/)
> - 12/30/2024 » [Reproduce the inference time scaling exp](/blog/2024-12-30-inference-time-scaling-exp/)
> - 12/12/2024 » [Cross-entropy loss and its optimization](/blog/2024-12-12-celoss/)
> - 11/20/2024 » [Graph Convolution ≈ Mixup](/blog/2024-11-20-graph-convolution-mixup/)
> - 10/20/2024 » [Attention and its gradient](/blog/2024-10-20-attention/)
> - 10/19/2024 » [Softmax and its triton implementation](/blog/2024-10-19-softmax/) -->

<blockquote>
<ul>
  {% for post in site.posts %}
    {% if post.category == "blog" %}
      <li>{{ post.date | date: "%m/%d/%Y" }} » <a href="{{ post.url }}">{{ post.title }}</a></li>
    {% endif %}
  {% endfor %}
</ul>
</blockquote>





# Publications

- On the Equivalence of Graph Convolution and Mixup  [[pdf](https://openreview.net/pdf?id=koC6zyaj73)]
  - **Xiaotian Han**, Hanqing Zeng, Yu Chen, Shaoliang Nie, Jingzhou Liu, Kanika Narang, Zahra Shakeri, Karthik Abinav Sankararaman, Song Jiang, Madian Khabsa, Qifan Wang, Xia Hu
  - TMLR2024, <span style="color:red">LoG2024 TMLR Track Oral Presentation</span>

- PokeMQA: Programmable knowledge editing for Multi-hop Question Answering [[pdf](https://arxiv.org/pdf/2312.15194.pdf)]
  - Hengrui Gu, Kaixiong Zhou, **Xiaotian Han**, Ninghao Liu, Ruobing Wang, Xin Wang
  - ACL2024

- LLM Maybe LongLM: Self-Extend LLM Context Window Without Tuning [[pdf](https://arxiv.org/abs/2401.01325)][[code](https://github.com/datamllab/LongLM)]
  - Hongye Jin<sup>\*</sup>, **Xiaotian Han**<sup>\*</sup>, Jingfeng Yang, Zhimeng Jiang, Zirui Liu, Chia-Yuan Chang, Huiyuan Chen, Xia Hu
  - ICML2024, <span style="color:red">Spotlight (3.5%)</span>

- FFB: A Fair Fairness Benchmark for In-Processing Group Fairness Methods [[pdf](https://arxiv.org/pdf/2306.09468.pdf)] [[code](https://github.com/ahxt/fair_fairness_benchmark)]
    - **Xiaotian Han**, Jianfeng Chi, Yu Chen, Qifan Wang, Han Zhao, Na Zou, Xia Hu.
    - ICLR2024
  
- Harnessing the Power of LLMs in Practice: A Survey on ChatGPT and Beyond [[pdf](https://arxiv.org/pdf/2304.13712.pdf)]  [[code](https://github.com/Mooler0410/LLMsPracticalGuide)] 
  - Jingfeng Yang<sup>\*</sup>, Hongye Jin<sup>\*</sup>, Ruixiang Tang<sup>\*</sup>, **Xiaotian Han**<sup>\*</sup>, Qizhang Feng<sup>\*</sup>, Haoming Jiang, Bing Yin, Xia Hu
  - TKDD, 2023

- Chasing Fairness under Distribution Shift: a Model Weight Perturbation Approach [[pdf](https://arxiv.org/pdf/2303.03300.pdf)]
  - **Xiaotian Han**<sup>\*</sup>, Zhimeng Jiang<sup>\*</sup>, Hongye Jin, Guanchu Wang, Rui Chen, Na Zou, Xia Hu.
  - NeurIPS2023

- Marginal Nodes Matter: Towards Structure Fairness in Graphs. [[pdf](https://arxiv.org/pdf/2310.14527.pdf)]
  - **Xiaotian Han**, Kaixiong Zhou, Ting-Hsiang Wang, Jundong Li, Fei Wang, Na Zou
  - KDD Explorations, 2022

- Does Synthetic Data Generation of LLMs Help Clinical Text Mining? [[pdf](https://arxiv.org/pdf/2303.04360.pdf)]
  - **Xiaotian Han**<sup>\*</sup>, Ruixiang Tang<sup>\*</sup>, Xiaoqian Jiang, Xia Hu 
  - AMIA, 2023

- Retiring $$\Delta$$DP: New Distribution-Level Metrics for Demographic Parity. [[pdf](https://arxiv.org/pdf/2301.13443.pdf)]
  - **Xiaotian Han**<sup>\*</sup>, Zhimeng Jiang<sup>\*</sup>, Hongye Jin<sup>\*</sup>, Zirui Liu, Na Zou, Qifan Wang, Xia Hu 
  - TMLR, 2023

- MLPInit: Embarrassingly Simple GNN Training Acceleration with MLP Initialization. [[pdf](https://arxiv.org/pdf/2210.00102.pdf)][[code](https://github.com/snap-research/MLPInit-for-GNNs)]
  - **Xiaotian Han**, Tong Zhao, Yozen Liu, Xia Hu, Neil Shah
  - ICLR2023

- $$\mathcal{G}$$-Mixup: Graph Augmentation for Graph Classification. [[pdf](https://arxiv.org/abs/2202.07179)]
  - **Xiaotian Han**, Zhimeng Jiang, Ninghao Liu, Xia Hu.
  - ICML2022,  <span style="color:red">Outstanding Paper Award</span>

- Geometric Graph Representation Learning via Maximizing Rate Reduction. [[pdf](https://arxiv.org/pdf/2202.06241.pdf)]  [[code](https://github.com/ahxt/G2R)]
  - **Xiaotian Han**, Zhimeng Jiang, Ninghao Liu, Qingquan Song, Jundong Li, Xia Hu. 
  - TheWebConf2022

- Aspect-Level Deep Collaborative Filtering via Heterogeneous Information Networks. [[pdf](https://www.ijcai.org/proceedings/2018/0471.pdf)]  [[code](https://github.com/ahxt/NeuACF)]
  - **Xiaotian Han**, Chuan Shi, Senzhang Wang, S Yu Philip, Li Song. 
  - IJCAI2018

- Representation Learning with Depth and Breadth for Recommendation using Multi-view Data. [[pdf](http://www.shichuan.org/doc/57.pdf)] 
  - **Xiaotian Han**, Chuan Shi, Lei Zheng, S Yu Philip, Jianxin Li, Yuanfu Lu. 
  - APWeb-WAIM2018


- Chasing Fairness in Graphs: A GNN Architecture Perspective
  - Zhimeng Jiang, **Xiaotian Han**, Chao Fan, Zirui Liu, Na Zou, Ali Mostafavi, Xia Hu. <br>
  - AAAI, 2024, Special Track on Safe, Robust and Responsible AI (SRRAI).

- Generalized Demographic Parity for Group Fairness. [[pdf](https://openreview.net/pdf?id=YigKlMJwjye)] 
  - Zhimeng Jiang, **Xiaotian Han**, Chao Fan, Fan Yang, Ali Mostafavi, Xia Hu.
  - ICLR2022 

- AutoRec: An Automated Recommender System. [[pdf](https://dl.acm.org/doi/abs/10.1145/3383313.3411529)] [[code](https://github.com/datamllab/AutoRec)]
  - Ting-Hsiang Wang, Qingquan Song, **Xiaotian Han**, Zirui Liu, Jin Haifeng, Xia Hu. 
  - Recsys2020, Demo

- FlowScope: Spotting Money Laundering Based on Graphs. [[pdf](https://ojs.aaai.org/index.php/AAAI/article/view/5906)]
  - Xiangfeng Li, Shenghua Liu, Zifeng Li, **Xiaotian Han**, Chuan Shi, Bryan Hooi, He Huang, Xueqi Cheng.
  - AAAI2020

- Embedding Geographic Information for Anomalous Trajectory Detection. [[pdf](https://link.springer.com/article/10.1007/s11280-020-00812-z)]
  - Ding Xiao, Li Song, Ruijia Wang, **Xiaotian Han**, Yanan Cai, Chuan Shi.
  - World Wide Web 2020

- Metapath-guided Heterogeneous Graph Neural Network for Intent Recommendation. [[pdf](https://dl.acm.org/doi/abs/10.1145/3292500.3330673)] 
  - Shaohua Fan, Junxiong Zhu, **Xiaotian Han**, Chuan Shi, Linmei Hu, Biyu Ma, Yongliang Li.
  - KDD2019

- Deep Collaborative Filtering with Multi-aspect Information in Heterogeneous Networks. [[pdf](https://arxiv.org/abs/1909.06627)]
  - Chuan Shi, **Xiaotian Han**, Li Song, Xiao Wang, Senzhang Wang, Junping Du, Philip, S Yu.
  - TKDE2019

- Anomalous Trajectory Detection Using Recurrent Neural Network. [[pdf](http://shichuan.org/doc/60.pdf)]
  - Li Song, Ruijia Wang, Ding Xiao, **Xiaotian Han**, Yanan Cai, Chuan Shi. 
  - ADMA2018, <span style="color:red">Best Paper Award</span>


# Preprints
- Do We Really Achieve Fairness with Explicit Sensitive Atrributes?, 
  - **Xiaotian Han**, Zhimeng Jiang, Ninghao Liu, Na Zou, Qifan Wang, Xia Hu

- You Only Debias Once: Towards Flexible Accuracy-Fairness Trade-offs at Inference Time, 
  - **Xiaotian Han**, Tianlong Chen, Kaixiong Zhou, Zhimeng Jiang, Zhangyang Wang, Xia Hu

- GrowLength: Accelerating LLMs Pretraining by Progressively Growing Training Length [[pdf]](https://arxiv.org/pdf/2310.00576.pdf), 
  - **Xiaotian Han** *, Hongye Jin*, Jingfeng Yang, Zhimeng Jiang, Chia-Yuan Chang, Xia Hu

- Fair Graph Message Passing with Transparency, Zhimeng Jiang, 
  - **Xiaotian Han**, Chao Fan, Zirui Liu, Na Zou, Ali Mostafavi, Xia Hu

- Towards Assumption-free Bias Mitigation, 
  - Chia-Yuan Chang, Yu-Neng Chuang, Kwei-Herng Lai, **Xiaotian Han**, Xia Hu, Na Zou

- Gradient Rewiring for Editable Graph Neural Network Training, 
  - Zhimeng Jiang, Zirui Liu, **Xiaotian Han**, Qizhang Feng, Hongye Jin, Qiaoyu Tan, Kaixiong Zhou, Na Zou, Xia Hu

- Beyond Fairness: Age-Harmless Parkinson's Detection via Voice, 
  - Yicheng Wang, **Xiaotian Han**, Leisheng Yu, Na Zou
  
- Reducing Communication Overhead in Distributed GNN Training via Client-Server Knowledge Distillation, 
  - Song Jiang, **Xiaotian Han**, Yinglong Xia, Qifan Wang, Yizhou Sun


# Educations
- *Aug. 2019 - Aug. 2024*, Ph.D., Computer Science, Texas A&M University.
- *Sept. 2016 - Jun. 2019*, Master Degree, Computer Science, Beijing Univ. of Posts and Telecommunications.
- *Sept. 2011 - Jun. 2015*, Bacheler Degree, Communication Engineering, Shandong University.

# Internships
- Amazon, Palo Alto, CA.  *May 2023 – Aug 2023*
  - Research Intern
  - Large Language Model
  - Work with [Jingfeng Yang](https://jingfengyang.github.io/), [Haoming Jiang](https://hmjianggatech.github.io/), [Qingyu Yin](), [Bin Bi](), [Chao Zhang](http://chaozhang.org/).
- Meta, Menlo Park, CA.  *Sept. 2022 – April 2023*
  - Research Intern
  - Understanding graph neural networks
  - Work with [Qifan Wang](https://wqfcr.github.io/)
- Snap Research, Seattle, WA. *Mar. 2022 - Aug. 2022*
  - Research Intern
  - Graph neural network training acceleration.
  - Work with [Neil Shah](http://nshah.net/), [Tong Zhao](https://tzhao.io/), Yozen Liu
- Microsoft Research Asia, Beijing, China. *Mar. 2019 - May. 2019*
  - Research Intern
  - Hyperparameter Optimization and AutoML.
- Alibaba Group, Hangzhou, China. *Jun. 2018 - Sept. 2018*
  - Research Intern
  - Query recomendataion in Taobao App.


# Awards & Honors
- Jane Street Graduate Research Fellowship Award Honorable Mention, 2024
- Outstanding Paper Award, ICML2022
- Excellent Ph.D. Student Award (One Per Year), Department of CSE, Texas A&M University, 2023
- NeurIPS2023 Scholar Award
- Grad School Research and Presentation Travel Award, Texas A&M University, 2023
- Best Paper Awards, ADMA2018
- Travel Grant, Department of Computer Science & Engineering, Texas A&M University, 2022, 2023
- Travel Award, ICML2022.
- Outstanding Reviewer Award, ICML2022.
- Best Reviewer Award, CCF Transactions on Pervasive Computing and Interaction 2020


# Professional Acitivities
- **Reviewer** ICLR2023,2024; ICML2022,2023,2024; NeurIPS2022,2023,2024; AAAI2021,2022,2023,2024; WWW2023;
WSDM2024; CIKM2023; IJCAI2021,2023; EMNLP2023; ICDM2022;
- **Session Chair** WWW2023, ICML2022
 


