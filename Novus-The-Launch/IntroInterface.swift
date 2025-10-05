//
//  IntroInterface.swift
//  habits
//
//  Created by Nora Abdullah Alhumaydani on 11/04/1447 AH.
//

import SwiftUI

struct IntroInterface: View {
    @State private var bounce = false
    @State private var navigateToNext = false
    @State private var scrollOffset: CGFloat = 0
    
    private let fadeDuration: Double = 0.12
    
    var body: some View {
        if navigateToNext {
            OnboardingPage2()
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
                            Spacer().frame(height: 134)
                            
                            // Title text
                                .padding(.top,60)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Help us")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.5))
                                
                                Text("make your")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text("experience")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .padding(.leading, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            // Subtitle text
                            
                            HStack(spacing: 0) {
                                Text("More ")
                                    
                                    .font(.system(size: 34, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                Text("Personal")
                                    .font(.system(size: 34, weight: .semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.5))
                            } //here
                            .padding(.top,150)
                            .padding(.leading, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer().frame(height: 420)
                        }
                        .background(GeometryReader { geo in
                            Color.clear.preference(
                                key: FirstScrollOffsetPreferenceKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                        })
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(FirstScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                        let threshold = -geometry.size.height * 0.12
                        if scrollOffset < threshold {
                            withAnimation(.linear(duration: fadeDuration)) {
                                navigateToNext = true
                            }
                        }
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 20, coordinateSpace: .local)
                            .onEnded { gesture in
                                if gesture.translation.height < -60 {
                                    withAnimation(.linear(duration: fadeDuration)) {
                                        navigateToNext = true
                                    }
                                }
                            }
                    )
                    
                    // Page dots - positioned like other pages
                    VStack(spacing: 12) {
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
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 20)
                    .padding(.bottom, 36)
                    
                    // Scroll hint - positioned like other pages
                    VStack(spacing: 6) {
                        Text("Scroll")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "4B0082"))
                        
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "4B0082"))
                            .offset(y: bounce ? -8 : 0)
                            .animation(
                                Animation.easeInOut(duration: 0.9)
                                    .repeatForever(autoreverses: true),
                                value: bounce
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 36)
                    .onAppear { bounce = true }
                }
                .ignoresSafeArea()
            }
        }
    }
}

struct FirstScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        IntroInterface()
    }
}
