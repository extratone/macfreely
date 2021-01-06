import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
        NavigationView {
            #if os(macOS)
            CollectionListView()
                .toolbar {
                    Button(
                        action: {
                            NSApp.keyWindow?.contentViewController?.tryToPerform(
                                #selector(NSSplitViewController.toggleSidebar(_:)), with: nil
                            )
                        },
                        label: { Image(systemName: "sidebar.left") }
                    )
                    .help("Toggle the sidebar's visibility.")
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.model.selectedPost = nil
                        }
                        let managedPost = WFAPost(context: LocalStorageManager.persistentContainer.viewContext)
                        managedPost.createdDate = Date()
                        managedPost.title = ""
                        managedPost.body = ""
                        managedPost.status = PostStatus.local.rawValue
                        managedPost.collectionAlias = nil
                        switch model.preferences.font {
                        case 1:
                            managedPost.appearance = "sans"
                        case 2:
                            managedPost.appearance = "wrap"
                        default:
                            managedPost.appearance = "serif"
                        }
                        if let languageCode = Locale.current.languageCode {
                            managedPost.language = languageCode
                            managedPost.rtl = Locale.characterDirection(forLanguage: languageCode) == .rightToLeft
                        }
                        withAnimation {
                            DispatchQueue.main.async {
                                self.model.selectedPost = managedPost
                            }
                        }
                    }, label: { Image(systemName: "square.and.pencil") })
                    .help("Create a new local draft.")
                }
            #else
            CollectionListView()
            #endif

            #if os(macOS)
            ZStack {
                PostListView(selectedCollection: nil, showAllPosts: false) //model.account.isLoggedIn)
                if model.isProcessingRequest {
                    ZStack {
                        Color(NSColor.controlBackgroundColor).opacity(0.75)
                        ProgressView()
                    }
                }
            }
            #else
            PostListView(selectedCollection: nil, showAllPosts: model.account.isLoggedIn)
            #endif

            Text("Select a post, or create a new local draft.")
                .foregroundColor(.secondary)
        }
        .environmentObject(model)

        #if os(iOS)
        EmptyView()
            .sheet(
                isPresented: $model.isPresentingSettingsView,
                onDismiss: { model.isPresentingSettingsView = false },
                content: {
                    SettingsView()
                        .environmentObject(model)
                }
            )
            .alert(isPresented: $model.isPresentingNetworkErrorAlert, content: {
                Alert(
                    title: Text("Connection Error"),
                    message: Text("""
                        There is no internet connection at the moment. Please reconnect or try again later.
                        """),
                    dismissButton: .default(Text("OK"), action: {
                        model.isPresentingNetworkErrorAlert = false
                    })
                )
            })
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()

        return ContentView()
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
