//
//  testMultiArray.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/31.
//

import SwiftUI

struct testMultiArray: View {
    @State private var fruitsArray: [[String]] = [
        ["apple", "banana", "blueBerry", "Cherry"],
        ["Dragon Fruit", "Durian", "Dates"],
        ["Lemon", "lime", "Kiwi"]
    ]
    
    @State private var currentArray: Int = 0
    @State private var msg: String = ""
    
    var body: some View {
        List {
            Section {
                Text("\(currentArray)")
            }
            
            Section {
                HStack {
                    ForEach(fruitsArray.indices, id: \.self) { index in
                        Button(action: {
                            currentArray = index
                        }, label: {
                            Text("fruit \(index)")
                        })
                        .buttonStyle(.borderless)
                    }
                }
            }
            
            Section {
                ForEach(fruitsArray[currentArray], id: \.self) { fruit in
                    Text(fruit)
                }
                .onDelete {indexSet in
                    fruitsArray[currentArray].remove(atOffsets: indexSet)
                }
            }
            
            Section {
                Button(action: {
                    let number = Int.random(in: 0..<3)
                    fruitsArray[number].append("new fruit")
                    msg = "fruit \(number) add new fruit!"
                }, label: {
                    Text("random add fruit")
                })
            }
            
            Section {
                Text(msg)
            }
        }
    }
}

//struct testSet: View {
//    @State private var fruits: [String: [String]]
//    
//    init() {
//        fruits.
//    }
//    
//    var body: some View {
//        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
//    }
//}

#Preview {
    testMultiArray()
}
