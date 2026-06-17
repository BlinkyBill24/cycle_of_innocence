# Git hooks (versioned)

Activate once per clone:

    git config core.hooksPath .githooks

- **pre-commit** — branch guard: blocks direct commits to `main`/`master`.
  Work on `feature/ fix/ refactor/ docs/ chore/` branches; merges to main happen
  on the Forgejo web UI (or via PR), never by a local commit.
