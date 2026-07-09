# INTENT.md — J1-PIPELINE Phase -1 (ORACLE)

**Repository:** `OneByJorah/autoresearch`
**Analysis Date:** 2026-07-05
**Analyst:** J1-PIPELINE ORACLE (read-only)
**Status:** Intent Reconstructed

---

## What This System Does

**autoresearch** is an autonomous LLM pretraining research framework. It gives an AI agent (Claude, Codex, etc.) a minimal, single-GPU training setup and lets it experiment autonomously — modifying code, training for a fixed 5-minute budget, measuring validation bits-per-byte (val_bpb), and iterating indefinitely.

### Technical Architecture

The system is deliberately minimal — three files that matter:

| File | Role | Modifiable? |
|------|------|-------------|
| `prepare.py` | Fixed constants, data download (climbmix-400b-shuffle from HuggingFace), BPE tokenizer training (rustbpe), dataloader with BOS-aligned best-fit packing, evaluation harness (`evaluate_bpb`) | **No** — read-only |
| `train.py` | Full GPT model (12-layer, 768-dim, 6-head transformer with Flash Attention 3, RoPE, Value Embeddings/ResFormer, sliding window attention), Muon+AdamW optimizer, training loop with time-budget scheduling | **Yes** — agent edits this |
| `program.md` | Agent instructions — defines the experiment loop, constraints, output format, and logging protocol | **Yes** — human edits this |

**Supporting files:**
- `analysis.ipynb` — Jupyter notebook for post-hoc analysis of experiment results from `results.tsv`
- `progress.png` — teaser visualization of experiment progress over time
- `pyproject.toml` — Python dependencies (PyTorch 2.9.1 CUDA 128, numpy, matplotlib, rustbpe, tiktoken, kernels)
- `.python-version` — Python 3.10

### Operational Role

The system operates as an **autonomous overnight research pipeline**:

1. Human sets up the repo, runs `prepare.py` once to download data and train a tokenizer
2. Human points an AI agent at the repo with `program.md` as instructions
3. Agent enters an infinite loop:
   - Reads current state → hacks `train.py` with an experimental idea → commits → runs `uv run train.py` (5 min) → reads val_bpb → if improved, keeps the commit; if not, resets → logs to `results.tsv` → repeats
4. Human wakes up to ~100 experiments completed overnight, with a log of what worked and what didn't

The single metric is **val_bpb** (validation bits per byte) — vocab-size-independent, so architectural changes are fairly compared. The fixed 5-minute time budget means ~12 experiments/hour regardless of compute platform.

---

## Why This Was Built

### Real Problem

Traditional ML research is bottlenecked by human time and attention. A researcher can run maybe 3-5 experiments per day manually — each requiring code changes, launching training, waiting for results, analyzing, and deciding what to try next. The vast majority of the search space (hyperparameters, architectures, optimizer variants) goes unexplored because humans are too slow to cover it.

The deeper problem: **the researcher's cognitive loop is the bottleneck, not the compute.** GPUs can train models 24/7, but the human who decides *what* to try next sleeps, eats, and has other obligations. The gap between compute availability and human decision-making throughput is enormous.

### Why Existing Tools Were Insufficient

- **Hyperparameter optimization (Optuna, Ray Tune, etc.)**: These search a predefined parameter space. They cannot invent new architectures, change the optimizer, or make creative leaps. They optimize within a fixed box.
- **AutoML (NAS, etc.)**: Heavyweight, distributed, requires significant infrastructure. Not something you spin up in a single file on one GPU.
- **Manual research**: The standard approach — human writes code, runs experiment, analyzes, repeats. Maxes out at ~3-5 experiments/day. The human is the serial bottleneck.
- **Existing agent frameworks (AutoGPT, etc.)**: General-purpose, not specialized for ML training loops. They lack the tight feedback cycle (5-minute experiments, immediate metric comparison, git-based state management) that makes this efficient.

What was needed: a **tight, minimal loop** where an LLM agent acts as the researcher — making creative decisions about architecture and hyperparameters, running experiments, evaluating results, and iterating — all without human intervention. The key insight is that LLMs are good at the *creative decision-making* part of research, and the 5-minute training budget makes the feedback cycle fast enough for meaningful overnight progress.

### What Triggered Development

The original repo was created by **Andrej Karpathy** (March 2026) as a demonstration of autonomous AI research. The initial commit message was simply "initial commit" — the purest statement of intent was the README's opening quote:

> *"One day, frontier AI research used to be done by meat computers in between eating, sleeping, having other fun... Research is now entirely the domain of autonomous swarms of AI agents running across compute cluster megastructures in the skies... This repo is the story of how it all began."*

The **OneByJorah fork** was created to:
1. **Adopt and maintain** this project within the JorahOne ecosystem
2. **Harden** the repo with security auditing, CI/CD (CodeQL), Dependabot, and community standards
3. **Standardize** across the JorahOne portfolio (ruff auto-fixes, portfolio-standard community files)
4. **Enable** JorahOne's own autonomous research workflows using this framework

The security audit commit (`8ad4f0e audit(autoresearch): sanitize email references`) and the portfolio standardization commit (`dc684c4 Apply ruff auto-fixes and portfolio standardization`) show the fork's focus on production-quality governance.

### Ecosystem Fit

```
JorahOne Ecosystem
├── Infrastructure & Deployment
├── Security & Monitoring
├── AI/LLM Tooling
│   ├── Hermes Agent (autonomous AI assistant)
│   ├── ... (other AI repos)
│   └── autoresearch ← HERE
└── Developer Tooling
```

