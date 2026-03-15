
# EulerLiveKit

EulerLiveKit is a Swift package for SwiftUI apps that want a clean, typed client for Euler Stream TikTok LIVE events.

The package handles three responsibilities.

• request short-lived websocket credentials from a backend  
• open and manage the websocket connection  
• convert raw payloads into typed Swift models while preserving the original payload for debugging

The goal is a SwiftUI-friendly interface for TikTok LIVE event streams.

---

## Installation

Add the package with Swift Package Manager.

.package(url: "https://github.com/JalilK/SwiftUIEulerLiveKit.git", from: "0.1.0")

---

## Architecture

SwiftUI App  
→ EulerLiveClient  
→ TokenProvider  
→ Backend Token Route  
→ Euler Stream WebSocket  
→ Event Decoder  
→ Typed Event Models + Debug Records

---

## Core Types

EulerLiveConfiguration  
Defines token endpoint and limits.

EulerTokenProvider  
Protocol responsible for retrieving websocket credentials.

BackendTokenService  
Default implementation that calls your backend.

EulerLiveClient  
Main entry point for connecting to a stream and receiving events.

EulerDebugEventRecord  
Canonical event representation containing

event name  
raw payload  
typed event model  
decode outcome  
timestamp

---

## Security Boundary

Euler API keys must never ship in the client.

The mobile app requests a short-lived JWT from a backend token service.

The backend signs the JWT and returns a websocket URL.

---

## Development

Clone and run tests.

git clone https://github.com/JalilK/SwiftUIEulerLiveKit.git
cd SwiftUIEulerLiveKit
swift test

---

## Repository Structure

Sources/EulerLiveKit  
Tests/EulerLiveKitTests  
Examples/EulerLiveExampleApp

---

## Purpose

This package exists to make building TikTok LIVE driven SwiftUI applications straightforward while keeping security boundaries clean and debugging visibility high.
