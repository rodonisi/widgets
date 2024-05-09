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

    static var allCards: [CardDetail] = []
}

struct CardQuery: EntityQuery {
    func entities(for identifiers: [CardDetail.ID]) async throws -> [CardDetail] {
        try! await suggestedEntities()
    }

    func suggestedEntities() async throws -> [CardDetail] {
        let data = UserDefaults(suiteName: groupId)
        let cards = data?.array(forKey: "cards") as? [NSDictionary]
        let details = cards?.map {
            CardDetail(
                id: String($0.value(forKey: "id") as? Int ?? 0),
                name: $0.value(forKey: "name") as? String ?? "invalid name",
                cardPath: data?.string(forKey: "card_\($0.value(forKey: "id") ?? "rip")") ?? "no path"
            )
        }
        return details ?? []
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

    var CardImage: some View {
        if let uiImage = UIImage(contentsOfFile: entry.detail.cardPath) {
            let image = Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .border(Color.red)
            return AnyView(image)
        }
        print("The image file could not be loaded")
        return AnyView(EmptyView())
    }

    var body: some View {
        CardImage
            .frame(maxWidth: .infinity)
            .border(Color.blue)
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
