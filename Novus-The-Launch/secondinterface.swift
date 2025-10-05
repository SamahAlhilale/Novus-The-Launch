//
//  secondinterface.swift
//  habits
//
//  Created by Nora Abdullah Alhumaydani on 11/04/1447 AH.
//
import SwiftUI
import Combine
import SwiftUI


// Shared data model
class UserData: ObservableObject {
    @Published var userName: String = ""
    @Published var userMotto: String = ""
    @Published var userNote: String = ""
}

struct OnboardingPage2: View {
    @EnvironmentObject var userData: UserData
    @State private var bounce = false
    @State private var navigateToNext = false
    @State private var scrollOffset: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    private let maxNameLength = 15
    
    private var keyboardPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
                .map { $0.height },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        )
        .eraseToAnyPublisher()
    }
    
    private let fadeDuration: Double = 0.12

    var body: some View {
        if navigateToNext {
            thirdinterface()
                .transition(.opacity.animation(.linear(duration: fadeDuration)))
        } else {
            GeometryReader { geometry in
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 184/255, green: 184/255, blue: 255/255), location: 0.0),
                            .init(color: Color(red: 219/255, green: 219/255, blue: 226/255), location: 0.33),
                            .init(color: Color(red: 228/255, green: 228/255, blue: 238/255), location: 0.66),
                            .init(color: Color(red: 228/255, green: 228/255, blue: 238/255), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    // Scrollable content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer().frame(height: 140)

                            // Title section
                                .padding(.top,60)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Kindly,")
                                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black)
                                
                                HStack {
                                    Text("Enter")
                                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.5))
                                    Text("your name...")
                                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                                        .foregroundColor(.black)
                                }

                                Text("(optional)")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                            }
                            .padding(.leading, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Spacer().frame(height: 40)

                            // Input field
                            VStack(alignment: .leading, spacing: 12) {
                                TextField("name or nickname", text: $userData.userName)
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color(red: 215/255, green: 215/255, blue: 242/255))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                                    .padding(.horizontal, 24)
                                    .focused($isTextFieldFocused)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        isTextFieldFocused = false
                                    }
                                    .onChange(of: userData.userName) { oldValue, newValue in
                                        if newValue.count > maxNameLength {
                                            userData.userName = String(newValue.prefix(maxNameLength))
                                        }
                                    }

                                Text("By sharing this, we can remind you of the motivation that inspired you to start.")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer().frame(height: 420)
                        }
                        .padding(.bottom, keyboardHeight)
                        .background(GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                        })
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                        let threshold = -geometry.size.height * 0.12
                        if scrollOffset < threshold {
                            isTextFieldFocused = false
                            withAnimation(.linear(duration: fadeDuration)) {
                                navigateToNext = true
                            }
                        }
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 20, coordinateSpace: .local)
                            .onEnded { gesture in
                                if gesture.translation.height < -60 {
                                    isTextFieldFocused = false
                                    withAnimation(.linear(duration: fadeDuration)) {
                                        navigateToNext = true
                                    }
                                }
                            }
                    )

                    // Page dots - positioned like Welcomepage1
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(Color(red: 0.2, green: 0.2, blue: 0.5))
                            .frame(width: 10, height: 10)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 20)
                    .padding(.bottom, 36)

                    // Scroll hint - positioned like Welcomepage1
                    VStack(spacing: 6) {
                        Text("Scroll")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red:75/255  , green:0/255 , blue: 130/255))

                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red:75/255  , green:0/255 , blue: 130/255))

                            .offset(y: bounce ? -8 : 0)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true),
                                value: bounce
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 36)
                    .onAppear { bounce = true }
                }
                .ignoresSafeArea()
                .onTapGesture {
                    isTextFieldFocused = false
                }
                .onReceive(keyboardPublisher.receive(on: RunLoop.main)) { height in
                    keyboardHeight = height
                }
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/*extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r,g,b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: 1)
    }
}*/

struct OnboardingPage2_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPage2()
            .environmentObject(UserData())
    }
}

// Shared data model


