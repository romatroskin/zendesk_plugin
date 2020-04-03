import Flutter
import UIKit
import ZendeskCoreSDK
import MessagingSDK
import MessagingAPI
import SupportSDK
import SupportProvidersSDK
import AnswerBotSDK
import AnswerBotProvidersSDK

public class SwiftZendeskPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "zendesk_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftZendeskPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? Dictionary<String, Any>
    if(call.method == "init") {
        initialize(zendeskUrl: arguments!["zendeskUrl"] as! String, appId: arguments!["appId"] as! String, clientId: arguments!["clientId"] as! String)
        result(nil)
    } else if(call.method == "setAnonymousIdentity") {
        setAnonymousIdentity(name: arguments!["name"] as! String, email: arguments!["email"] as! String)
        result(nil)
    } else if(call.method == "setJWTIdentity") {
        setJWTIdentity(jwtIdentifier: arguments!["jwtIdentifier"] as! String)
        result(nil)
    } else if(call.method == "showMessagingActivity") {
        showMessagingActivity(withAnswerBotEngine: arguments!["withAnswerBotEngine"] as! Bool, withSupportEngine: arguments!["withSupportEngine"] as! Bool)
        result(nil)
    } else if(call.method == "showHelpCenterActivity") {
        showHelpCenterActivity(withAnswerBotEngine: arguments!["withAnswerBotEngine"] as! Bool, withSupportEngine: arguments!["withSupportEngine"] as! Bool)
        result(nil)
    } else if(call.method == "showViewArticleActivity") {
        showViewArticleActivity(articleId: arguments!["articleId"] as! String, withAnswerBotEngine: arguments!["withAnswerBotEngine"] as! Bool, withSupportEngine: arguments!["withSupportEngine"] as! Bool)
    } else if(call.method == "showRequestActivity") {
        showRequestActivity()
    } else if(call.method == "showRequestListActivity") {
        showRequestListActivity()
    } else {
        result("iOS " + UIDevice.current.systemVersion)
    }
  }
    
  private func initialize(zendeskUrl: String, appId: String, clientId: String) {
    Zendesk.initialize(appId: appId, clientId: clientId, zendeskUrl: zendeskUrl)
  }
    
  private func setAnonymousIdentity(name: String, email: String) {
    let identity = Identity.createAnonymous(name: name, email: email)
    Zendesk.instance?.setIdentity(identity)
    
    Support.initialize(withZendesk: Zendesk.instance)
    AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)
  }
    
  private func setJWTIdentity(jwtIdentifier: String) {
    let identity = Identity.createJwt(token: jwtIdentifier)
    Zendesk.instance?.setIdentity(identity)
    
    Support.initialize(withZendesk: Zendesk.instance)
    AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)
  }
    
  private func showMessagingActivity(withAnswerBotEngine: Bool, withSupportEngine: Bool) {
    let rootViewController = UIApplication.shared.delegate?.window??.rootViewController!
    do {
        let answerBotEngine = try AnswerBotEngine.engine()
        let supportEngine = try SupportEngine.engine()
        let viewController = try Messaging.instance.buildUI(engines: [answerBotEngine, supportEngine])
        let navController = UINavigationWrapper(rootViewController: viewController)
        rootViewController?.present(navController, animated: true)
    } catch {
        print("Unexpected error: \(error).")
    }
  }
    
    private func showHelpCenterActivity(withAnswerBotEngine: Bool, withSupportEngine: Bool) {
        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController!
        do {
            let answerBotEngine = try AnswerBotEngine.engine()
            let supportEngine = try SupportEngine.engine()
            
            let config = HelpCenterUiConfiguration()
            config.engines = [answerBotEngine, supportEngine]
            let viewController = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [config])
            let navController = UINavigationWrapper(rootViewController: viewController)
            rootViewController?.present(navController, animated: true)
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    private func showViewArticleActivity(articleId: String, withAnswerBotEngine: Bool, withSupportEngine: Bool) {
        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController!
        do {
            let answerBotEngine = try AnswerBotEngine.engine()
            let supportEngine = try SupportEngine.engine()
            
            let config = HelpCenterUiConfiguration()
            config.engines = [answerBotEngine, supportEngine]
            
            let viewController = HelpCenterUi.buildHelpCenterArticleUi(withArticleId: articleId, andConfigs: [config])
            let navController = UINavigationWrapper(rootViewController: viewController)
            rootViewController?.present(navController, animated: true)
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    private func showRequestActivity() {
        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController!
        
        let viewController = RequestUi.buildRequestUi()
        
        let navController = UINavigationWrapper(rootViewController: viewController)
        rootViewController?.present(navController, animated: true)
    }
    
    private func showRequestListActivity() {
        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController!
        
        let viewController = RequestUi.buildRequestList()
        
        let navController = UINavigationWrapper(rootViewController: viewController)
        rootViewController?.present(navController, animated: true)
    }
}
