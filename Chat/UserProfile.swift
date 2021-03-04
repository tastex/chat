//
//  UserProfile.swift
//  Chat
//
//  Created by VB on 28.02.2021.
//

import Foundation
import UIKit

class UserProfile {

    var image: UIImage?
    var conversations: [Conversation]
    var onlineConversations: [Conversation] { conversations.filter { $0.online } }
    var offlineConversations: [Conversation] { conversations.filter { !$0.online } }

    init(image: UIImage?, conversations: [Conversation] = []) {
        self.image = image
        self.conversations = conversations
    }

    static var defaultProfile = UserProfile(image: UIImage(named: "DefaultProfileImage"), conversations: fakeConversations())

    class Conversation {
        var name: String?
        var online: Bool
        var messages: [Message]
        var hasUnreadMessages: Bool { messages.contains { $0.status == .unread } }

        init(name: String?, online: Bool, messages: [Message] = []) {
            self.name = name
            self.online = online
            self.messages = messages
        }
    }

    class Message {
        let text: String?
        let kind: MessageKind
        let status: MessageStatus
        let date: Date?

        init(_ text: String?, kind: MessageKind = .incoming, status: MessageStatus = .unread, date: Date?) {
            self.text = text
            self.kind = kind
            self.status = status
            self.date = date
        }
        enum MessageKind {
            case incoming
            case outgoing
        }

        enum MessageStatus {
            case unread
            case read
        }
    }

