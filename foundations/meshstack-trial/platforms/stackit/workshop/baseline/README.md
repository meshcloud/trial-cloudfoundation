# Workshop Baseline

Trainers run this OpenTofu module next to [`../sandboxes`](../sandboxes) to deploy the same
resources into every sandbox's STACKIT project. Like the sandboxes module, it needs only the
trainer's **Workspace Owner** role.

The baseline is a draft building block definition owned by the workshop workspace. Its runs reach
STACKIT through workload identity federation, so no key is stored anywhere. In each sandbox, the
module orders:

1. **STACKIT Service Account**: a service account in the sandbox project.
2. **STACKIT Service Account Federation**: lets runs of the baseline definition act as that account.
3. **Workshop Baseline**: the baseline itself, as a child of the federation.

The first two are definitions the platform team publishes, because they need STACKIT organization
access.

## Usage

Add to the `main.tf` of the sandboxes module's usage:

```hcl
module "baseline" {
  source = "git::https://github.com/meshcloud/trial-cloudfoundation.git//foundations/meshstack-trial/platforms/stackit/workshop/baseline?ref=main"

  workspace_identifier = "my-workshop-ab12cd34"
  sandboxes            = module.sandboxes.sandboxes

  # Your own Terraform code. Leave this out to deploy the example in ./buildingblock.
  implementation = {
    repository_url  = "https://github.com/my-org/workshop-baseline.git"
    repository_path = "."
    ref_name        = "main"
  }
}
```

The provider in your code signs in from the environment, so declare it without credentials:

```hcl
provider "stackit" {}
```

Pin `ref_name` to a commit. Bumping it changes the draft definition, so the next `tofu apply` re-runs
the baseline in every sandbox. A new commit on a branch alone triggers no run.
