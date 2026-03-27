# Top AI models underperform in languages other than English

**Source:** https://www.economist.com/science-and-technology/2026/03/18/top-ai-models-underperform-in-languages-other-than-english
**Category:** science-and-technology
**Date:** 2026-03-18

---

Your browser does not support the <audio> element.

TO GET THE most accurate answer from a large language model, make sure to prompt it in the right language. An English-speaking user asking a world-leading model what to do about swollen legs late in pregnancy, for example, might be advised to watch out for pre-eclampsia, a common complication responsible for over 70,000 maternal deaths a year. An expectant mother who speaks Swahili, on the other hand, might be more likely to be told not to worry.

This illustrates a widespread problem affecting large language models (LLMs): even when an English-language version passes a safety test, it can still hallucinate dangerous misinformation in other languages. In a preprint published in October 2025, researchers found that accuracy in non-English languages was between about 12 and 29 percentage points lower than in English, depending on the model used. In the worst cases, a model capable of correctly answering roughly 75% of English queries scored as low as 22.6%.

The problem is becoming more pressing as LLM use accelerates in non-English-speaking regions. In January the Gates Foundation, a charity, and OpenAI, a builder of LLMs, announced $50m in funding to deploy AI tools in 1,000 primary health clinics across Africa, including for patient triage and medical advice in local languages. If such tools fail to account for the language gap, they may not be equipped for the task.

Two researchers working to establish the size of the gap are Tuka Alhanai at New York University Abu Dhabi and her collaborator Mohammad Ghassemi at Michigan State University. In February 2025 they and their co-authors released what they called a benchmark: a test for LLMs’ ability to understand other languages. Measured against this standard, things do seem to be improving.

This benchmark emerged from a preprint Drs Alhanai and Ghassemi posted online in December 2024. In their paper, the team tested the performance of world-leading models on reasoning and medical knowledge in 11 African languages. Even the top-scoring models, OpenAI’s GPT-4o and GPT-4, scored between 12 and 20 percentage points lower than they did in English. According to Dr Alhanai, that is how an English-language model from five years ago would perform.

After the benchmark was released last year, researchers at Stanford’s Centre for Research on Foundation Models used it to evaluate a new wave of frontier models. Preliminary leaderboard results suggest that these newer systems, including Gemini 2.0 Flash from Google DeepMind and Claude 3.7 Sonnet from Anthropic (all of which lag behind today’s state-of-the-art models), do perform better on African-language reasoning and medical tasks than the models tested in the original paper.

All the same, says Dr Ghassemi, the best answers still come in response to questions posed in English. “Even the newest frontier models still lag meaningfully in low-resource languages,” he says. Based on OpenAI’s own benchmarks for language performance, there was slight improvement from GPT-4o to o3, but progress has since stalled, and GPT-5.2 performance is “generally on par” with those previous models. Large gaps still persist, with tests conducted in December showing a score of 0.91 on French and 0.78 on Yoruba, on a much simpler set of questions than Dr Alhanai’s benchmark contains.

Other research has shown that this gap widens as a language’s difference from English increases. Any LLM would treat languages like Spanish and French more similarly to English, for example, than Igbo or Turkmen. This means the poorest performance often occurs among African languages, which are very different from English and where data are especially sparse.

The dominance of English-language data not only affects the answers LLMs give; it also shapes how they work. Before processing text, models break it up into small units known as tokens. Models trained predominantly on English often break non-English text into inefficient fragments, requiring more tokens to express the same meaning. For example, when using GPT-5 models, the first sentence in the Universal Declaration of Human Rights can be encoded in 36 tokens in English, but takes 47 in Hindi, 62 in Mandarin, and 132 in Yoruba. Because developers pay for model access based on the number of tokens processed, the same prompt can cost up to five times more in another language than the same English prompt.

Even explicitly multilingual models succumb to these pressures. A preprint from May 2025 that took Meta’s Llama-3.2-3B as a test case shows that the model often answers non-English questions by first retrieving facts in English and then translating the answer at the final step. Adding such additional steps introduces more opportunities for error.

The researchers found that these failures are most pronounced in languages like Mandarin, Japanese, and Korean, in which models got fewer than a quarter of factual answers correct, even when their internal representations showed that it had found the correct English answer. In contrast, the same model answered comparable questions correctly in English more than half the time.

One seemingly obvious response would be to add more English to a user’s prompt. But this can backfire. A study published in Proceedings of the 37th AAAI Conference on Artificial Intelligence in 2023 found that mixing languages within a single query, a practice known as code-mixing, often degraded performance even further. Models prompted with a mixture of English and Swahili perform markedly worse than those queried in either language, for instance. The researchers suggest this happens because mixing languages introduces competing internal representations and compounds translation errors, rather than helping models anchor on English. Similar effects appear within English itself: models trained on Standard American English underperform when queried in dialects like African American English or Singaporean English.

Fortunately, adding even small amounts of non-English data to a model’s training data can help boost its performance. In their preprint from December 2024, Dr Alhanai and her team found that fine-tuning a model with a small number of high-quality samples increased its accuracy in that language by over five percentage points. Even adding data from a related language led to improvements. In this spirit, Google Research has released an open-access speech data set covering over 20 sub-Saharan African languages, which is designed to help researchers and developers build voice-recognition and text-to-speech tools.

A more intensive approach is to redesign the way models break text into tokens. While such tokenisation is often learned automatically from large data sets, researchers can deliberately train models on more linguistically diverse data, producing more natural representations of African languages and improving the model’s ability to accurately and efficiently reason in them. Benchmarks like Dr Alhanai’s are a start, but their effectiveness ultimately depends on whether labs view them as tests worth acing. For now, though, says Dr Alhanai, “The people with the most to gain are the least able to use these tools.” ■

Curious about the world? To enjoy our mind-expanding science coverage, sign up to Simply Science, our weekly subscriber-only newsletter.

Delivered to you every week

Well Informed

It would seem so, even for amateurs

The GPUs that powered the AI boom can’t handle the workload

Could it be the first to build a commercial reactor?

They can be topped up in as little time as a tank of fuel

Well Informed

The evidence is tantalising. But that is not the same as proof

Boosters say they will do everything from aiding strength, recovery and longevity
