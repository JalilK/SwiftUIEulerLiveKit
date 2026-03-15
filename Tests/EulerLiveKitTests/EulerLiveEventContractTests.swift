import Testing
@testable import EulerLiveKit

struct EulerLiveEventContractTests {
    @Test
    func promotedBattleTaskEventUsesStableContractText() {
        let event = EulerLiveEvent.linkMicBattleTask(
            LinkMicBattleTaskEvent(
                roomId: "1",
                battleId: "battle-1",
                messageType: 7,
                taskProgress: 90,
                fromUserUid: "user-1",
                taskResult: 1,
                rewardStartTimestamp: "123",
                rewardStartTime: 123,
                rewardMultiple: 2,
                rewardSettleAmount: 10,
                rewardStatus: 1,
                progressTarget: 100
            )
        )

        #expect(event.eventName == "link_mic_battle_task")
        #expect(event.summary.contains("battleId=battle-1"))
        #expect(event.description == "Battle bonus-task lifecycle update including start, progress, settle, and reward settlement.")
    }

    @Test
    func workerInfoEventUsesStableContractText() {
        let event = EulerLiveEvent.workerInfo(
            WorkerInfoEvent(
                webSocketId: "socket-1",
                schemaVersion: "2026-03-15",
                isLoggedIn: true,
                bundleEvents: true,
                rawMessages: false
            )
        )

        #expect(event.eventName == "worker_info")
        #expect(event.summary.contains("schema=2026-03-15"))
        #expect(event.description == "Worker-side transport metadata.")
    }

    @Test
    func transportConnectEventUsesStableContractText() {
        let event = EulerLiveEvent.transportConnect(
            TransportConnectEvent(agentId: "agent-1")
        )

        #expect(event.eventName == "tiktok.connect")
        #expect(event.summary == "tiktok.connect agentId=agent-1")
        #expect(event.description == "Transport connection bootstrap metadata.")
    }
}
