# Agent Instructions — trial-cloudfoundation

The cloud foundation IaC behind <https://try.meshstack.io>, the meshStack trial instance. A
Terragrunt monorepo under `foundations/meshstack-trial/`.

It is a **different meshStack** from the one
[likvid-bank/likvid-cloudfoundation](https://github.com/likvid-bank/likvid-cloudfoundation) targets
— its own instance, cloud accounts and Vault credentials — but it follows the same conventions, and
those are documented once, publicly, over there. Read them there instead of re-deriving them here;
keep a sibling checkout at `../likvid-cloudfoundation`.

- **[`AGENTS.md`](https://github.com/likvid-bank/likvid-cloudfoundation/blob/main/AGENTS.md)** —
  conventions: Terragrunt + OpenTofu, hub modules pinned by Git ref, the nix devShell.
- **[`.agents/skills/foundation-modules`](https://github.com/likvid-bank/likvid-cloudfoundation/blob/main/.agents/skills/foundation-modules/SKILL.md)**
  — run, plan, apply and upgrade units; credential and provider errors.
- **[`.agents/skills/hub`](https://github.com/likvid-bank/likvid-cloudfoundation/blob/main/.agents/skills/hub/SKILL.md)**
  — consume [meshstack-hub](https://github.com/meshcloud/meshstack-hub) modules as deployed building
  blocks, and the foundation e2e smoke-test protocol.

## What differs here

- **meshStack endpoint** is `https://api.try.meshstack.io`.
- **Credentials** come from `source setup-env.sh` (Vault secret
  `concourse/meshstack-dev/trial-cloudfoundation`), which exports every key in that secret. The
  `ske` units read the meshStack API key **id** from `MESHSTACK_STARTER_KIT_API_KEY_ID` rather than
  committing it, unlike the rest of this repo and all of likvid — an inconsistency, not a
  requirement; a key id is not a secret.
- **No CI.** Everything, smoke tests included, runs from a developer machine. When this repo gets
  CI, likvid's `.github/workflows/smoke-test.yml` selects smoke tests by the `smoke.hcl` include, so
  cloning it needs no per-case wiring here.
