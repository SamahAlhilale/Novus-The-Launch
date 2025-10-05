//
//  ContentView.swift
//  habits
//
//  Created by Nora Abdullah Alhumaydani on 11/04/1447 AH.
//
import SwiftUI

struct ContentView: View {
    // Use the shared UserData provided by the App
    @EnvironmentObject var userData: UserData

    @State private var isAnimated: Bool = false
    @State private var showSettingPopup = false
    @State private var showNotivicationPopup = false
    @State private var showAddHabitsPopup = false
    @State private var showShufflePopup = false

    @State private var shakePhone: Bool = false
    @State private var shakeCount: Int = 0

    var body: some View {
        ZStack(alignment: .top) {

            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 230/255, green: 230/255, blue: 250/255).opacity(0.8),
                    Color.white
                ]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(alignment: .leading) {

                // Header with name + settings + icons
                HStack {
                    // Welcome text + edit button
                    HStack(spacing: 9) {
                        Text("Welcome Back, \(userData.userName.isEmpty ? "Achiever" : userData.userName)!")
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                            .foregroundStyle(.black)

                        Button(action: { showSettingPopup = true }) {
                            Image(systemName: "pencil.and.scribble")
                                .foregroundColor(Color(hex: "4B0082"))
                                .font(.system(size: 15, weight: .heavy))
                        }
                        .sheet(isPresented: $showSettingPopup) {
                            SettingSheet(userData: userData, showSettingPopup: $showSettingPopup)
                        }
                    }

                    Spacer()

                    // Icons
                    HStack(spacing: 12) {
                        StreakIcon(streakCount: HabitStorageManager.shared.progress.streaks)


//                        NotificationIcon(isAnimated: $isAnimated, showNotivicationPopup: $showNotivicationPopup)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 32)
                .padding(.bottom, 32)

                // Page title
                Text("Tracking Your \n Habits")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .frame(width: 350, height: 100, alignment: .leading)
                .padding(.horizontal)

                // Calendar
                CalendarSection()

                // Today's Activities
                .padding(.top, 16)
                HStack {
                    Text("Today's Activities")
                        .font(.system(size: 20, weight: .semibold))

                    Spacer()

                    // Add Habits button
                    Button(action: { showAddHabitsPopup = true }) {
                        Circle()
                            .fill(Color(red: 230/255, green: 230/255, blue: 250/255))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color(hex: "4B0082"))
                            )
                    }
                    .sheet(isPresented: $showAddHabitsPopup) {
                        AddHabitsSheet(
                            shakePhone: $shakePhone,
                            shakeCount: $shakeCount,
                            showShufflePopup: $showShufflePopup,
                            dismissParent: { showAddHabitsPopup = false }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                // Activities list
                ActivitiesList()
            }
        }
        .sheet(isPresented: $showShufflePopup) {
            HabitsShuffle()
                .presentationDetents([.medium, .large])
        .onAppear {
                    HabitStorageManager.shared.resetIfWeekChanged()
                }
        }
        // Keep environment object wiring to the App (do not re-add here)
    }

}


// Preview: provide environmentObject so the preview compiles
#Preview {
    ContentView()
        .environmentObject(UserData())
}


struct SettingSheet: View {
    @ObservedObject var userData: UserData
    @Binding var showSettingPopup: Bool
    
    private let maxNameLength = 15
    private let maxMottoLength = 18
    private let maxNoteLength = 25
    
    var body: some View {
        VStack( spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    TextField("Your Name", text: $userData.userName)
                        .padding(.horizontal, 12)
                        .frame(width: 345, height: 44)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: userData.userName) { oldValue, newValue in
                            if newValue.count > maxNameLength {
                                userData.userName = String(newValue.prefix(maxNameLength))
                            }
                        }
                }
                
