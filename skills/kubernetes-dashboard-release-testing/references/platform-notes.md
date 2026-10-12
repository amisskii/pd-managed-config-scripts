# Linux and Windows platform notes

## Common behavior

Kubernetes assertions and Dashboard interactions are identical to macOS. Keep
fixture names, Red Hat UBI images, namespace selection, and expected UI behavior
the same. Platform differences affect only bootstrap and tool paths.

## Linux

- Confirm that the container runtime and Kind are available to the same user
  that runs Podman Desktop and `kubectl`.
- For containerized test runs, use the project `e2e-container` skill. Do not
  treat a container-only kubeconfig as the Podman Desktop kubeconfig.
- Validate host-port availability before a port-forward or Ingress check.

## Windows

- Use PowerShell paths for kubeconfig and quote paths containing spaces.
- Ensure `kind`, `kubectl`, and the container runtime resolve in the same
  user session that launches Podman Desktop.
- Use the Dashboard's displayed local port or URL for forwarding checks rather
  than Unix-specific `curl` assumptions.
- Keep temporary kubeconfigs outside synchronized folders and restore the
  original preference afterward.

## Escalation checklist

Stop and report an unmet prerequisite rather than inventing a passing result
when:

- fewer than three nodes are Ready for placement validation;
- required Metrics Server, Contour, Gateway API, or storage provisioning is
  absent;
- the current user lacks the required cluster-scoped permission; or
- the Desktop context differs from the `kubectl` context.

Diagnose with `kubectl` and state the exact missing command or configuration.
