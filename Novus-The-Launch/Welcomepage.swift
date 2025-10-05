//
//  Welcomepage.swift
//  habits
//
//  Created by Nora Abdullah Alhumaydani on 11/04/1447 AH.
//
import SwiftUI

struct Welcomepage1: View {
    var body: some View {
        Welcomepage(userName: "", currentPage: 5, totalPages: 6)
    }
}

struct Welcomepage: View {
    // typing settings
    private let charDelay: Double = 0.03  // adjust speed
    
    var userName: String = ""
    var currentPage: Int = 5
    var totalPages: Int = 6
    
    // typing state
    @State private var visibleText: String = ""
    @State private var typingTask: Task<Void, Never>? = nil
    @State private var isTyping: Bool = false
    @State private var isActive = false
    @State private var appear = false
    @State private var sweep = false

    var body: some View {
        if isActive {
            ContentView()
                .transition(.opacity)
        } else {
            ZStack {
                // Background gradient (lavender → white)
                LinearGradient(
                    colors: [
                        Color(red: 0.76, green: 0.74, blue: 0.98), // light lavender top
                        Color.white                                // soft white bottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Scrollable content — disabled while typing
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 140)
                            .padding(.top,30)
                        
                        // Welcome and Username section (isolated)
                        VStack(alignment: .leading, spacing: 0){
                            // Title (kept absolutely static — no animation)
                            Text("Welcome")
                                .font(.system(size: 45, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .animation(.none, value: userName)
                            
                            // Username with gradient (use "Achiever" if empty)
                            let displayName = userName.isEmpty ? "Achiever" : userName
                            let title = Text(displayName + ",")
                                .font(.system(size: 45, weight: .bold, design: .rounded))
                            let midnight     = Color(.sRGB, red: 25/255, green: 25/255,  blue: 112/255)
                            let deepIndigoL1 = Color(.sRGB, red: 102/255, green: 38/255, blue: 149/255)
                            title
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: midnight,     location: 0.0),
                                            .init(color: deepIndigoL1, location: 1.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .mask(title)
                                .animation(.none, value: userName)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer().frame(height: 42.5)
                        
                        // Typing text section (isolated)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(visibleText)
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .lineSpacing(4)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                .animation(.none, value: visibleText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer().frame(height: 420) // extra space for scroll
                    }
                    .padding(.horizontal, 24)
                }
                .scrollDisabled(isTyping)
                .onAppear {
                    startTypingCharByChar()
                    appear = true
                    sweep = true
                    
                    // Navigate to next screen after 2.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isActive = true
                        }
                    }
                }
                .onDisappear {
                    typingTask?.cancel()
                    isTyping = false
                }
                
                // Bottom-right page dots
                .overlay(alignment: .bottomTrailing) {
                    PageDots(current: currentPage, total: totalPages)
                        .padding(.trailing, 20)
                        .padding(.bottom, 36)
                }
                
                // Bottom "Scroll ↑" hint
                .overlay(alignment: .bottom) {
                    ScrollHint()
                        .padding(.bottom, 36)
                }
            }
        }
    }
    
    // MARK: - Char-by-char typing
    private func startTypingCharByChar() {
        let fullText = "This is your space to grow, reflect, and build better habits one small step at a time."
        visibleText = ""
        typingTask?.cancel()
        
        let chars = Array(fullText)
        
        // mark typing started
        isTyping = true
        typingTask = Task {
            for ch in chars {
                if Task.isCancelled {
                    await MainActor.run { isTyping = false }
                    return
                }
                await MainActor.run { visibleText.append(ch) }
                try? await Task.sleep(nanoseconds: UInt64(charDelay * 1_000_000_000))
            }
            
            await MainActor.run { isTyping = false }
        }
    }
}

// MARK: - Page Dots
struct PageDots: View {
    let current: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color(hex: "191970") : Color(hex: "191970").opacity(0.20))
                    .frame(width: 10, height: 10)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Scroll Hint
struct ScrollHint: View {
    @State private var bounce = false
    
    var body: some View {
        VStack(spacing: 6) {
            Text("Scroll")
                .font(.footnote)
                .foregroundStyle(Color(hex: "4B0082"))
            Image(systemName: "arrow.up")
                .font(.footnote)
                .offset(y: bounce ? -5 : 0)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: bounce)
        }
        .onAppear { bounce = true }
        .accessibilityHidden(true)
    }
}

// MARK: - Hex Color Helper
/*extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.replacingOccurrences(of: "#", with: "")
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8) & 0xFF) / 255
        let b = Double(v & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}*/

#Preview {
    Welcomepage(userName: "Sarah", currentPage: 5, totalPages: 6)
}