autoresearch fits as an **AI/LLM research automation tool** within the JorahOne portfolio. It complements Hermes Agent by providing a specialized framework for autonomous ML experimentation — a domain-specific research loop rather than a general-purpose agent.

---

## Operational Classification

**Classification: EXPERIMENTAL**

Evidence:
- **Self-described**: README calls it "an experiment" and "autonomous pretraining research swarm"
- **No production deployment**: No Dockerfile, no compose file, no health checks, no service configuration
- **Single-GPU only**: Designed for one-off research runs, not production serving
- **No monitoring/observability**: No logging infrastructure beyond stdout and `results.tsv`
- **No backup/recovery**: No state persistence beyond git commits
- **No versioned releases**: No tags, no semantic versioning
- **CI/CD present but minimal**: CodeQL workflow only (no test runner, no build pipeline)
- **Community files present**: CODE_OF_CONDUCT, CONTRIBUTING, SECURITY, issue/PR templates — these are JorahOne portfolio standards, not evidence of production readiness
- **MIT License**: Permissive open-source, consistent with research/experimental projects
- **Security audit in history**: `8ad4f0e` — positive maturity signal for a fork, but the system itself remains experimental

---

## Key Architectural Decisions

1. **Single file to modify (`train.py`)** — Keeps scope manageable, diffs reviewable, and the agent's attention focused. The agent never touches `prepare.py` (fixed evaluation) or `program.md` (human's instructions).

2. **Fixed 5-minute time budget** — Makes experiments directly comparable regardless of what the agent changes (model size, batch size, architecture). ~12 experiments/hour, ~100 experiments overnight. The downside: results aren't comparable across different compute platforms.

3. **val_bpb as the single metric** — Bits per byte is vocab-size-independent, so architectural changes (different vocab sizes, tokenizers) are fairly compared. The evaluation harness in `prepare.py` is explicitly read-only to prevent metric manipulation.

4. **Git-based state management** — Each experiment is a git commit. If val_bpb improves, the commit stays (branch advances). If not, `git reset` discards it. This gives a clean, auditable history of what worked.

5. **Muon + AdamW hybrid optimizer** — Muon (Newton-Schulz-based orthogonalization) for 2D matrix parameters, AdamW for embeddings, scalars, and unembedding. This is a state-of-the-art optimizer combination for LLM pretraining.

6. **Self-contained, no distributed training** — One GPU, one file, one metric. No complex configs, no distributed infrastructure. This is intentional — the goal is to make the agent's job as simple as possible.

7. **BOS-aligned best-fit packing dataloader** — 100% utilization (no padding). Documents are packed into sequences using best-fit bin packing, with BOS tokens prepended. This maximizes training efficiency.

8. **Flash Attention 3 with Hopper detection** — Auto-selects between `varunneal/flash-attention-3` (Hopper GPUs) and `kernels-community/flash-attn3` (non-Hopper) based on CUDA capability. Graceful fallback for different GPU generations.

---

## Repository Structure

```
autoresearch/
├── prepare.py              # Fixed data prep + runtime utilities (read-only)
├── train.py                # GPT model + optimizer + training loop (agent edits)
├── program.md              # Agent instructions (human edits)
├── analysis.ipynb          # Jupyter notebook for experiment analysis
├── progress.png            # Teaser visualization
├── pyproject.toml          # Python dependencies
├── .python-version         # Python 3.10
├── .gitignore              # Git ignore rules
├── LICENSE                 # MIT License
├── CODE_OF_CONDUCT.md      # Contributor Covenant v2.1
├── CONTRIBUTING.md         # Contribution guidelines
├── SECURITY.md             # Security policy (90-day disclosure)
├── INTENT.md               # ← This file (Phase -1 output)
├── uv.lock                 # Lock file (uv package manager)
└── .github/
    ├── workflows/
    │   └── codeql.yml      # CodeQL security analysis (weekly + push/PR)
    ├── dependabot.yml      # Dependabot for pip, npm, docker, github-actions
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.md
    │   └── feature_request.md
    └── PULL_REQUEST_TEMPLATE.md
```

---

## Notes

- **Fork relationship**: This is a fork of `karpathy/autoresearch` (upstream). The OneByJorah fork adds security hardening, CI/CD, community standards, and portfolio standardization on top of the original.
- **Dependabot ecosystem mismatch**: Dependabot is configured for `npm` and `docker` ecosystems, but there is no `package.json` or `Dockerfile` in the repo. This is a template vestige from the JorahOne portfolio standard — should be cleaned up.
- **No test files**: No `tests/` directory, no test scripts, no smoke tests. The only verification is the training loop's fast-fail check (NaN/loss explosion detection).
- **No docs/ directory**: No dedicated documentation folder. All documentation lives in the README, program.md, and inline code comments.
- **39 commits total** in the fork's history. Initial commit by karpathy, followed by JorahOne portfolio standardization, security audit, dependabot bumps, and community file additions.
- **Security audit present**: Commit `8ad4f0e` ("audit(autoresearch): sanitize email references") — positive maturity signal.
- **No Dockerfile**: Despite being a training framework that requires a GPU, there's no containerized deployment path. The assumption is bare-metal or user-managed GPU environment.
- **No j1.yaml**: This repo does not yet have a J1-REGISTRY configuration file. This would be created in Phase 0.