                // Motto
                VStack(alignment: .leading, spacing: 6) {
                    Text("Motto")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    TextField("Your Motto", text: $userData.userMotto)
                        .padding(.horizontal, 12)
                        .frame(width: 345, height: 44)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: userData.userMotto) { oldValue, newValue in
                            if newValue.count > maxMottoLength {
                                userData.userMotto = String(newValue.prefix(maxMottoLength))
                            }
                        }
                }
                
                // Note to self
            VStack(alignment: .leading, spacing: 6) {
                Text("Note to self")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                TextField("Your Note to Self", text: $userData.userNote)
                    .padding(.horizontal, 12)
                    .frame(width: 345, height: 44)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onChange(of: userData.userNote) { oldValue, newValue in
                        if newValue.count > maxNoteLength {
                            userData.userNote = String(newValue.prefix(maxNoteLength))
                        }
                    }
            }
                
                Button("Done") {
                    showSettingPopup = false
                }
                .font(.system(size: 18, weight: .bold))
                .frame(width: 150, height: 40)
                .foregroundColor(.white)
                .background(Color(hex: "4B0082"))
                .cornerRadius(8)
            
        }
        .padding(.top, 20)
        .presentationDetents([.medium, .large])
        .frame(width: UIScreen.main.bounds.width, height: 900)
        .background(Color(red: 230/255, green: 230/255, blue: 250/255))
    }
}


struct AddHabitsSheet: View {
    @Binding var shakePhone: Bool
    @Binding var shakeCount: Int
    @Binding var showShufflePopup: Bool
    
    var dismissParent: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("SHAKE!")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "4B0082"))
            
            Image(.sheke)
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(shakePhone ? -10 : 10))
                .animation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true), value: shakePhone)
                .onAppear { shakePhone = true }
                .padding(.top, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 230/255, green: 230/255, blue: 250/255))
        .presentationDetents([.medium, .large])
        .onShake {
            dismiss()
            dismissParent()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showShufflePopup = true
            }
        }
    }
}

struct StreakIcon: View {
    /// Current streak count (x1, x2, x3...)
    var streakCount: Int
    
    /// Animation trigger
    @State private var animatePulse = false
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .fill(Color(red: 230/255, green: 230/255, blue: 250/255))
                .frame(width: 40, height: 40)
                .scaleEffect(animatePulse ? 1.08 : 1.0)
                .animation(.spring(response: 0.45, dampingFraction: 0.6), value: animatePulse)
            
            // Flame
            Image(systemName: "flame.fill")
                .foregroundColor(Color(red: 252/255, green: 85/255, blue: 6/255))
                .scaleEffect(animatePulse ? 1.15 : 1.0)
                .animation(.spring(response: 0.45, dampingFraction: 0.6), value: animatePulse)
            
            // Streak text
            Text("x\(streakCount)")
                .font(.system(size: 14, design: .rounded))
                .bold()
                .offset(x: 5, y: 7)
                .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                .scaleEffect(animatePulse ? 1.15 : 1.0)
                .animation(.spring(response: 0.45, dampingFraction: 0.6), value: animatePulse)
        }
        .onChange(of: streakCount) { _, _ in
            // Animate pulse when streak increases
            withAnimation {
                animatePulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                animatePulse = false
            }
        }
    }
}


//struct NotificationIcon: View {
//    @Binding var isAnimated: Bool
//    @Binding var showNotivicationPopup: Bool
//
//    var body: some View {
//        Button(action: { showNotivicationPopup = true }) {
//            Circle()
//                .fill(Color(red: 230/255, green: 230/255, blue: 250/255))
//                .frame(width: 40, height: 40)
//                .overlay(
//                    Image(systemName: "bell.badge")
//                        .foregroundStyle(Color(red: 252/255, green: 85/255, blue: 6/255), Color(hex: "4B0082"))
//                        .offset(x: isAnimated ? -2 : 2)
//                        .animation(.easeInOut(duration: 0.5).repeatForever(), value: isAnimated)
//                )
//                .onAppear { isAnimated = true }
//        }
//        .sheet(isPresented: $showNotivicationPopup) {
//            NotificationsView()
//                .presentationDetents([.medium, .large])
//        }
//    }
//}
struct CalendarSection: View {
    @ObservedObject var storage = HabitStorageManager.shared
    @State private var showCalenderSheet = false
    
