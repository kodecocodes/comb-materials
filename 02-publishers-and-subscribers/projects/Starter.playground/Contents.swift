/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Combine
import _Concurrency

var subscriptions = Set<AnyCancellable>()

example(of: "Publisher") {
    
    let myNotif = Notification.Name("MyNotif")
    
    let publisher = NotificationCenter.default.publisher(for: myNotif, object: nil)
    
    let center = NotificationCenter.default
    
    let observer = center.addObserver(forName: myNotif, object: nil, queue: nil) { notif in
        print("Notification received!")
    }
    
    center.post(name: myNotif, object: nil)
    
    center.removeObserver(observer)
}

example(of: "Subscriber") {
    
    let myNotif = Notification.Name("MyNotif")
    let center = NotificationCenter.default
    
    let publisher = center.publisher(for: myNotif, object: nil)
    
    let subscription = publisher
        .sink { _ in
            print("Notif received from a publisher!")
        }
    
    center.post(name: myNotif, object: nil)
    
    subscription.cancel()
}

example(of: "Just") {
    
    // Just creates a publisher from a single value.
    let just = Just("Hello world!")
    
    _ = just.sink(receiveCompletion: {
        print("Received completion", $0)
    }, receiveValue: {
        print("Received value", $0)
    })
    
    
    _ = just.sink(receiveCompletion: {
        print("Received completion (another)", $0)
    }, receiveValue: {
        print("Received value (another)", $0)
    })
}

example(of: "assign(to:on:)") {
    
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }
    
    let object = SomeObject()
    
    let publisher = ["Hello", "world!"].publisher
    
    _ = publisher
        .assign(to: \.value, on: object)
}

example(of: "assign(to:)") {
    
    class SomeObject {
        @Published var value = 0
    }
    
    let object = SomeObject()
    
    object.$value
        .sink {
            print($0)
        }
    
    (0..<10).publisher
        .assign(to: &object.$value)
    
}