    private static func fakeConversations() -> Array<Conversation> {

        let online = Array(arrayLiteral:
                            Conversation(name: "Bob", online: true, messages: [
                                Message("Hello",
                                        kind: .incoming,
                                        status: .read,
                                        date: Date().addingTimeInterval(TimeInterval(-180))),
                                Message("Did you finish your third homework?",
                                        kind: .incoming,
                                        status: .read,
                                        date: Date().addingTimeInterval(TimeInterval(-160))),
                                Message("Hi, Bob!",
                                        kind: .outgoing,
                                        status: .unread,
                                        date: Date().addingTimeInterval(TimeInterval(-60)))
                            ]),
                           Conversation(name: "Alice", online: true, messages: Array()),
                           Conversation(name: nil, online: true, messages: Array()),
                           Conversation(name: nil, online: true, messages: [
                            Message("",
                                    kind: .incoming,
                                    status: .unread,
                                    date: nil)
                           ]),
                           Conversation(name: "Mat", online: true, messages: [
                            Message(nil,
                                    kind: .incoming,
                                    status: .unread,
                                    date: nil)
                           ]),
                           Conversation(name: "Наташа", online: true, messages: [
                            Message("Скорее иди домой, у меня ужин готов. И захвати пожалуйста авокадо для тостов 🥑",
                                    kind: .outgoing,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-1200))),
                            Message("Уже бегу, в нашем супермаркете авокадо не было. Пришлось вернуться и зайти на рынок. Через 10 минут буду.",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-1100))),
                            Message("👍",
                                    kind: .outgoing,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-1090))),
                            Message("😉",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-1000)))
                           ]),
                           Conversation(name: "Apple Developer News", online: true, messages: [
                            Message("Submitting health pass apps",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-100001))),
                            Message("With the recent release of COVID-19 vaccines, we’ve seen an increase in apps that generate health passes used to enter buildings and access in-person services based on testing and vaccination records. To ensure these apps responsibly handle sensitive data and provide reliable functionality, they must be submitted by developers working with entities recognized by public health authorities, such as test kit manufacturers, laboratories, or healthcare providers. As with other apps related to COVID-19, we also accept apps submitted directly by government, medical, and other credentialed institutions.",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-100000))),
                            Message("Apple Entrepreneur Camp applications open for female founders and developers",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-90000))),
                            Message("Apple Entrepreneur Camp supports underrepresented founders and developers as they build the next generation of cutting-edge apps and helps form a global network that encourages the pipeline and longevity of these entrepreneurs in technology. Applications are open now for the next cohort for female founders and developers, which runs online from July 20 to 29, 2021. Attendees receive code-level guidance, mentorship, and inspiration with unprecedented access to Apple engineers and leaders. Applications close on March 26, 2021.",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-80000))),
                            Message("App Analytics now includes App Clip data",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-70000))),
                            Message("You can now view important details about your App Clips, such as the number of installations, sessions, and crashes. You can also see how users found your App Clips — for example, through an App Clip Code, Maps, or an external referral. App Clip data is available only from users who have agreed to share their diagnostics and usage information with app developers.",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-60000))),
                            Message("IMDF now recognized as Global Community Standard",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-50000))),
                            Message("Indoor Mapping Data Format (IMDF) lets you present your users with fully-customized indoor maps of venues around the world, such as stadiums, airports, and campuses — all under the security and privacy controls of the property owner. Developed by Apple, IMDF makes it easy for organizations to enable Apple’s indoor positioning service on iPhone and iPad inside facilities without installing additional infrastructure, like beacons. It offers a mobile-friendly, compact, human-readable, and highly extensible data model for any indoor space, providing a basis for orientation, navigation, and discovery. And now, the Open Geospatial Consortium (OGC) membership has added IMDF 1.0.0 to the OGC Standards Baseline as a Community Standard.",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-40000))),
                            Message("Additional guidance available for App Store privacy labels",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-30000))),
                            Message("Additional details have been published on completing your App Store privacy labels, including more information about data types, such as email or text messages, and gameplay content. You’ll also find more information about data collected in web views and data that may be entered by users within documents or other file types.",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20000))),
                            Message("Reminder: APNs provider API requirement starts March 31",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-10001))),
                            Message("The HTTP/2-based Apple Push Notification service (APNs) provider API lets you take advantage of great features, such as authentication with a JSON Web Token, improved error messaging, and per-notification feedback. If you still send push notifications with the legacy binary protocol, make sure to upgrade to the APNs provider API as soon as possible. APNs will no longer support the legacy binary protocol after March 31, 2021.",
                                    kind: .incoming,
                                    status: .unread,
                                    date: Date().addingTimeInterval(TimeInterval(-10000))),

                           ]),
                           Conversation(name: "Jeff with very looooooooooong second name", online: true, messages: [
                            Message("Sisters starving, brothers begging. Mothers mourning, fathers folding",
                                    kind: .outgoing,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20010))),
                            Message("When I look in the mirror I see:",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20009))),
                            Message("A boy not a man",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20008))),
                            Message("The son of a father I refuse to understand",
                                    kind: .outgoing,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20007))),
                            Message("The \"brother\" of a brother like a wound I neglect",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20006))),
                            Message("The coward of a sister with the world I forget",
                                    kind: .outgoing,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20005))),
                            Message("The prodigal son, but I am yet to return",
                                    kind: .outgoing,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20004))),
                            Message("From a siege where I take refuge but I want to watch burn",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20003))),
                            Message("Your lover, your companion, your champion, your friend",
                                    kind: .outgoing,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20002))),
                            Message("The fortunate son who dwells in the city, With the poorest of the poor, still, I ask for your pity",
                                    kind: .outgoing,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20001))),
                            Message("And while there's a man who sleeps on the ice-cold streets. His godsend not in me, but in his cardboard: his sheets. Yet. I still see the same son ",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-20000)))
                           ]),

                           Conversation(name: "🐙", online: true, messages: [
                            Message("😀", kind: .incoming, status: .read, date: Date().addingTimeInterval(TimeInterval(-30009))),
                            Message("🦙", kind: .outgoing, status: .read, date: Date().addingTimeInterval(TimeInterval(-30008))),
                            Message("🐠🦕🦍", kind: .incoming, status: .read, date: Date().addingTimeInterval(TimeInterval(-30007))),
                            Message("🐃", kind: .outgoing, status: .read, date: Date().addingTimeInterval(TimeInterval(-30006))),
                            Message("☀️", kind: .incoming, status: .read, date: Date().addingTimeInterval(TimeInterval(-30005))),
                            Message("⚡️", kind: .incoming, status: .read, date: Date().addingTimeInterval(TimeInterval(-30004))),
                            Message("☃️", kind: .outgoing, status: .read, date: Date().addingTimeInterval(TimeInterval(-30003))),
                            Message("🍌", kind: .incoming, status: .read, date: Date().addingTimeInterval(TimeInterval(-30002))),
                            Message("🌮", kind: .incoming, status: .read, date: Date().addingTimeInterval(TimeInterval(-30001))),
                            Message("🥗", kind: .outgoing, status: .unread, date: Date().addingTimeInterval(TimeInterval(-30000)))
                           ]),
                           Conversation(name: "Wonder Woman", online: true, messages: [
                            Message("Don't you know there is Spider Man?",
                                    kind: .incoming,
                                    status: .unread,
                                    date: Date().addingTimeInterval(TimeInterval(-40000)))
                           ]),
                           Conversation(name: "Spider Man", online: true, messages: [
                            Message("Hello, cover me",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-95000)))
                           ]),
                           Conversation(name: "Elon", online: true, messages: [
                            Message("Starship launch tomorrow. Window opens at 9am.",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-600002))),
                            Message("Starship SN10 landed in one piece!",
                                    kind: .incoming,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-600001))),
                            Message("Starship to the moon",
                                    kind: .outgoing,
                                    status: .read,
                                    date: Date().addingTimeInterval(TimeInterval(-600000)))
                           ])
        )

        let offline = Array(arrayLiteral:
                                Conversation(name: "Marty", online: false, messages: [
                                    Message("Are you at office now? I have problem with documents. Need you help.",
                                            kind: .outgoing,
                                            status: .unread,
                                            date: Date().addingTimeInterval(TimeInterval(-90000)))
                                ]),
                            Conversation(name: "Ann with very looooooooooong second name", online: false, messages: [
                                Message("A navigation controller is a container view controller that manages one or more child view controllers in a navigation interface. In this type of interface, only one child view controller is visible at a time. Selecting an item in the view controller pushes a new view controller onscreen using an animation, thereby hiding the previous view controller. Tapping the back button in the navigation bar at the top of the interface removes the top view controller, thereby revealing the view controller underneath.",
                                        kind: .incoming,
                                        status: .read,
                                        date: Date().addingTimeInterval(TimeInterval(-1900)))
                            ]),
                            Conversation(name: "Mom", online: false, messages: [
                                Message("👋",
                                        kind: .incoming,
                                        status: .read,
                                        date: Date().addingTimeInterval(TimeInterval(-1800)))
                            ]),
                            Conversation(name: "Dad", online: false, messages: [
                                Message("Are you at office now?",
                                        kind: .outgoing,
                                        status: .read,
                                        date: Date().addingTimeInterval(TimeInterval(-1770)))
                            ]),
                            Conversation(name: "Brother", online: false, messages: [
                                Message("Будешь на выходных в городе?",
                                        kind: .outgoing,
                                        status: .unread,
                                        date: Date().addingTimeInterval(TimeInterval(-1750)))
                            ]),
                            Conversation(name: "🍕🍕🍕🍕🍕", online: false, messages: [
                                Message("Ваш заказ готовят. Доставим до 23:45",
                                        kind: .incoming,
                                        status: .read,
                                        date: Date().addingTimeInterval(TimeInterval(-1650))),
                                Message("Курьер направился к вам, пицца будет через 15 минут",
                                        kind: .incoming,
                                        status: .read,
                                        date: Date().addingTimeInterval(TimeInterval(-1600)))
                            ]),
                            Conversation(name: "Cat", online: false, messages: [
                                Message(nil,
                                        kind: .incoming,
                                        status: .unread,
                                        date: nil)
                            ]),
                            Conversation(name: nil, online: false, messages: [
                                Message("",
                                        kind: .incoming,
                                        status: .unread,
                                        date: nil)
                            ]),
                            Conversation(name: nil, online: false, messages: Array()),
                            Conversation(name: "Светлана В.", online: false, messages: Array()),
                            Conversation(name: "Batman", online: false, messages: [
                                Message("There is my Batmobile?",
                                        kind: .incoming,
                                        status: .unread,
                                        date: Date().addingTimeInterval(TimeInterval(-15500)))
                            ]),
                            Conversation(name: "Robin", online: false, messages: [
                                Message("Can I leave Batmobile in your garage",
                                        kind: .incoming,
                                        status: .read,
                                        date: Date().addingTimeInterval(TimeInterval(-15000)))
                            ]),
                            Conversation(name: "Джокер", online: false, messages: [
                                Message("😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈",
                                        kind: .outgoing,
                                        status: .unread,
                                        date: Date().addingTimeInterval(TimeInterval(-10000)))
                            ]),
                            Conversation(name: "Pavel Durov", online: false, messages: [
                                Message("Just install Telegramm on you phone, you don't need this app",
                                        kind: .incoming,
                                        status: .read,
                                        date: Date().addingTimeInterval(TimeInterval(-50001))),
                                Message("WhatsApp?",
                                        kind: .outgoing,
                                        status: .read,
                                        date: Date().addingTimeInterval(TimeInterval(-50000)))
                            ])
        )

        return online + offline
    }
}

