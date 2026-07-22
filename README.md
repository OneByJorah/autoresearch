<div align="center">
  <img src="https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/PyTorch-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white">
  <img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge">
</div>

<br>

<div align="center">
  <h1>autoresearch</h1>
  <p><strong>AI-Powered Automated Research Framework</strong></p>
  <p>AI agents running research on single-GPU nanochat training automatically.</p>
  <p>
    <a href="#features">Features</a> •
    <a href="#quick-start">Quick Start</a> •
    <a href="#how-it-works">How It Works</a> •
    <a href="#contributing">Contributing</a>
  </p>
</div>

---

## Screenshot

![autoresearch Dashboard](docs/screenshot.png)
*AI agents automatically researching and optimizing nanochat training.*

## Features

- **Autonomous Research** — AI agents iteratively optimize training code.
- **Single-GPU Training** — Designed for nanochat models on single GPUs.
- **Human-in-the-Loop** — Human-managed `program.md` guides research direction.
- **Automatic Iteration** — Agents improve `train.py` automatically.
- **Experiment Logging** — Track all experiments and results.
- **Reproducible Results** — Full experiment history for reproducibility.

## Quick Start

```bash
git clone https://github.com/OneByJorah/autoresearch.git
cd autoresearch

pip install -r requirements.txt

# Configure your research program
cp program.example.md program.md
# Edit program.md with your research goals

# Start the research loop
python3 main.py
```

## How It Works

1. **Program Definition** — You define research goals in `program.md`
2. **Agent Execution** — AI agent reads the program and current code
3. **Code Generation** — Agent proposes improvements to `train.py`
4. **Training Run** — Code is executed on single GPU
5. **Evaluation** — Results are evaluated against metrics
6. **Iteration** — Agent learns from results and proposes next iteration

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENAI_API_KEY` | *(empty)* | OpenAI API key for agent |
| `GPU_DEVICE` | `cuda:0` | GPU device for training |
| `MAX_ITERATIONS` | `100` | Maximum research iterations |
| `SAVE_INTERVAL` | `10` | Checkpoint save interval |
| `LOG_DIR` | `./logs` | Experiment log directory |

## Project Structure

```
autoresearch/
├── main.py              # Research loop entry point
├── agent.py             # AI agent logic
├── train.py             # Training code (auto-improved)
├── evaluate.py          # Evaluation metrics
├── program.md           # Research program definition
├── logs/                # Experiment logs
├── checkpoints/         # Model checkpoints
├── requirements.txt     # Python dependencies
└── README.md
```

## Research Program Format

```markdown
# Research Program

## Objective
Optimize nanochat training for single-GPU deployment.

## Metrics
- Training loss < 0.1
- Inference latency < 100ms
- Model size < 500MB

## Constraints
- Single GPU (24GB VRAM max)
- Python 3.10+
- PyTorch 2.0+

## Evaluation
- Run on validation set
- Report metrics after each iteration
```

## Contributing

Contributions are welcome. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community standards.

## Security

For security concerns, see [SECURITY.md](SECURITY.md). Please report vulnerabilities to **info@jorahone.com** — do not use public issues.

## License

MIT © Jhonattan L. Jimenez

---

<div align="center">
  <p>AI-powered automated research framework.</p>
  <p><a href="https://github.com/OneByJorah">@OneByJorah</a></p>
</div>
