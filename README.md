# Codex Rig

**Codex Rig** is an automated, modular, and minimalist configuration repository tailored specifically for the **Codex CLI** environment. It provisions global agent instructions, Korean UX enforcement, token-saving terse response modes (caveman), git atomic commit protocols, and a focused suite of engineering skills (Waza + local core).

---

## Features

- **Automated Symlink Setup (`install.sh`)**: One-command installation linking global instructions and engineering skills directly to `~/.codex/` and `~/.agents/skills/` with `--dry-run` preview support and orphaned symlink cleanup.
- **Global Instructions (`~/.codex/AGENTS.md`)**:
  - **Korean UX Enforcement**: Mandatory Korean responses for all user-facing explanations, plans, and reviews, while preserving technical symbols, code blocks, and logs in English.
  - **Using-Superpowers Mandate**: Anti-rationalization gate enforcing proactive skill execution (`/think`, `/hunt`, `/check`, etc.) before code is written.
  - **Caveman Mode**: Terse, high-density, token-saving communication without conversational fluff.
  - **Atomic Commit Protocol**: Standardized 1-line Conventional Commits upon completing verified units of work.
- **Core Engineering Skills Suite**:
  - Upstream `tw93/Waza` (`plugins/waza`): The gold-standard software engineering workflow skills.
  - Local core execution skill: `simplify` (code refactoring for clarity without changing behavior).

---

## Installation

### Preview Setup (Dry-Run)
Inspect what symlinks and plugin updates will be executed without modifying the filesystem:
```bash
./install.sh --dry-run
```

### Apply Configuration
Apply symlinks to `~/.codex/` and `~/.agents/skills/`:
```bash
./install.sh
```

---

## Available Skills (Callable via `$`)

| Category | Skill | Purpose |
| :--- | :--- | :--- |
| **Waza Suite** | `/think` | Pre-build planning, architecture design & decision validation |
| | `/hunt` | Root cause diagnosis, bug fix & regression investigation |
| | `/check` | Code review, diff inspection, release gates & project audit |
| | `/ui` | UI/UX design, visual polish & component styling |
| | `/write` | Technical documentation, release notes & copywriting |
| | `/learn` | Deep research, synthesizing material & compiling sources |
| | `/read` | Extracting web URLs & reading PDF documents |
| | `/health` | Engineering health audit & config drift check |
| **Local Tool** | `/simplify` | Refactor code for clarity and maintainability without altering behavior |

---

## References & Acknowledgements

- **[tw93/Waza](https://github.com/tw93/Waza)**: Upstream repository for core engineering workflow skills.
- **[obra/superpowers](https://github.com/obra/superpowers)**: Source reference for `/using-superpowers`.
- **[juliusbrussee/caveman](https://github.com/juliusbrussee/caveman)**: Source reference for `/caveman`.

---

## License

This project is licensed under the [MIT License](LICENSE).
