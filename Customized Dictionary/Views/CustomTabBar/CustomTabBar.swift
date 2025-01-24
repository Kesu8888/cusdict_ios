//
//  CustomTabBar.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/18.
//

import SwiftUI

enum Mode {
    case list
    case search
    case play
    case store
    case profile
}

struct CustomTabBar: View {
    @Binding var selectedMode: Mode
    
    var body: some View {
        VStack {
            Divider()
            Spacer()
                .frame(height: 20)
            HStack(spacing: 50) {
                Button(action: {
                    withAnimation {
                        selectedMode = .list
                    }
                }) {
                    Image(systemName: "book")
                        .font(.system(size: 24))
                        .foregroundColor(selectedMode == .list ? .blue : .black)
                        .scaleEffect(selectedMode == .list ? 1.2 : 1.0)
                }
                
                Button(action: {
                    withAnimation {
                        selectedMode = .search
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24))
                        .foregroundColor(selectedMode == .search ? .blue : .black)
                        .scaleEffect(selectedMode == .search ? 1.2 : 1.0)
                }
                
                Button(action: {
                    withAnimation {
                        selectedMode = .play
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 34, height: 34)
                            .overlay(
                                Circle()
                                    .stroke(selectedMode == .play ? Color.blue : Color.black, lineWidth: 2))
                        
                        Image(systemName: "play")
                            .font(.system(size: 24))
                            .foregroundColor(selectedMode == .play ? .blue : .black)
                            .offset(x: 1)
                    }
                    .scaleEffect(selectedMode == .play ? 1.2 : 1.0)
                }
                
                Button(action: {
                    withAnimation {
                        selectedMode = .store
                    }
                }) {
                    Image(systemName: "storefront")
                        .font(.system(size: 24))
                        .foregroundColor(selectedMode == .store ? .blue : .black)
                        .scaleEffect(selectedMode == .store ? 1.2 : 1.0)
                }
                
                Button(action: {
                    withAnimation {
                        selectedMode = .profile
                    }
                }) {
                    Image(systemName: "person")
                        .font(.system(size: 24))
                        .foregroundColor(selectedMode == .profile ? .blue : .black)
                        .scaleEffect(selectedMode == .profile ? 1.2 : 1.0)
                }
            }
            
            Spacer()
                .frame(height: 48)
        }
        .background(Color.white)
        .frame(height: 102)
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBar(selectedMode: .constant(.list))
        }
    }
}