    // MARK: - Compute current week days dynamically
    private var currentWeekDates: [Date] {
        let calendar = Foundation.Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today) // Sunday = 1
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // Only numeric day
        return formatter
    }

    private var storageFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            
            // “View All” button
            Button {
                showCalenderSheet = true
            } label: {
                Text("View All")
                    .font(.system(size: 10, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.bottom, 8)
                    .padding(.trailing, 20)
                    .underline()
                    .foregroundColor(Color(hex: "4B0082"))
            }
            .sheet(isPresented: $showCalenderSheet) {
                Calendar()
            }
            
            // Weekday header
            HStack(spacing: 20) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .foregroundColor(.gray)
                        .font(.system(size: 15, weight: .regular))
                        .frame(width: 36)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Fixed date row
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 370, height: 38)
                    .allowsHitTesting(false)
                
                HStack(spacing: 20) {
                    ForEach(Array(currentWeekDates.enumerated()), id: \.offset) { index, date in
                        let dateKey = storageFormatter.string(from: date)
                        let completedDates = UserDefaults.standard.array(forKey: "completedDates") as? [String] ?? []
                        let isDone = completedDates.contains(dateKey)
                        let isToday = Foundation.Calendar.current.isDateInToday(date)
                        let dayString = dayFormatter.string(from: date)
                        
                        ZStack {
                            Circle()
                                .fill(isDone ? Color(hex: "4B0082") : .clear)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "4B0082"), lineWidth: isToday ? 2 : 0)
                                )
                                .frame(width: 25, height: 25)
                                .animation(.easeInOut(duration: 0.25), value: isDone)
                            
                            Text(dayString)
                                .foregroundColor(isDone ? .white : .black)
                                .font(.system(size: 15, weight: .regular))
                        }
                        .frame(width: 36, height: 38)
                    }
                }
                .frame(height: 38)
            }
            .frame(height: 38)
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
    }
}


struct ActivitiesList: View {
    @ObservedObject var storage = HabitStorageManager.shared

    var body: some View {
        ZStack(alignment: .top) {
            // Background box
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 230/255, green: 230/255, blue: 250/255))
                .frame(maxWidth: .infinity, minHeight: 338, maxHeight: 338)
                .padding(.horizontal)
            
            // Check if user has selected a Big Habit first
            if let selectedHabit = storage.getSelectedBigHabit(),
               storage.selectedWeek == storage.progress.currentWeek {
                // ✅ Show micro habits only if user selected a habit this week
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 16) {
                        let week = selectedHabit.weekNumber
                        let availableMicroHabits = storage.availableMicroHabits(for: week)
                        
                        ForEach(Array(availableMicroHabits.enumerated()), id: \.offset) { index, microHabit in
                            let isDone = storage.isMicroHabitCompleted(week: week, day: index)
                            
                            Button(action: {
                                    storage.toggleMicroHabitForToday(week: week, day: index)
                                }) {
                                HStack {
                                    Text(microHabit)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isDone ? Color(hex: selectedHabit.colorHex) : .gray)
                                }
                                .padding(.horizontal, 12)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.9))
                                )
                                .frame(width: 350)
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                .frame(height: 330)
            } else {
                // 🧭 Completely empty before shake
                VStack {
                    Text("Shake your phone to select your Big Habit")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(height: 330)
            }
        }
    }
}

struct ActionButtonStyle: ButtonStyle {
    var enabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 28)
            .background(enabled ? Color(hex: "4B0082") : Color.gray.opacity(0.4))
            .clipShape(Capsule())
    }
}

// MARK: - HEX Color Extension
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

// MARK: - Shake Detection
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
        }
    }
}

extension Notification.Name {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

struct ShakeDetector: ViewModifier {
    var onShake: () -> Void
    func body(content: Content) -> some View {
        content.onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
            onShake()
        }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeDetector(onShake: action))
    }
}

#Preview {
    ContentView()
}
