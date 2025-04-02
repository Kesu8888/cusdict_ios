//
//  testOndelete.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/26.
//

import SwiftUI

struct testOndelete: View {
    @State private var fruits = ["apple", "banana", "orange", "pineapple", "grapes", "peach"]
    @State private var fruits2 = ["apple", "banana", "orange", "pineapple", "grapes", "peach"]
//    @State private var deleteFruitIndexSet = IndexSet()
    @State private var showDeleteFruitAlert = false
    
    var body: some View {
        List {
            Section {
                Text("Nothing")
                    .listRowSeparator(.hidden)
                ForEach(fruits, id: \.self) { fruit in
                    Text(fruit)
                }
                .onDelete { indexSet in
                    fruits.remove(atOffsets: indexSet)
//                    if let index = indexSet.first {
//                        let fruit = fruits[index]
//                        print("Deleting fruit: \(fruit)")
//                        fruits2.removeAll(where: { $0 == fruit })
//                    }
                }
            }
//            .onChange(of: fruits2, {
//                fruits = fruits2
//            })
            
//            Section {
//                ForEach(fruits2.indices, id: \.self) { index in
//                    Text(fruits2[index])
//                }
//            }
        }
        // combine with onDelete modifier to make sure the delete button always exist
//        .environment(\.editMode, Binding.constant(EditMode.active))
    }
}

#Preview {
    testOndelete()
}
