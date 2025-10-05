import SwiftUI
import Foundation

// MARK: - Data Models
struct BigHabit: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let weekNumber: Int
    let colorHex: String
    let microHabits: [String]
}

struct HabitProgress: Codable {
    var selectedBigHabitId: Int?
    var completedMicroHabits: [String: Bool] = [:]
    var weekCompletions: [Int: Bool] = [:]
    var currentWeek: Int = 1
    var streaks: Int = 0
    var lastAccessDate: Date = Date()
    
    var hasSelectedHabit: Bool {
        return selectedBigHabitId != nil
    }
}

// MARK: - Storage Manager
class HabitStorageManager: ObservableObject {
    static let shared = HabitStorageManager()
    
    @Published var progress: HabitProgress
    @Published var selectedHabitColorHex: String? = nil
    @Published var selectedWeek: Int? = nil  // store which week this selection belongs to

    private let progressKey = "habitProgress"
    
    let bigHabits: [BigHabit] = [
        BigHabit(
            id: 1,
            title: "Invest in Continuous Learning & Career Growth",
            description: "Expand your knowledge, sharpen your professional edge, and commit to lifelong learning that fuels your career.",
            weekNumber: 1,
            colorHex: "6495ED",
            microHabits: [
                "Spend 15 minutes learning a new skill online",
                "Read one career-related article to stay updated in your field",
                "Watch a 10-minute tutorial related to your area of interest",
                "Practice one small technical or analytical exercise today",
                "Write a 3-line reflection on something new you learned this week",
                "Message a mentor, peer, or professional contact with a small thoughtful question",
                "Listen to 10 minutes of a podcast that inspires your professional growth"
            ]
        ),
        BigHabit(
            id: 2,
            title: "Strengthen Emotional Intelligence & Workplace Etiquette",
            description: "Navigate people dynamics and emotions professionally.",
            weekNumber: 2,
            colorHex: "6495ED",
            microHabits: [
                "Before meetings, write one word to describe how you feel",
                "During conversations, focus on listening more than speaking",
                "Give one person specific positive feedback",
                "Before replying to a problem in your day, pause 3 seconds to assess your tone and clarity",
                "Write down 2 emotional triggers in your work/project/team and how to manage them better",
                "Read a short LinkedIn post or article on empathy at work",
                "Thank one person for their effort, even in small things"
            ]
        ),
        BigHabit(
            id: 3,
            title: "Develop Growth & Leadership Potential",
            description: "Go beyond tasks and act like someone growing into leadership.",
            weekNumber: 3,
            colorHex: "4B0082",
            microHabits: [
                "End the day by asking: 'What did I lead today?'",
                "Take initiative and suggest one improvement to your class/project/team",
                "Ask someone for feedback and accept it gracefully",
                "Choose one challenge today instead of avoiding it",
                "Write down one professional strength you want to master this month",
                "Mentor or help a peer with something you're good at",
                "If something doesn't go right, pause and ask: What can I do differently next time to grow as a leader?"
            ]
        ),
        BigHabit(
            id: 4,
            title: "Communicate with Clarity & Confidence",
            description: "Express ideas persuasively and professionally.",
            weekNumber: 4,
            colorHex: "FBCF4F",
            microHabits: [
                "Record yourself speaking for 1 minute on any topic",
                "Practice introducing yourself in a confident, natural way",
                "Watch one short video on body language",
                "Rephrase a complex sentence into something simple and clear",
                "Write one email or message professionally then reread for tone",
                "Compliment someone on how clearly they expressed an idea",
                "Reflect: 'Did I communicate to be understood or to impress?'"
            ]
        )
    ]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(HabitProgress.self, from: data) {
            self.progress = decoded
        } else {
            self.progress = HabitProgress()
        }
        
        if progress.selectedBigHabitId == nil {
            progress.completedMicroHabits.removeAll()
            progress.weekCompletions.removeAll()
            progress.streaks = 0
            saveProgress()
        }
        
