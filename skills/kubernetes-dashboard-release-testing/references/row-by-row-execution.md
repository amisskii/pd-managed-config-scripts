# Row-by-row execution and bug discovery

## Treat the tracker as an executable checklist

Work in tracker order. For each in-scope test case:

1. Open the row's linked scenario heading. If its link targets a workflow rather
   than an exact heading, find the subsection covering that resource/action.
2. Read the row's setup, action, and expected result together with the linked
   steps. Apply exactly the embedded YAML and use the named namespace.
3. Perform the described action in Podman Desktop. Use `kubectl` only to
   prepare fixtures, verify prerequisites, or diagnose a Dashboard mismatch.
4. Compare the visible result with the row's expected result and update only
   the active platform status.
5. Keep the fixture until every later row in that workflow that depends on it
   has executed. Then use the scenario cleanup.

Do not reduce a workflow to a resource-existence check. A row that asks for
recovery, traffic, scheduling, patching, logs, a disabled control, or an
authorization outcome requires that observable behavior.

## Required status outcomes

Use a concrete outcome for each row:

- `PASSED`: all stated setup, action, and Dashboard observation occurred.
- `FAILED`: the cluster prerequisite is satisfied, but the Dashboard behavior
  differs from the expected result. Preserve evidence and leave the fixture
  when it is useful for reproduction.
- `BLOCKED`: a named prerequisite is absent or cannot be configured. Record
  the missing capability and the verification command/result.
- `Not applicable`: only when the row is explicitly outside the release
  platform or product scope; state why.

## Focused bug-discovery pass

After the expected path passes, probe one meaningful boundary for the workflow.
Do not mutate production resources; use the disposable `test-*` fixture.
Prioritize boundaries exposed by the Dashboard:

| Workflow type | Probe after the happy path |
| --- | --- |
| List and details | Refresh, switch away and back, and confirm the new state is neither stale nor duplicated. |
| Namespaced resource | Change namespace and confirm the resource is scoped correctly. |
| Controller | Delete or change the supported child/setting and confirm reconciliation and UI refresh. |
| Config dependency | Remove/invalidates the test dependency, observe failure, then restore it and observe recovery. |
| Networking | Confirm both the resource relationship and real traffic or port-forward behavior. |
| RBAC/context | Switch to the restricted or alternate context, confirm the limited state, then restore the original context. |
| Create, edit, delete action | Check form validation, confirmation/cancel behavior, success state, and a single refresh. |

Record a defect candidate when a reproducible mismatch exists: affected
platform, Dashboard page/resource, minimal actions, expected versus actual
result, and any visible error. Do not mark a row passed merely because
`kubectl` succeeds when Podman Desktop presents stale, incorrect, unsafe, or
missing behavior.

## Final coverage audit

Before declaring the run complete, scan the active platform column from the
first section through Compatibility:

- every in-scope row has a status;
- each `FAILED` or `BLOCKED` row has a precise reason;
- every linked workflow was opened and its cleanup run;
- all temporary contexts have been restored; and
- test namespaces, port forwards, and other disposable resources are removed.
