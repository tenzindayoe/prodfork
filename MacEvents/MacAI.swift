//
//  MacAI.swift
//  MacEvents
//

import SwiftUI
import FoundationModels
import Speech
import AVFoundation
import MapKit

// MARK: - Local message model (kept private to avoid name clashes)
private struct AIMsg: Identifiable {
    enum Role { case user, assistant }
    enum Payload {
        case text(String)
        case event(Event)
        case map(Event)
    }

    let id = UUID()
    let role: Role
    let payload: Payload
}

// MARK: - Speech → Text
final class SpeechManager: NSObject, ObservableObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    @Published var text: String = ""

    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    func start() throws {
        stop()
        let req = SFSpeechAudioBufferRecognitionRequest()
        request = req

        let input = engine.inputNode
        task = recognizer?.recognitionTask(with: req) { [weak self] r, _ in
            guard let self, let r else { return }
            DispatchQueue.main.async { self.text = r.bestTranscription.formattedString }
        }

        let fmt = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: fmt) { [weak self] buf, _ in
            self?.request?.append(buf)
        }

        engine.prepare()
        try engine.start()
    }

    func stop() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
    }
}

// MARK: - Main View
struct MacAI: View {
    // UI
    @State private var input = ""
    @FocusState private var inputFocused: Bool
    @State private var sending = false
    @State private var messages: [AIMsg] = []

    // Data
    @State private var allEvents: [Event] = []
    @State private var idIndex: [String: Event] = [:]

    // Speech
    @StateObject private var speech = SpeechManager()
    @State private var recording = false

    // Limits
    private let maxContextEvents = 60
    private let maxEventsToShow = 5

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat log
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { msg in
                                bubble(for: msg)
                                    .id(msg.id)
                                    .padding(.horizontal)
                            }

                            if sending {
                                HStack {
                                    ProgressView()
                                    Text("Thinking…").foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation { proxy.scrollTo(messages.last?.id, anchor: .bottom) }
                    }
                }

                Divider()

                // Input bar
                HStack(spacing: 12) {
                    TextField("Message…", text: $input, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(10)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 18))
                        .focused($inputFocused)

