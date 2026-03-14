# EulerLiveExampleApp

This example app is now included as a real Xcode project.

Open

`Examples/EulerLiveExampleApp/EulerLiveExampleApp.xcodeproj`

The app is a payload inspection harness for EulerLiveKit.
Each inbound message carries

- event name
- raw payload
- decoded typed event when available
- decode outcome
- receive timestamp

The example app uses `https://euler-token-worker.swiftui-euler-api-key.workers.dev/token` by default. Enter a TikTok uniqueId, connect, and inspect live Euler payloads safely.
