//
//  testHideAnimation.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/4/1.
//

import SwiftUI

struct testHideAnimation: View {
    @State private var fruit = ""
    @State private var fruits = ["apple", "banana", "orange"]
    
    var body: some View {
        VStack {
            HStack {
                ForEach(fruits, id: \.self) { f in
                    Button(action: {
                        withAnimation {
                            fruit = f
                        }
                    }, label: {
                        Text(f)
                    })
                }
            }
        }
        
        ForEach(fruits, id: \.self) { f in
            if fruit == f {
                Text(f)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .transition(.scale)
            }
        }
        
        Button(action: {
            let removeIndex = fruits.firstIndex(where: { $0 == fruit }) ?? 0
            var index = 0
            if index == fruits.count - 1 {
                index = removeIndex - 1
            } else {
                index = removeIndex + 1
            }
            var newFruit: String = ""
            if fruits.count == 1 {
                newFruit = ""
            } else {
                newFruit = fruits[index]
            }
            
            withAnimation {
                fruit = newFruit
            }
            fruits.remove(at: removeIndex)
        }, label: {
            Text("delete")
        })
    }
}

#Preview {
    testHideAnimation()
}
