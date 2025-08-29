import SwiftUI

struct TabbarView: View {
    @State var page: Int = 0
    
    var body: some View {
        ZStack {
            ReelsFeedView()
            
            VStack {
                Spacer()
                
                HStack(spacing: 24) {
                    Button {
                        withAnimation {
                            page = 0
                        }
                    } label: {
                        Image("home")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .opacity(page == 0 ? 1 : 0.5)
                    }
                    
                    Button {
                        withAnimation {
                            page = 1
                        }
                    } label: {
                        Image("notif")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .opacity(page == 1 ? 1 : 0.5)
                    }
                    
                    Button {
                        withAnimation {
                            
                        }
                    } label: {
                        Image("add")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                    
                    Button {
                        withAnimation {
                            page = 2
                        }
                    } label: {
                        Image("messages")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .opacity(page == 2 ? 1 : 0.5)
                    }
                    
                    Button {
                        withAnimation {
                            page = 3
                        }
                    } label: {
                        Image("profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(10)
                .background(
                    CustomBlur.Blur(style: .dark)
                        .cornerRadius(100)
                )
                .padding(.bottom, 48)
            }
        }
    }
}
