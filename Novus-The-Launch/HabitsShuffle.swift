import SwiftUI

struct HabitsShuffle: View {
    @ObservedObject var habitStorage = HabitStorageManager.shared
    @State private var currentIndex: Int = 0
    @State private var acceptedHabit: BigHabit? = nil
    @State private var showFullCard: Bool = false
    @State private var selectedCardColor: Color? = nil
    
    // MARK: - Card Colors (Now 4 total)
    let cardColors: [Color] = [
        Color(red: 0.39, green: 0.58, blue: 0.93),   // Blue - 6495ED
        Color(red: 0.29, green: 0.0, blue: 0.51),    // Purple - 4B0082
        Color(red: 0.98, green: 0.81, blue: 0.31),   // Yellow - FBCF4F
        Color(red: 25/255, green: 25/255, blue: 112/255) // Midnight Blue - 191970
    ]
    
    var body: some View {
        VStack {
            Spacer()
            
            GeometryReader { proxy in
                let cardWidth = proxy.size.width * 0.75
                let cardHeight: CGFloat = showFullCard ? 380 : 300
                let sideCardScale: CGFloat = 0.85
                let sideCardOffset: CGFloat = cardWidth * 0.65
                
                ZStack {
                    if let chosen = acceptedHabit, let color = selectedCardColor {
                        selectedCardView(chosen: chosen, color: color, cardWidth: cardWidth, cardHeight: cardHeight)
                    } else {
                        carouselView(cardWidth: cardWidth, cardHeight: cardHeight, sideCardScale: sideCardScale, sideCardOffset: sideCardOffset)
                    }
                }
                .frame(width: proxy.size.width, height: cardHeight + 60)
            }
            .frame(height: showFullCard ? 460 : 420)
            .padding(.top, 20)
            
            // Page indicators
            if acceptedHabit == nil {
                pageIndicator
            }
            
            Spacer()
        }
        .background(
            Color(red: 230/255, green: 230/255, blue: 250/255)
                .ignoresSafeArea()
        )
    }
}

extension HabitsShuffle {
    // MARK: - Selected Habit Card
    private func selectedCardView(chosen: BigHabit, color: Color, cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(color)
            .frame(width: cardWidth + 60, height: cardHeight)
            .overlay(
                VStack(spacing: 20) {
                    Text("For this habit you will")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(chosen.description)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .lineSpacing(6)
                }
                .padding(.horizontal, 20)
            )
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(), value: showFullCard)
    }
    
    // MARK: - Carousel Before Selection
    private func carouselView(cardWidth: CGFloat, cardHeight: CGFloat, sideCardScale: CGFloat, sideCardOffset: CGFloat) -> some View {
        ZStack {
            if habitStorage.bigHabits.count > 0 {
                leftCard(cardWidth: cardWidth, cardHeight: cardHeight, sideCardScale: sideCardScale, sideCardOffset: sideCardOffset)
            }
            
            centerCard(cardWidth: cardWidth, cardHeight: cardHeight)
            
            if habitStorage.bigHabits.count > 2 {
                rightCard(cardWidth: cardWidth, cardHeight: cardHeight, sideCardScale: sideCardScale, sideCardOffset: sideCardOffset)
            }
        }
    }
    
    private func leftCard(cardWidth: CGFloat, cardHeight: CGFloat, sideCardScale: CGFloat, sideCardOffset: CGFloat) -> some View {
        let leftIndex = (currentIndex - 1 + habitStorage.bigHabits.count) % habitStorage.bigHabits.count
        return RoundedRectangle(cornerRadius: 28)
            .fill(cardColors[leftIndex % cardColors.count])
            .frame(width: cardWidth * sideCardScale, height: cardHeight * sideCardScale)
            .overlay(
                Text(habitStorage.bigHabits[leftIndex].title)
                    .font(.custom("SF Pro Rounded", size: 22).weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            )
            .offset(x: -sideCardOffset, y: 30)
            .zIndex(0)
    }
    
    private func centerCard(cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(cardColors[currentIndex % cardColors.count])
            .frame(width: cardWidth, height: cardHeight)
            .overlay(
                VStack(spacing: 30) {
                    Text(habitStorage.bigHabits[currentIndex].title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .minimumScaleFactor(0.9)
                    
                    Button(action: selectCurrentHabit) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(red: 0.29, green: 0.0, blue: 0.51))
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    }
                }
            )
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            .zIndex(1)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if value.translation.width < -50 {
                                currentIndex = (currentIndex + 1) % habitStorage.bigHabits.count
                            } else if value.translation.width > 50 {
                                currentIndex = (currentIndex - 1 + habitStorage.bigHabits.count) % habitStorage.bigHabits.count
                            }
                        }
                    }
            )
    }
    
    private func rightCard(cardWidth: CGFloat, cardHeight: CGFloat, sideCardScale: CGFloat, sideCardOffset: CGFloat) -> some View {
        let rightIndex = (currentIndex + 1) % habitStorage.bigHabits.count
        return RoundedRectangle(cornerRadius: 28)
            .fill(cardColors[rightIndex % cardColors.count])
            .frame(width: cardWidth * sideCardScale, height: cardHeight * sideCardScale)
            .overlay(
                Text(habitStorage.bigHabits[rightIndex].title)
                    .font(.custom("SF Pro Rounded", size: 22).weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            )
            .offset(x: sideCardOffset, y: 30)
            .zIndex(0)
    }
    
    private func selectCurrentHabit() {
        withAnimation(.spring()) {
            let selected = habitStorage.bigHabits[currentIndex]
            acceptedHabit = selected
            showFullCard = true
            selectedCardColor = cardColors[currentIndex % cardColors.count]
            
            habitStorage.selectBigHabit(selected)
            habitStorage.selectedHabitColorHex = selected.colorHex
            habitStorage.progress.completedMicroHabits.removeAll()
            habitStorage.saveProgress()
        }
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<habitStorage.bigHabits.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color(red: 0.29, green: 0.0, blue: 0.51) : Color.gray.opacity(0.3))
                    .frame(width: index == currentIndex ? 36 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
        .padding(.top, 12)
    }
}

#Preview {
    HabitsShuffle()
}
