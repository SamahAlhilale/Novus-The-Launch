//
//  fourthinterface.swift
//  habits
//
//  Created by Nora Abdullah Alhumaydani on 11/04/1447 AH.
//
import SwiftUI
import Combine

struct fourthinterface: View {
    @EnvironmentObject var userData: UserData
    @State private var bounce = false
    @State private var navigateNext = false
    private let maxNoteLength = 25

    // keyboard handling
    @State private var keyboardHeight: CGFloat = 0
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
        if navigateNext {
            Welcomepage(userName: userData.userName, currentPage: 5, totalPages: 6)
                .environmentObject(userData)
                .transition(.opacity.animation(.linear(duration: fadeDuration)))
        } else {
            ZStack {
                // Multi-point gradient background
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
                
                ZStack {
                    // Main content
                    VStack(spacing: 0) {
                        // Top spacing
                        Spacer()
                            .frame(height: 140)
                         
                        // Title section
                        VStack(alignment:.leading , spacing: 4) {
                            Text("Kindly,")
                                .font(.system(size: 36, weight: .semibold, design: .rounded))
                                .foregroundColor(.black)
                                                           
                            HStack{
                                Text("Write")
                                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.5))
                                Text("a note to yourself ")
                                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black)
                            }
                            
                            Text(" (Required)")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                        .padding(.leading, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Spacing before input field
                        Spacer()
                            .frame(height: 40)
                        
                        // Input field
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("note to self", text: $userData.userNote)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color(red: 215/255, green: 215/255, blue: 242/255))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 30)
                                .submitLabel(.done)
                                .onSubmit {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                .onChange(of: userData.userNote) { oldValue, newValue in
                                    if newValue.count > maxNoteLength {
                                        userData.userNote = String(newValue.prefix(maxNoteLength))
                                    }
                                }
                            
                            // Description text
                            Text("By sharing this, we can remind you of the motivation that inspired you to start.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.black)
                                .padding(.horizontal, 30)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Submit Button
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            withAnimation(.linear(duration: fadeDuration)) {
                                navigateNext = true
                            }
                        }) {
                            Text("Submit")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 78, height: 38)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(userData.userNote.isEmpty ? Color.gray : Color(red: 75/255, green: 0/255, blue: 130/255))
                                )
                        }
                        .disabled(userData.userNote.isEmpty)
                        .padding(.top, 32)
                        
                        // Bottom spacer
                        Spacer()
                        
                        // Scroll text and arrow
//                        VStack(spacing: 4) {
//                            Text("Scroll")
//                                .font(.system(size: 14, weight: .medium))
//                                .foregroundColor(Color(hex: "4B0082"))
//
//                            Image(systemName: "arrow.up")
//                                .font(.system(size: 16, weight: .medium))
//                                .foregroundColor(Color(hex: "4B0082"))
//                                .offset(y: bounce ? -8 : 0)
//                                .animation(
//                                    Animation.easeInOut(duration: 0.9)
//                                        .repeatForever(autoreverses: true),
//                                    value: bounce
//                                )
//                                .onAppear {
//                                    bounce = true
//                                }
//                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.bottom, keyboardHeight)
                    
                    // Page indicator dots
                    VStack {
                        Spacer().frame( height: 650)

                        VStack(spacing: 8) {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color(red: 0.2, green: 0.2, blue: 0.5))
                                .frame(width: 10, height: 10)
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onEnded { gesture in
                        if gesture.translation.height < -60 {
                            guard !userData.userNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            withAnimation(.linear(duration: fadeDuration)) {
                                navigateNext = true
                            }
                        }
                    }
            )
            .onReceive(keyboardPublisher.receive(on: RunLoop.main)) { height in
                keyboardHeight = height
            }
        }
    }
}

extension Color {
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
}

struct fourthinterface_Previews: PreviewProvider {
    static var previews: some View {
        fourthinterface()
            .environmentObject(UserData())
    }
}
