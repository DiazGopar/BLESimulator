import SwiftUI
import CoreBluetooth

@main
struct BLESimulatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(initialConfigFile: getInitialConfigFile())
                .frame(minWidth: 600, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
        }
        .windowResizability(.contentSize)
    }
    
    private func getInitialConfigFile() -> String? {
        let arguments = CommandLine.arguments
        // Buscar argumento que termine en .json
        for arg in arguments {
            if arg.hasSuffix(".json") {
                return arg
            }
        }
        return nil
    }
}
