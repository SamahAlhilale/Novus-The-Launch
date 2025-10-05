//
//  NotificationsView.swift
//  The Launch
//

import SwiftUI

// MARK: - Data Model
struct AppNotification: Identifiable {
    let id = UUID()
    let title: String   // "Motto in Life" or "Note to Self"
    let userInput: String
    let date: Date
}

// MARK: - Main View
struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var notifications: [AppNotification] = [
        AppNotification(title: "Motto in Life", userInput: "Keep moving forward, no matter how small the step.", date: Date().addingTimeInterval(-300)),   // 5 min ago
        AppNotification(title: "Note to Self", userInput: "You started this journey to build consistency.", date: Date().addingTimeInterval(-7200)),     // 2 hours ago
        AppNotification(title: "Motto in Life", userInput: "Discipline beats motivation.", date: Date().addingTimeInterval(-86400)),                     // yesterday
        AppNotification(title: "Note to Self", userInput: "Remember how proud you felt when you began.", date: Date().addingTimeInterval(-172800))       // 2 days ago
    ]
    
    var body: some View {
      
        VStack {
            // Header
            HStack {
                
                Text("Notifications")
                    .fontWeight(.semibold)
                    .font(.system(size: 30))
                    .foregroundStyle(.black)
                
                
                Spacer()
                
//                Button(action: {
//                    withAnimation { dismiss() }
//                }) {
//                    Image(systemName: "xmark")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.white)
//                        .frame(width: 36, height: 36)
//                        .background(Color(hex: "4B0082"))
//                        .clipShape(Circle())
//                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
//                }
            }
            .padding(.horizontal)
            .padding(.top, 60)
            
            // Notifications list
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(notifications) { notification in
                        NotificationCard(notification: notification)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .background(Color(red: 230/255, green: 230/255, blue: 250/255))
        
    }
}

// MARK: - Card View
struct NotificationCard: View {
    var notification: AppNotification
    
    var body: some View {
        
        let isNew = Date().timeIntervalSince(notification.date) < 86400 // 24 hours
        
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(notification.title)
                .font(.custom("SF Pro Rounded", size: 18).weight(.bold))
                .foregroundColor(isNew ? Color(hex: "4B0082") : Color(hex: "4B0082").opacity(0.6))
            
            Text(creativeMessage(for: notification))
                .font(.custom("SF Pro Rounded", size: 16).weight(.semibold))
                .foregroundColor(isNew ? Color(hex: "191970") : Color(hex: "191970").opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
            
            Text(timeAgo(since: notification.date))
                .font(.custom("SF Pro Rounded", size: 14).weight(.semibold))
                .foregroundColor(.gray.opacity(0.8))
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isNew ? Color(hex: "ffffff") : Color.gray.opacity(0.3))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    // Creative phrasing generator
    func creativeMessage(for notification: AppNotification) -> String {
        switch notification.title {
        case "Motto in Life":
            let phrases = [
                "Remember why you said:",
                "Your motto still guides you:",
                "Don’t forget your words:",
                "Here’s your spark again:"
            ]
            return "\(phrases.randomElement() ?? "Remember:") \"\(notification.userInput)\""
            
        case "Note to Self":
            let phrases = [
                "Your note to self whispers:",
                "You once reminded yourself:",
                "Keep this in mind:",
                "Don’t lose sight of:"
            ]
            return "\(phrases.randomElement() ?? "Reminder:") \"\(notification.userInput)\""
            
        default:
            return notification.userInput
        }
    }
    
    // Relative time formatter
    func timeAgo(since date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NotificationsView()
}