                    Button {
                        if recording {
                            speech.stop(); recording = false
                        } else {
                            try? speech.start(); recording = true
                        }
                    } label: {
                        Image(systemName: recording ? "mic.circle.fill" : "mic.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(recording ? .red : .blue)
                    }

                    Button {
                        Task { await send() }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30, weight: .bold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                    }
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.thinMaterial)
            }
            .navigationTitle("MacAI")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture { inputFocused = false }
            .onChange(of: speech.text) { input = $0 }
            .task {
                await loadEvents()
                resetChat()
                speech.requestPermission()
            }
        }
    }

    // MARK: - UI Bubbles
    @ViewBuilder
    private func bubble(for msg: AIMsg) -> some View {
        switch msg.payload {
        case .text(let txt):
            HStack {
                if msg.role == .assistant {
                    Text(txt)
                        .padding(12)
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.primary)
                    Spacer()
                } else {
                    Spacer()
                    Text(txt)
                        .padding(12)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.white)
                }
            }

        case .event(let event):
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    EventWidget(event: event, favoriteEventIDs: .constant([]))
                }
                Spacer(minLength: 0)
            }

        case .map(let event):
            VStack(spacing: 8) {
                LocationMap(event: event)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Button {
                    openInMaps(event)
                } label: {
                    Label("Open in Maps", systemImage: "map")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - Actions
    private func resetChat() {
        messages = [
            .init(role: .assistant, payload: .text("👋 Hi, I’m Scottie AI. How can I help you today? I can tell you about the latest Macalester events."))
        ]
    }

    private func append(_ role: AIMsg.Role, _ payload: AIMsg.Payload) {
        messages.append(.init(role: role, payload: payload))
    }

    private func openInMaps(_ event: Event) {
        guard let coord = event.coord, coord.count == 2 else {
            append(.assistant, .text("I don’t have GPS coordinates for “\(event.title)”."))
            return
        }
        let c = CLLocationCoordinate2D(latitude: coord[0], longitude: coord[1])
        let placemark = MKPlacemark(coordinate: c, addressDictionary: nil)
        let item = MKMapItem(placemark: placemark)
        item.name = event.title
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    // MARK: - Send
    private func send() async {
        inputFocused = false
        if recording { speech.stop(); recording = false }

        let user = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !user.isEmpty else { return }
        append(.user, .text(user))
        input = ""

        guard #available(iOS 26.0, *) else {
            append(.assistant, .text("⚠️ On-device AI requires iOS 26 or newer."))
            return
        }

        sending = true
        do {
            let system = systemPrompt()
            let ctx = contextLines()
            let prompt = """
            \(system)

            CONTEXT_BEGIN
            DATE_NOW=\(Date().formatted(.dateTime.year().month().day().hour().minute()))
            EVENTS:
            \(ctx)
            CONTEXT_END

            USER: \(user)
            """

            let session = try LanguageModelSession()
            let reply = try await session.respond(to: prompt).content

            renderStructured(reply)
        } catch {
            append(.assistant, .text("⚠️ Error: \(error.localizedDescription)"))
        }
        sending = false
    }

    // MARK: - System prompt
    private func systemPrompt() -> String {
        """
        You are Scottie AI, a concise campus assistant. Answer using the event CONTEXT I give you.
        RULES:
        • Never invent events. Use only IDs from CONTEXT.
        • Prefer widgets over long prose.
        • If the user asks for events (today, tomorrow, upcoming, a date, or a range), pick at most \(maxEventsToShow) best matches.
        • Emit one line per widget using these exact tags (no extra text on those lines):
          EVENT: <id>         ← to render an event card
          MAP: <id>           ← to render a map for an event
          TEXT: <short text>  ← optional, 1–2 sentences max
        • Put TEXT first if you need to explain something briefly; then widget lines.
        • For “how do I get there”, choose the most relevant event and output MAP: <id>.
        • For “latest” or “upcoming”, choose the nearest future events.
        • For “today” or a specific date, filter by that day.
        • If nothing matches, output only: TEXT: I couldn’t find events for that time.

        Output must be UTF-8 plain text. Do not wrap in code fences.
        """
    }

    // MARK: - Context
    private func contextLines() -> String {
        // upcoming first, cap to keep prompt small
        let upcoming = allEvents.sorted { $0.formatDate() < $1.formatDate() }
        let slice = Array(upcoming.prefix(maxContextEvents))
        return slice.map(eventLine).joined(separator: "\n")
    }

    /// Ultra-compact line per event consumed by the model.
    /// ID|TITLE|YYYY-MM-DD|TIME|LOCATION|LAT|LON
    private func eventLine(_ e: Event) -> String {
        let d = e.formatDate()
        let ymd = d.formatted(.dateTime.year().month().day())
        let tm = (e.time ?? "").replacingOccurrences(of: "|", with: "/")
        let loc = e.location.replacingOccurrences(of: "|", with: "/")

        // Pull from coord: [Double]?  -> lat|lon (empty if missing)
        let lat: String
        let lon: String
        if let c = e.coord, c.count == 2 {
            lat = String(c[0])
            lon = String(c[1])
        } else {
            lat = ""
            lon = ""
        }

        return "\(e.id)|\(e.title)|\(ymd)|\(tm)|\(loc)|\(lat)|\(lon)"
    }

    // MARK: - Parse + Render
    private func renderStructured(_ raw: String) {
        let lines = raw
            .replacingOccurrences(of: "\r\n", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

        var textParts: [String] = []
        var eventIDs: [String] = []
        var mapID: String?

        for line in lines {
            if line.hasPrefix("TEXT:") {
                textParts.append(String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces))
            } else if line.hasPrefix("EVENT:") {
                let id = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                if !id.isEmpty { eventIDs.append(id) }
            } else if line.hasPrefix("MAP:") {
                let id = String(line.dropFirst(4)).trimmingCharacters(in: .whitespaces)
                if !id.isEmpty { mapID = id }
            }
        }

        // If the model didn’t follow protocol, show reply as-is.
        if textParts.isEmpty && eventIDs.isEmpty && mapID == nil {
            append(.assistant, .text(raw.trimmingCharacters(in: .whitespacesAndNewlines)))
            return
        }

        if !textParts.isEmpty {
            append(.assistant, .text(textParts.joined(separator: " ")))
        }

        for id in eventIDs.prefix(maxEventsToShow) {
            if let ev = idIndex[id] {
                append(.assistant, .event(ev))
            }
        }

        if let id = mapID, let ev = idIndex[id] {
            append(.assistant, .map(ev))
        }
    }

    // MARK: - Data
    private func loadEvents() async {
        do {
            let url = URL(string: "https://mac-events-494-e4c3b3cxfhdca5fh.centralus-01.azurewebsites.net/events")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let events = try JSONDecoder().decode([Event].self, from: data)
            allEvents = events
            idIndex = Dictionary(uniqueKeysWithValues: events.map { ($0.id, $0) })
        } catch {
            allEvents = []
            idIndex = [:]
        }
    }
}
