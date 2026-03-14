# Changelog

## 2026-03-13

- added `EulerDebugEventRecord` and `EulerDecodeOutcome`
- preserved raw payloads for every inbound event
- updated session history to store debug records instead of event summaries only
- updated the example app to inspect full payloads on device
- added decoder tests for known unknown and invalid payload paths
