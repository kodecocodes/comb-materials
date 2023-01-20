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

example(of: "Custom Subscriber") {
    
    let publisher = (1...6).publisher
    
    // custom subscriber
    final class IntSubscriber: Subscriber {
        
        // receive int input and never receive error
        typealias Input = Int
        typealias Failure = Never
        
        // called by publisher,receive to max 3 request
        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }
        
        // .none = max(0)
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    
    publisher.subscribe(subscriber)
    
}

/*
example(of: "Future") {
    func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
        Future<Int, Never> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                promise(.success(integer + 1))
            }
            print("Original")
        }
    }
    
    let future = futureIncrement(integer: 1, afterDelay: 3)
    
    future
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    future
        .sink(receiveCompletion: { print("second", $0) }, receiveValue: { print("second", $0) })
        .store(in: &subscriptions)
    
}
 */

example(of: "PassthroughSubject") {
    
    enum MyError: Error {
        case test
    }
    
    final class StringSubscriber: Subscriber {
        
        typealias Input = String
        typealias Failure = MyError
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Received value", input)
            
            return input == "World" ? .max(1) : .none
        }
        
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion", completion)
        }
    }
    
    
    let subscriber = StringSubscriber()
    
    let subject = PassthroughSubject<String, MyError>()
    
    subject.subscribe(subscriber)
    
    let subscription = subject
        .sink(receiveCompletion: { completion in
            print("Received completion (sink)", completion)
        },
        receiveValue: { value in
            print("Received value (sink)", value)
            
        })
    
    subject.send("Hello")
    subject.send("World")
    subscription.cancel()
    subject.send("Still there?")
    subject.send(completion: .failure(MyError.test))
    subject.send(completion: .finished)
    subject.send("How about another one?")

}

example(of: "CurrentValueSubject") {
    
    var subscriptions = Set<AnyCancellable>()
  
    let subject = CurrentValueSubject<Int, Never>(0)
  
    subject
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    subject.send(1)
    subject.send(2)

    subject.value = 3
    print(subject.value)

    subject
      .sink(receiveValue: { print("Second subscription:", $0) })
      .store(in: &subscriptions)
}

