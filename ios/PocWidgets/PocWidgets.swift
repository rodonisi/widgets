//
//  PocWidgets.swift
//  PocWidgets
//
//  Created by Simon Amitiel Rodoni on 09.05.2024.
//

import AppIntents
import SwiftUI
import WidgetKit

private let groupId = "group.com.rileytestut.AltStore.9LLQNF6L4W"

struct SelectCardIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Card"

    @Parameter(title: "Card")
    var card: CardDetail

    init(card: CardDetail) {
        self.card = card
    }

    init() {}
}

struct CardDetail: AppEntity {
    let id: String
    let name: String
    let cardPath: String

    static var defaultQuery = CardQuery()
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Card"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct CardQuery: EntityQuery {
    func entities(for identifiers: [CardDetail.ID]) async throws -> [CardDetail] {
        let data = UserDefaults.init(suiteName: groupId)
        data?.
        CardDetail.allCards.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [CardDetail] {
        CardDetail.allCards
    }

    func defaultResult() async -> CardDetail? {
        try? await suggestedEntities().first
    }
}

struct CardEntry: TimelineEntry {
    let date: Date
    let detail: CardDetail
}

struct CardDetailProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CardEntry {
        CardEntry(date: .now, detail: CardDetail(id: "id", name: "name", cardPath: "path"))
    }

    func snapshot(for configuration: SelectCardIntent, in context: Context) async -> CardEntry {
        CardEntry(date: .now, detail: configuration.card)
    }

    func timeline(for configuration: SelectCardIntent, in context: Context) async -> Timeline<CardEntry> {
        let entry = CardEntry(date: Date(), detail: configuration.card)
        let timeline = Timeline(entries: [entry], policy: .never)
        return timeline
    }
}

struct CardEntryView: View {
    var entry: CardDetailProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("name:")
            Text(entry.detail.name)

            Text("id:")
            Text(entry.detail.id)
        }
    }
}

struct PocWidgets: Widget {
    let kind: String = "PocWidgets"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectCardIntent.self, provider: CardDetailProvider()) { entry in
            CardEntryView(entry: entry)
        }
        .configurationDisplayName("Cards")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    PocWidgets()
} timeline: {
    CardEntry(date: .now, detail: CardDetail(id: "0", name: "Name", cardPath: "path"))
}
