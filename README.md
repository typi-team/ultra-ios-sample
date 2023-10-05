# UltraCore

[![CI Status](https://img.shields.io/travis/rakish.shalkar@gmail.com/UltraCore.svg?style=flat)](https://travis-ci.org/rakish.shalkar@gmail.com/UltraCore)
[![Version](https://img.shields.io/cocoapods/v/UltraCore.svg?style=flat)](https://cocoapods.org/pods/UltraCore)
[![License](https://img.shields.io/cocoapods/l/UltraCore.svg?style=flat)](https://cocoapods.org/pods/UltraCore)
[![Platform](https://img.shields.io/cocoapods/p/UltraCore.svg?style=flat)](https://cocoapods.org/pods/UltraCore)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
```


## Installation

UltraCore is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'UltraCore', :git => "https://github.com/typi-team/ultra-ios.git"
```

## How to use

### How to display the chat page:

You need to call `update(sid token)` and wait for a response in the callback, which can return an error. If there is no error, you should call `entryConversationsViewController`, which returns a `UIViewController` that you can show in your `UIViewController` stack.

```swift

update(sid: UserDefaults.standard.string(forKey: "K_SID") ?? "") { [weak self] error in
    guard let `self` = self else { return }
    DispatchQueue.main.async {
        if let error = error {
            self.present(viewController: UltraCoreSettings.entrySignUpViewController(), animated: true)
        } else {
            self.navigationContoller?.push(UltraCoreSettings.entryConversationsViewController())
        }        
    }
}
```

### How to handle push notifications:

UltraCore can handle the following notification attributes: `[msg_id, chat_id, sender_id]`

You need to pass a dictionary to `handleNotification(data: [AnyHashable: Any], callback: @escaping (UIViewController?) -> Void)`. If the handling is successful, return a `UIViewController` that you can show in your UIViewController stack.

```swift
// Обработка нажатия на уведомление
UltraCoreSettings.handleNotification(data: response.notification.request.content.userInfo) { viewController in
    guard let viewController = viewController else { return }
    self.window?.rootViewController?.present(UINavigationController(rootViewController: viewController), animated: true)
}
```   
### How to set server config:

```swift
    struct ServerConfig: ServerConfigurationProtocol {
        var portOfServer: Int = 443
        var pathToServer: String = "ultra-dev.typi.team"
    }

    UltraCoreSettings.set(server: ServerConfig())    
}
```   

### How to set UIStyleGuide:

```swift
    struct Colors: TwiceColor {
        var defaultColor: UIColor = .red
        var darkColor: UIColor = .white
    }

    UltraCoreStyle.controllerBackground = Colors()    
}
```        

### Updating SID:

To update the token for the `UltraCore` application to function properly, you need to call the method `update(sid token: String, with callback: @escaping (Error?) -> Void)`.


```swift
UltraCoreSettings.update(sid: newSid, with: {_ in })
```

###  How to Replace Pages with Yours
To implement this approach, you need to implement the protocol `UltraCoreSettingsDelegate`. 


```swift
/// Метод для реализаций страницы контактов
/// - Parameters:
///   - callback: для сохранения контактов, можно использовать для сохранения массива контактной книги или одиночной сохранения контакта, перед началом переписки
///   - userCallback: для начало переписки, перед вызовом надо скрыть ваш контроллер
/// - Returns: Контроллер для отображения ваших контактов или передайте nil и отобразитсья личный контроллер

func contactsViewController(callback: @escaping UltraCore.ContactsCallback, userCallback: @escaping UltraCore.UserIDCallback) -> UIViewController?
```

Similarly, you can replace the money transfer page, you need to transmit

```swift
public struct MoneyTransfer {
    let amout: Int64
    let currency: String
    let transactionID: String
}
```

The one that needs to be passed to the delegate method

```swift 
/// Метод для реализаций страницы передачи денег
/// - Parameter callback: для передачи сообщения о переводе денег
/// - Returns: Контроллер для передачи денег с указаннием суммы
func moneyViewController(callback: @escaping MoneyCallback) -> UIViewController?
```

```swift

```
