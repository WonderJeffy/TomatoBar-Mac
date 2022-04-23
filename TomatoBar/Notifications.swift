import UserNotifications

enum TBNotification {
    enum Category: String {
        case restStarted, restFinished
    }

    enum Action: String {
        case skipRest
    }
}

typealias TBNotificationHandler = (TBNotification.Action) -> Void

class TBNotificationCenter: NSObject, UNUserNotificationCenterDelegate {
    private var center = UNUserNotificationCenter.current()
    private var handler: TBNotificationHandler?
    private var disabled = false

    override init() {
        super.init()

        center.requestAuthorization(
            options: [.alert]
        ) { _, error in
            if error != nil {
                self.disabled = true
                print("Error requesting notification authorization: \(error!)")
            }
        }

        center.delegate = self

        let actionSkipRest = UNNotificationAction(
            identifier: TBNotification.Action.skipRest.rawValue,
            title: "Skip",
            options: []
        )
        let restStartedCategory = UNNotificationCategory(
            identifier: TBNotification.Category.restStarted.rawValue,
            actions: [actionSkipRest],
            intentIdentifiers: []
        )
        let restFinishedCategory = UNNotificationCategory(
            identifier: TBNotification.Category.restFinished.rawValue,
            actions: [],
            intentIdentifiers: []
        )

        center.setNotificationCategories([
            restStartedCategory,
            restFinishedCategory,
        ])
    }

    public func setActionHandler(handler: @escaping TBNotificationHandler) {
        self.handler = handler
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler _: @escaping () -> Void)
    {
        if handler != nil {
            if let action = TBNotification.Action(rawValue: response.actionIdentifier) {
                handler!(action)
            }
        }
    }

    public func send(title: String, body: String, category: TBNotification.Category) {
        if disabled {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = category.rawValue
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        center.add(request) { error in
            if error != nil {
                print("Error adding notification: \(error!)")
            }
        }
    }
}
