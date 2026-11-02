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
- **[`meshstack-cli`](https://github.com/meshcloud/meshstack-cli/blob/main/skills/meshstack-cli/SKILL.md)**
  — query meshStack, follow runs and order building blocks with the `meshstack` CLI. It lives in
  the CLI repository; keep a sibling checkout at `../meshstack-cli`.

## What differs here

- **meshStack endpoint** is `https://api.try.meshstack.io`.
- **Deployments run from a developer machine.** `source setup-env.sh` (Vault secret
  `concourse/meshstack-dev/trial-cloudfoundation`) exports every key in that secret; CI has none of
  them.
- **The meshstack provider logs in with your meshstack CLI profile.** Units set only `endpoint`
  and `workspace`, so the provider uses the profile whose endpoint is
  `https://api.try.meshstack.io` (`meshstack login --endpoint https://api.try.meshstack.io`). Your
  user needs a role in the unit's workspace, mostly `meshcloud`. A login acts with admin rights only
  in `cloudfoundation-admin`; in `meshcloud` meshStack drops a restricted tag such as `Company` that
  an object does not carry yet, so set it once with `--workspace cloudfoundation-admin`. Do not
  export `MESHSTACK_API_KEY` or `MESHSTACK_API_SECRET` locally: an API key wins over the profile.
  Exceptions: the `ske` units read their API key from `MESHSTACK_STARTER_KIT_API_KEY_*`, and the AKS
  `connector` and `github-repo` units from `MESHSTACK_API_SECRET_AKS_IDP`, because their hub modules
  pin provider `~> 0.20.0`, which predates profiles.
- **CI runs smoke tests only.** `.github/workflows/smoke-test.yml` mirrors likvid's: it selects
  units by the `smoke.hcl` include, so a new smoke test needs no CI change. The tests use one
  secret, the `smoke-test` environment's `MESHSTACK_API_SECRET` — the environment is named for the
  job, not for the foundation, because the deployment credentials are not in Actions at all.