        checkAndUpdateDay()
    }
    
    func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
        objectWillChange.send()
    }

    
    func getCurrentBigHabit() -> BigHabit? {
        return bigHabits.first { $0.weekNumber == progress.currentWeek }
    }
    
    func getSelectedBigHabit() -> BigHabit? {
        guard let id = progress.selectedBigHabitId else { return nil }
        return bigHabits.first { $0.id == id }
    }
    
    func selectBigHabit(_ habit: BigHabit) {
        // store the selected habit ID and week
        progress.selectedBigHabitId = habit.id
        selectedWeek = progress.currentWeek
        progress.completedMicroHabits.removeAll() // clear old micro habits when new one is chosen
        saveProgress()
    }

    
    func isMicroHabitCompleted(week: Int, day: Int) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Get the date for this specific day of the week
        let calendar = Foundation.Calendar.current
        let today = Date()
        let currentWeekday = calendar.component(.weekday, from: today) - 1 // Sun = 0
        let daysToAdd = day - currentWeekday
        
        guard let targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: today) else {
            return false
        }
        
        let dateKey = formatter.string(from: targetDate)
        let key = "week\(week)_day\(day)_\(dateKey)"
        return progress.completedMicroHabits[key] ?? false
    }
    
    func isWeekComplete(week: Int) -> Bool {
        for day in 0..<7 {
            let key = "week\(week)_day\(day)"
            if progress.completedMicroHabits[key] != true {
                return false
            }
        }
        return true
    }
    
    func checkAndUpdateDay() {
        let calendar = Foundation.Calendar.current
        let lastAccess = progress.lastAccessDate
        let now = Date()
        
        if !calendar.isDate(lastAccess, inSameDayAs: now) {
            progress.lastAccessDate = now
            saveProgress()
        }
    }
    
    func getTodayDayOfWeek() -> Int {
        let calendar = Foundation.Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return weekday - 1
    }
    
//    func getWeekColor(week: Int) -> Color {
//        let habit = bigHabits.first { $0.weekNumber == week }
//        return Color(hex: habit?.colorHex ?? "4B0082")
//    }
    
    func getWeekColor(week: Int) -> Color {
        switch week {
        case 1: return Color(hex: "6495ED")   // Cornflower Blue
        case 2: return Color(hex: "4169E1")   // Royal Blue
        case 3: return Color(hex: "4B0082")   // Indigo
        case 4: return Color(hex: "FBCF4F")   // Gold
        default: return Color(hex: "191970")  // Midnight Blue (fallback)
        }
    }

    
    func getDayColor(forDay day: Int, inWeek week: Int) -> Color {
        if isMicroHabitCompleted(week: week, day: day) {
            return getWeekColor(week: week)
        }
        return Color.gray.opacity(0.2)
    }
    
    func resetIfWeekChanged() {
        let currentWeek = progress.currentWeek
        if selectedWeek != currentWeek {
            progress.selectedBigHabitId = nil
            selectedWeek = nil
            progress.completedMicroHabits.removeAll()
            saveProgress()
        }
    }
}

// MARK: - Extension for MicroHabits and Streak Logic
extension HabitStorageManager {
    func availableMicroHabits(for week: Int) -> [String] {
        guard let habit = bigHabits.first(where: { $0.weekNumber == week }) else { return [] }
        let all = habit.microHabits
        let completedCount = (0..<all.count).filter { isMicroHabitCompleted(week: week, day: $0) }.count
        return Array(all.prefix(max(1, completedCount + 1)))
    }
    
    func toggleMicroHabitForToday(week: Int, day: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = formatter.string(from: Date())

        // Toggle completion for this micro habit
        let microKey = "week\(week)_day\(day)_\(todayKey)"
        let currentValue = progress.completedMicroHabits[microKey] ?? false
        progress.completedMicroHabits[microKey] = !currentValue

        // Also store a simple "completedDates" record for calendar checks
        if progress.completedMicroHabits[microKey] == true {
            var completed = UserDefaults.standard.array(forKey: "completedDates") as? [String] ?? []
            if !completed.contains(todayKey) {
                completed.append(todayKey)
                UserDefaults.standard.set(completed, forKey: "completedDates")
            }
        }

        saveProgress()
    }

    
    
}
