# Cross-platform execution plan

## 1. Cluster preparation

Follow `docs/cluster-test-prerequisites.md` and
`docs/scenarios/kubernetes-dashboard/setup/README.md` from the scenario
repository. The minimum release cluster is a disposable multi-node Kind cluster
with one control plane and at least two workers.

Verify before testing:

```sh
kubectl config current-context
kubectl get nodes
kubectl cluster-info
```

All nodes must be `Ready`. Configure prerequisites only when the dependent
workflow needs them:

| Capability | Required by |
| --- | --- |
| Metrics Server | HPA live scaling and metric assertions |
| Contour with its control-plane toleration | Ingress and Gateway routing |
| Gateway API CRDs and Contour Gateway | GatewayClass, Gateway, HTTPRoute |
| Dynamic local storage provisioner | PVC/PV consumer and reclaim workflows |
| Cluster-scoped permissions | Admission webhook and RBAC setup |

Open Podman Desktop, select the created context, and wait for the Dashboard to
show `Connected` and non-empty node metrics before continuing.

## 2. Release workflow map

Use the corresponding scenario document for full fixture and cleanup.

| Tracker section | Run this document set |
| --- | --- |
| Installation, cluster prep, Dashboard | setup README and tracker instructions |
| Nodes | `nodes/node-topology-scheduling.md` |
| Compute | `compute/*.md` |
| Config | `config/*.md` |
| Network | `network/*.md` |
| Storage | `storage/*.md` |
| Access Control | `access-control/*.md` |
| Namespaces | `namespaces/namespace-isolation-lifecycle.md` |
| Compatibility | `compatibility/kubernetes-contexts.md` and `access-control/restricted-user-rbac.md` |

For every workflow, use the embedded resource names: they are deterministic and
start with `test-`.

## 3. Evidence standard

Pass only after three layers agree:

1. Kubernetes: the API apply, update, or recovery result is expected.
2. Dashboard: the list, details, Inspect, Patch, logs, or action reflects it in
   the correct namespace.
3. Meaningful behavior: a consumer runs; a controller reconciles; traffic
   succeeds or fails; or authorization changes access.

Examples:

- ConfigMap/Secret: the consumer is Running; a missing or invalid dependency
  blocks it; restoring the dependency recovers it.
- Controller: delete an owned Pod and observe the replica, ordinal, or
  placement restored.
- Service: verify generated Endpoints and EndpointSlices, then port-forward and
  check a client response. Do not create endpoints separately.
- Admission: an accepted Pod is mutated; an invalid Pod is rejected and absent.
- Restricted user: the Dashboard is Connected, metrics show `-`, resources
  show `Not accessible`, and the original context recovers.

## 4. Tracker updates and audit

- Change only the current platform column: Linux/Fedora, Windows, or macOS.
- Prefer single-cell edits for final status; verify after saving because rows
  can contain merged cells or embedded newlines.
- Do not change an existing `FAILED` result to pass without a new successful
  reproduction.
- Audit the active OS column for unintended `Not tested` entries.

## 5. Cleanup

Delete only dedicated fixtures. For admission workflows, delete webhook
configurations before their service and namespace. For restricted-user
workflows, restore the original kubeconfig/context before removing temporary
resources. Retain prerequisites while later workflows still need them.
