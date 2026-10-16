# Workshop Sandboxes

Trainers run this OpenTofu module with their own meshStack login to prepare a STACKIT workshop. It
adds sandboxes to a workshop workspace that the STACKIT University workspace starterkit created. A
sandbox is a meshProject with a STACKIT sandbox project.

It is not a Terragrunt unit of this foundation: we never apply it. It needs no permissions beyond
the trainer's **Workspace Owner** role and no STACKIT organization access.

## Workflow

1. Set `sandbox_count` (1–30) and apply ahead of the workshop. A STACKIT project takes a few minutes
   to provision.
2. In meshPanel, invite each participant to the workshop workspace. The invite dialog asks which
   project to grant: pick their sandbox with **Project Admin**, which makes them owner of its
   STACKIT project.

## Usage

Requires `tofu`, and the [meshStack CLI](https://github.com/meshcloud/meshstack-cli) to log in.

```bash
meshstack login -p try --endpoint https://api.try.meshstack.io
```

Pick the workshop workspace when asked. Then write a `main.tf`:

```hcl
terraform {
  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
    }
  }
}

provider "meshstack" {
  profile   = "try"
  workspace = "my-workshop-ab12cd34"
}

module "sandboxes" {
  source = "git::https://github.com/meshcloud/trial-cloudfoundation.git//foundations/meshstack-trial/platforms/stackit/workshop/sandboxes?ref=main"

  workspace_identifier = "my-workshop-ab12cd34"
  sandbox_count        = 20
}

output "sandboxes" {
  value = module.sandboxes.sandboxes
}
```

```bash
tofu init && tofu apply
```

Keep the `terraform.tfstate` file this creates. The next apply needs it.

## After the workshop

Run `tofu destroy` before the workshop workspace expires. The workspace starterkit cannot delete a
workspace that still holds these projects.
