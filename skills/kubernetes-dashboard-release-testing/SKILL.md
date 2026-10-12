---
name: kubernetes-dashboard-release-testing
description: Validate a Kubernetes Dashboard extension release across macOS, Linux, or Windows using a disposable multi-node Kind cluster, the scenario documentation, and the shared Google Sheet tracker. Use when reproducing or completing the cross-platform Dashboard test matrix.
---

# Kubernetes Dashboard release testing

Run the complete, meaningful release workflow for the Kubernetes Dashboard
extension. Treat the shared tracker as the execution record, and treat the
scenario documents as the source of fixtures and detailed manual steps.

The work is not complete until every in-scope tracker row has a recorded
outcome or a specific prerequisite-based block.

## Inputs and discovery

Before changing the cluster or tracker, locate:

- the target tracker sheet and the column for the current operating system;
- the scenario repository/branch containing `docs/scenarios/kubernetes-dashboard/`;
- `docs/cluster-test-prerequisites.md` and
  `docs/scenarios/kubernetes-dashboard/setup/README.md`;
- the Kind configuration used for release tests; and
- a running Podman Desktop instance with the Kubernetes Dashboard and
  Kubernetes Contexts extensions installed.

Read [the execution plan](references/execution-plan.md) and
[row-by-row execution](references/row-by-row-execution.md) before starting.
Read [platform notes](references/platform-notes.md) only for Linux or Windows.

## Operating rules

- Start with a fresh or explicitly isolated test environment. Use only the
  `test-*` namespaces and resource names defined by the scenarios.
- Create a multi-node Kind cluster before validating node placement, DaemonSet,
  scheduling, storage, or routing behavior. Do not mark those cases passed on
  a single-node cluster.
- Use the embedded YAML in the scenario document or Apply YAML when the
  workflow calls for it. Do not substitute a generic fixture, arbitrary image,
  or production resource.
- Verify the user-visible Dashboard result, not merely `kubectl` state. Use
  `kubectl` to bootstrap, assert prerequisites, and diagnose discrepancies.
- Select the dedicated namespace in the Dashboard before judging a namespaced
  resource. A missing resource in `default` is not a functional failure.
- For each row, mark only the active OS column after its stated expected result
  is reproduced. Record `FAILED` for a reproducible product mismatch and
  `BLOCKED` only for a documented unsatisfied prerequisite. Never overwrite
  results in the other OS columns.
- Keep the tracker actionable: short setup/action/observable outcome in the
  row; full YAML, rationale, and cleanup in the linked scenario document.
- Restore the original kubeconfig/context after compatibility or restricted-RBAC
  checks. Ask for confirmation immediately before importing/uploading a token
  kubeconfig or deleting data through the UI.
- Do not silently skip a row because a related scenario passed. Execute the
  action and observation stated in that row, using its linked workflow section.
  If the row lacks a link or is unclear, resolve the matching scenario document
  before executing it and report the documentation gap.

## Execution order

1. Prepare the cluster and prerequisites.
2. Confirm installation, connection, dashboard, and multi-node inventory.
3. For every in-scope row, follow the linked scenario steps, capture its
   Dashboard observation, and record the result before moving on.
4. Run compute, then configuration, networking, storage, access control,
   namespace, and compatibility workflows in order.
5. Perform a focused bug-discovery pass for each workflow before cleanup.
6. Remove disposable fixtures and restore the initial Podman Desktop context.
7. Audit the active OS column: no `Not tested` rows should remain unless a row
   is intentionally outside the agreed release scope.

## Documentation maintenance

When a scenario fixture itself is incompatible with the current cluster or
runtime, diagnose it using the dedicated test resource. Correct the scenario
document only after reproducing the fix, keep names/images consistent with the
existing fixtures, and update the linked PR when authorized. Do not modify
unrelated documentation or tracker sections.
