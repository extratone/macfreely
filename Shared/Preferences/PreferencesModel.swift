import SwiftUI

class PreferencesModel: ObservableObject {
    private let defaults = UserDefaults.shared

    /* We're stuck dropping into AppKit/UIKit to set light/dark schemes for now,
     * because setting the .preferredColorScheme modifier on views in SwiftUI is
     * currently unreliable.
     *
     * Feedback submitted to Apple:
     *
     * FB8382883: "On macOS 11β4, preferredColorScheme modifier does not respect .light ColorScheme"
     * FB8383053: "On iOS 14β4/macOS 11β4, it is not possible to unset preferredColorScheme after setting
     *              it to either .light or .dark"
     */

    #if os(iOS)
    @available(iOSApplicationExtension, unavailable)
    var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }
    #endif

    @available(iOSApplicationExtension, unavailable)
    @Published var selectedColorScheme: ColorScheme?

    @available(iOSApplicationExtension, unavailable)
    @Published var appearance: Int = 0 {
        didSet {
            switch appearance {
            case 1:
//                selectedColorScheme = .light
                #if os(macOS)
                NSApp.appearance = NSAppearance(named: .aqua)
                #else
                window?.overrideUserInterfaceStyle = .light
                #endif
            case 2:
//                selectedColorScheme = .dark
                #if os(macOS)
                NSApp.appearance = NSAppearance(named: .darkAqua)
                #else
                window?.overrideUserInterfaceStyle = .dark
                #endif
            default:
//                selectedColorScheme = .none
                #if os(macOS)
                NSApp.appearance = nil
                #else
                window?.overrideUserInterfaceStyle = .unspecified
                #endif
            }

            defaults.set(appearance, forKey: WFDefaults.colorSchemeIntegerKey)
        }
    }
    @Published var font: Int = 0 {
        didSet {
            defaults.set(font, forKey: WFDefaults.defaultFontIntegerKey)
        }
    }
}
