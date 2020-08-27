import SwiftUI

struct PostEditorView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: Post

    @State private var isNewPost = false
    @State private var title = ""
    var body: some View {
        VStack {
            TextEditor(text: $title)
                .font(.title)
                .frame(height: 100)
                .onChange(of: title) { _ in
                    if post.status == .published && post.wfPost.title != title {
                        post.status = .edited
                    }
                    post.wfPost.title = title
                }
            TextEditor(text: $post.wfPost.body)
                .font(.body)
                .onChange(of: post.wfPost.body) { _ in
                    if post.status == .published {
                        post.status = .edited
                    }
                }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .status) {
                PostStatusBadgeView(post: post)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    model.publish(post: post)
                    post.status = .published
                }, label: {
                    Image(systemName: "paperplane")
                })
            }
        }
        .onAppear(perform: {
            title = post.wfPost.title ?? ""
            checkIfNewPost()
            if self.isNewPost {
                addNewPostToStore()
            }
        })
    }

    private func checkIfNewPost() {
        self.isNewPost = !model.store.posts.contains(where: { $0.id == post.id })
    }

    private func addNewPostToStore() {
        withAnimation {
            model.store.add(post)
            self.isNewPost = false
        }
    }
}

struct PostEditorView_NewDraftPreviews: PreviewProvider {
    static var previews: some View {
        PostEditorView(post: Post())
            .environmentObject(WriteFreelyModel())
    }
}

struct PostEditorView_ExistingPostPreviews: PreviewProvider {
    static var previews: some View {
        PostEditorView(post: testPostData[0])
            .environmentObject(WriteFreelyModel())
    }
}