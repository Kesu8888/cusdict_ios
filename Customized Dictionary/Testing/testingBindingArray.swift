//
//  testingBindingArray.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/19.
//

import SwiftUI

// conclusion:
// 1. Binding value change will not initialize the struct again using the initializer unless some of the statement in the initializer uses the binding value to initialize. e.g., binding value in testView and line 2 in initializer will cause the struct to initialize again.
struct testingBindingArray: View {
    @State var value = 2
    
    var body: some View {
        testView(value: $value, myValue: value)
    }
}

fileprivate struct testView: View {
    @Binding var value: Int
    @State var myValue: Int
    
    init(value: Binding<Int>, myValue: Int) {
        self._value = value
//        self.myValue = value.wrappedValue + 5
        self.myValue = myValue
    }
    
    var body: some View {
        Text("value is \(value)")
        Text("myValue is \(myValue)")
        Button(action: {
            value += 1
//            myValue += 1
        }, label: {
            Text("Add value")
        })
        .onAppear(perform: {
            value += 1
        })
    }
}

#Preview {
    testingBindingArray()
}
