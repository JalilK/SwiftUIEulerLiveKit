# EulerLiveKit

EulerLiveKit is a Swift package for connecting iOS and SwiftUI apps to Euler Stream TikTok LIVE WebSocket events through a backend-issued JWT.

This checkpoint adds a debug event record path across the package so every inbound message can carry

- event name
- raw payload
- decoded typed event when available
- decode outcome
- receive timestamp

## What changed in this iteration

- Added `EulerDebugEventRecord` as the canonical debug surface for inbound messages.
- Added `EulerDecodeOutcome` to classify decode results.
- Updated the event decoder to preserve the original raw payload for every message.
- Updated the session and client layers to store `EulerDebugEventRecord` history.
- Updated the example app to inspect full raw payloads on device.
- Added tests for raw payload retention and decoder classification.

## Euler constraints carried forward

- JWT signing remains on the backend.
- Euler API keys stay off the client.
- The package remains general purpose rather than app specific.

## Backend contract

Your backend should expose `POST /token` and return JSON in this shape.

```json
{
  "creator": "thatgirldollar",
  "jwtKey": "token_here",
  "websocketURL": "wss://ws.eulerstream.com?uniqueId=thatgirldollar&jwtKey=token_here",
  "expiresInSeconds": 60,
  "strategy": "optional"
}
```

## Quick start

```swift
import EulerLiveKit

let configuration = EulerLiveConfiguration(
    backendBaseURL: URL(string: "https://euler-token-worker.swiftui-euler-api-key.workers.dev")!
)
let tokenProvider = BackendTokenService(configuration: configuration)
let client = EulerLiveClient(
    configuration: configuration,
    tokenProvider: tokenProvider
)

client.onStatusChange = { status in
    print("status", status)
}

client.onEventRecord = { record in
    EulerConsolePayloadPrinter.printLogBlock(for: record)
}

Task {
    try await client.connect(to: "thatgirldollar")
}
```

## Run tests

```bash
swift test
```

## Example app

The example app now includes a real Xcode project at `Examples/EulerLiveExampleApp/EulerLiveExampleApp.xcodeproj`. Open that project in Xcode to run the payload inspection harness against the deployed Cloudflare Worker token route.

## Concrete event models

SwiftUIEulerLiveKit now models the following live payload families as concrete native types.

### Stable models

- `room_info`
- `member`
- `gift`
- `like`
- `chat`
- `follow`
- `share`
- `room_user`
- `live_intro`
- `room_message`
- `caption_message`
- `barrage`
- `link_mic_fan_ticket_method`
- `link_mic_armies`
- `goal_update`
- `link_mic_method`
- `in_room_banner`
- `link_layer`

## Schema discovery workflow

The example app now has first-pass modeling for goal updates, link mic method summaries, in-room banner ranking payloads, and link-layer participant graph updates.

Unknown logging can stay focused on payloads that still have no reliable public model.
