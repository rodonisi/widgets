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

struct CardDetail: AppEntity, Codable {
    let id: Int
    let name: String
    let content: String

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
        let data = UserDefaults(suiteName: groupId)?.string(forKey: "cards") ?? ""
        let decoder = JSONDecoder()
        let details = try? decoder.decode([CardDetail].self, from: data.data(using: .utf8)!)

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
        CardEntry(date: .now, detail: CardDetail(id: 0, name: "name", content: "path"))
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

    @Environment(\.widgetFamily) var family

    var CardImage: some View {
        if let uiImage = UIImage(contentsOfFile: entry.detail.content) {
            let image = Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
            return AnyView(image)
        }
        print("The image file could not be loaded")
        return AnyView(EmptyView())
    }

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                CardImage
                    .scaledToFill()
                Text(entry.detail.name)
            }.containerBackground(for: .widget) { Color.white }
        case .systemMedium:
            GeometryReader { geometry in
                HStack {
                    CardImage
                        .frame(height: geometry.size.height)
                    VStack(alignment: .center, spacing: 8) {
                        Text("ID: \(entry.detail.id)")
                        Text(entry.detail.name)
                    }.frame(maxWidth: .infinity)
                }
                .scaledToFill()
                .containerBackground(for: .widget) { Color.white }
            }
        default:
            EmptyView()
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    PocWidgets()
} timeline: {
    CardEntry(date: .now, detail: CardDetail(id: 0, name: "Name", content: "path"))
}

#Preview(as: .systemMedium) {
    PocWidgets()
} timeline: {
    CardEntry(date: .now, detail: CardDetail(id: 0, name: "Name", content: "path"))
}
