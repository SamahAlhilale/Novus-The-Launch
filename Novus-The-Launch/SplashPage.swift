//
//  SplashPage.swift
//  habits
//
//  Created by Nora Abdullah Alhumaydani on 11/04/1447 AH.
//

import SwiftUI

struct SplashPage: View {
    @State private var isActive = false
    @State private var appear = false      // للوجو
    @State private var sweep = false       // لحركة الشعاع
    
    var body: some View {
        if isActive {
            IntroInterface()
        } else {
            GeometryReader { geo in
                ZStack {
                    // خلفية بتدرّج ناعم (نفس ContentView)
                    LinearGradient(
                        colors: [
                            Color(.sRGB, red: 0.486, green: 0.478, blue: 0.882), // بنفسجي فاتح
                            Color(.sRGB, red: 0.906, green: 0.922, blue: 0.976), // أبيض مزرق
                            Color(.sRGB, red: 0.431, green: 0.482, blue: 0.851)  // أزرق بنفسجي
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // شعاع ضوئي يمسح الشاشة بهدوء
                    LinearGradient(
                        colors: [.white.opacity(0.599), .white.opacity(0.20), .white.opacity(0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geo.size.width * 1.1, height: geo.size.height * 1.1)
                    .rotationEffect(.degrees(20))
                    .offset(x: sweep ? geo.size.width : -geo.size.width)
                    .blur(radius: 30)
                    .blendMode(.softLight)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: sweep)
                    
                    // فيغنت خفيف لزيادة التركيز
                    RadialGradient(
                        colors: [.clear, .black.opacity(0.19)],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width
                    )
                    .ignoresSafeArea()
                    .blendMode(.multiply)
                    
                    VStack {
                        Spacer()
                            
                        // مجموعة الشعار + النص
                        VStack(spacing: -18) {
                            ZStack {
                                // الشعار (welcomelogo من Assets)
                                Image("77")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 250, height: 250)
                                    .opacity(appear ? 0.95 : 0)
                                    .scaleEffect(appear ? 1.0 : 0.97)
                                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                                    .animation(.easeOut(duration: 0.8), value: appear)
                                    .offset(x: -18, y: 0)
                                    
                            }
                            // النص تحت الشعار
                            

                           
                        }
                        // الإزاحة المطلوبة
                        .offset(x: -geo.size.width * 0.03,
                                y: -geo.size.height * 0.04)
                       

                        
                        Spacer()
                    }
                    .padding()
                }
                .onAppear {
                    appear = true
                    sweep = true
                    
                    // الانتقال للشاشة التالية بعد 2.5 ثانية
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashPage()
}
