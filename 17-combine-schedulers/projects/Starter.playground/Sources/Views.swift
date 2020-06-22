/// Copyright (c) 2019 Razeware LLC
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

import SwiftUI
import Combine

struct EventValueView: View {
  let index: Int
  var body: some View {
    Text("\(self.index)")
      .padding(3.0)
      .frame(width: 28.0, height: 28.0)
      .allowsTightening(true)
      .minimumScaleFactor(0.1)
      .foregroundColor(.white)
      .background(Circle().fill(Color.blue))
      .fixedSize()
  }
}

struct EventCompletedView: View {
  var body: some View {
    Text("-")
      .padding(3.0)
      .frame(width: 28.0, height: 28.0)
      .foregroundColor(.white)
      .background(Circle().fill(Color.black))
  }
}

struct EventFailureView: View {
  var body: some View {
    Text("X")
      .padding(3.0)
      .frame(width: 28.0, height: 28.0)
      .foregroundColor(.white)
      .background(Circle().fill(Color.red))
  }
}

struct EventView: View {
  let data: RecorderData

  var body: some View {
    switch self.data.event {
    case .value:
      return AnyView(EventValueView(index: self.data.index))
    case .completion:
      return AnyView(EventCompletedView())
    case .failure:
      return AnyView(EventFailureView())
    }
  }
}

public typealias SetupClosure = (ThreadRecorder) -> AnyPublisher<RecorderData, Never>

public struct ThreadRecorderView: View {
  @ObservedObject public var recorder = ThreadRecorder()
  let title: String
  let setup: SetupClosure

  public init(title: String, setup: @escaping SetupClosure) {
    self.title = title
    self.setup = setup
  }

  public var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .fixedSize(horizontal: false, vertical: true)
      List(recorder.chains.reversed()) { chain in
        RecorderDataView(data: chain.data)
      }
    }.onAppear {
      self.recorder.start(with: self.setup)
    }
  }
}

struct RecorderDataView: View {
  let data: [RecorderData]

  var body: some View {
    HStack() {
      EventView(data: self.data[0])
      if self.data[0].event == .value {
        ForEach(data) { event in
          Rectangle()
            .frame(width: 16, height: 3, alignment: .center)
            .foregroundColor(.gray)
          if !event.context.isEmpty {
            Text(event.context)
              .padding([.leading, .trailing], 5)
              .padding([.top, .bottom], 2)
              .background(Color.gray)
              .foregroundColor(.white)
          }
          Text("Thread \(event.thread)")
        }
      }
    }
  }
}

/*:
 Copyright (c) 2019 Razeware LLC

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 distribute, sublicense, create a derivative work, and/or sell copies of the
 Software in any work that is designed, intended, or marketed for pedagogical or
 instructional purposes related to programming, coding, application development,
 or information technology.  Permission for such use, copying, modification,
 merger, publication, distribution, sublicensing, creation of derivative works,
 or sale is expressly withheld.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

