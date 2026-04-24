# Security policy

## Reporting security issues

If you find a security problem in this skill, such as instructions that could leak secrets or encourage unsafe destructive debugging, please report it privately to the repository maintainer before public disclosure.

## Safety principles for this skill

This skill should never instruct the assistant to:

- print secrets, tokens, passwords, cookies, private keys, credentials, signing identities, or full environment dumps
- run destructive commands against production data without explicit approval and safe scoping
- hide uncertainty or claim a fix without verification
- make broad code/configuration changes before root-cause investigation

Diagnostic examples should use presence/absence, counts, lengths, types, or redacted fingerprints instead of sensitive values.
