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
- **Deployments run from a developer machine.** `source setup-env.sh` (Vault secret
  `concourse/meshstack-dev/trial-cloudfoundation`) exports every key in that secret; CI has none of
  them. The `ske` deployment units read even the meshStack API key **id** from
  `MESHSTACK_STARTER_KIT_API_KEY_ID` rather than committing it, unlike the rest of this repo — an
  inconsistency, not a requirement, since a key id is not a secret.
- **CI runs smoke tests only.** `.github/workflows/smoke-test.yml` mirrors likvid's: it selects
  units by the `smoke.hcl` include, so a new smoke test needs no CI change. Its one secret is the
  `smoke-test` environment's `MESHSTACK_API_SECRET` — the environment is named for the job, not for
  the foundation, because the deployment credentials are not in Actions at all.
