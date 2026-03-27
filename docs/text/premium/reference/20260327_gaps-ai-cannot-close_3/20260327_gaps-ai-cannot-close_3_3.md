# The next phase of artificial intelligence may require very different processors

**Source:** https://www.economist.com/science-and-technology/2026/03/18/the-next-phase-of-artificial-intelligence-may-require-very-different-processors
**Category:** science-and-technology
**Date:** 2026-03-18

---

Your browser does not support the <audio> element.

NVIDIA, A MANUFACTURER of computer chips, is the most valuable company in the world. It owes its success to the versatility of the graphics processing unit (GPU), a chip it pioneered in the late 1990s. Originally designed to make video games look better, GPUs turned out to be well suited to training large language models (LLMs). That discovery sent demand for Nvidia’s chips, and its valuation, soaring.

Times are changing fast. Demand for AI computing is shifting from training models to getting them to answer real-world queries, a process known as inference. McKinsey, a consultancy, estimates that by the end of the decade inference will account for three-fifths of demand in AI data centres. Nvidia appears to recognise the shift. On March 16th it unveiled a new chip designed specifically for inference tasks, the Groq 3 LPX, with an architecture that departs from the traditional GPU.

This time, it will have plenty of competition. A crop of startups is building chips aimed at running AI models faster and more efficiently than Nvidia’s.

Training and inference place different demands on hardware. Training, in which an AI model is taught to identify patterns in vast amounts of raw data, relies on enormous numbers of calculations being conducted in parallel. Nvidia’s B200 chip, for instance, one of the company’s flagship products, contains more than 16,000 processing units, also known as cores, to perform such operations.

Inference, in which a finished model calls on its training to respond to user prompts, works differently. It unfolds in two stages: prefill and decode. During prefill, the model processes the prompt and converts it into small units of text, typically about four characters in English, known as tokens. To speed things up, tokenising different parts of the query can be done in parallel. Decoding then generates the response, token by token. To do this, the model relies on its “weights” (relationships between tokens learned during training) as well as previously generated tokens. These weights are stored in the system’s memory.

The need for constant memory access is where modern GPUs fall down. AI processors like the B200 contain small but extremely fast on-chip memory, known as SRAM, as well as a much larger off-chip memory known as DRAM. Accessing DRAM can be ten times slower and consume far more energy than reading SRAM. The problem is worsening. As AI models grow larger and become better at handling long user prompts, their memory demands are rising sharply. A study by Amir Gholami of the University of California, Berkeley, and colleagues finds that over the past two decades computing performance has roughly tripled every few years, whereas off-chip memory bandwidth has improved by a factor of only about 1.6. This “memory wall” has become the main bottleneck in increasing the speed of AI inference.

GPUs rely on software workarounds to cope. One approach splits the two stages across different processors. The prefill phase runs on GPUs optimised for high parallel computing power, while decoding runs on separate GPUs designed for fast memory access. Another technique is batching, where many queries are processed together. Once the model’s weights are loaded, they can then be used for many queries at the same time, reducing repeated trips to the external memory.

Nvidia’s new chip uses the power of software to give the on-chip memory a boost. The size of the SRAM is around 500 megabytes—tiny when compared with the B200’s 192 gigabytes of off-chip memory. What makes the difference is smart software that choreographs how every piece of data moves through the chip to maximise computation and memory access.

Startups are experimenting with more radical designs. One approach is to simply build a bigger chip. That is the approach taken by Cerebras, an American chip designer. Its latest chip, the size of a dinner plate, contains an enormous 900,000 cores and 44 gigabytes of on-chip SRAM. Because all data movement occurs within the wafer, Cerebras claims its system can run inference up to 15 times faster than conventional designs. For very large models, however, storing all their parameters on SRAM is impractical.

Others are tackling the problem by redesigning how data move through the cores. MatX, a startup founded by former Google chip engineers, builds on an idea used in Google’s tensor processing units (TPUs). These chips rely on what is called a systolic array, a grid of processing elements through which data flow rhythmically, rather like blood pumped through the body. After each calculation the result passes directly to the next unit, bypassing the need to store intermediate results in memory. Traditional systolic arrays, however, are fixed in size. Make them bigger, for larger tasks, and they will often sit idle; make them smaller, and efficiency falls when the larger tasks come through. MatX proposes a “splittable” systolic array that divides the processor into several smaller grids, allocating computing resources differently depending on whether the chip is handling prefill or decode.

A third approach, pursued by d-Matrix, a California-based startup, tries to eliminate the memory wall entirely by having the same components handle both memory and computation. This architecture, known as in-memory computing, promises lower energy use and faster inference.

Others advocate chip designs built around specific algorithms to improve efficiency further. Etched, another Californian startup, is designing a chip custom-built to run transformer models, the algorithms that underpin most LLMs. This specialisation allows the company to strip away hardware needed for other uses and simplifies the software running on the chip. Researchers in China have proposed an even more radical form of specialisation: embedding model weights directly into hardware. In one design from the Chinese Academy of Sciences, these are physically encoded in the layout of metal wires. The authors claim this technique removes the need to fetch parameters from memory, enabling extreme efficiency.

Yet such specialisation carries risks. Designing a new chip typically takes 12–18 months, whereas AI algorithms evolve far faster. A chip built around today’s dominant model architecture could quickly become obsolete if the field shifts.

The chips have yet to fall. Nvidia’s rivals are at different stages. Cerebras is already on its third generation of chips; d-Matrix expects to release its first widely available version this year. Others, including MatX and Etched, remain in development. Nvidia says the Groq 3 LPX will reach the market later this year. It is easy to see that the GPU conquered training. Inferring what comes next is harder. ■

Curious about the world? To enjoy our mind-expanding science coverage, sign up to Simply Science, our weekly subscriber-only newsletter.

This article appeared in the Science & technology section of the print edition under the headline “Points of inference”

Discover stories from this section and more in the list of contents

Delivered to you every week

Well Informed

It would seem so, even for amateurs

Could it be the first to build a commercial reactor?

Those turning to them for health advice are most at risk

They can be topped up in as little time as a tank of fuel

Well Informed

The evidence is tantalising. But that is not the same as proof

Boosters say they will do everything from aiding strength, recovery and longevity
