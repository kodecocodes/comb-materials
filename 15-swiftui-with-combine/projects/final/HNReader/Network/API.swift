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

import Foundation
import Combine
import SwiftUI

struct API {
  
  /// API Errors.
  enum Error: LocalizedError, Identifiable {
    var id: String { localizedDescription }
    
    case addressUnreachable(URL)
    case invalidResponse
    
    var errorDescription: String? {
      switch self {
      case .invalidResponse: return "The server responded with garbage."
      case .addressUnreachable(let url): return "\(url.absoluteString) is unreachable."
      }
    }
  }
  
  /// API endpoints.
  enum EndPoint {
    static let baseURL = URL(string: "https://hacker-news.firebaseio.com/v0/")!
    
    case stories
    case story(Int)
    
    var url: URL {
      switch self {
      case .stories:
        return EndPoint.baseURL.appendingPathComponent("newstories.json")
      case .story(let id):
        return EndPoint.baseURL.appendingPathComponent("item/\(id).json")
      }
    }
  }

  /// Maximum number of stories to fetch (reduce for lower API strain during development).
  var maxStories = 10

  /// A shared JSON decoder to use in calls.
  private let decoder = JSONDecoder()

  private let apiQueue = DispatchQueue(label: "API", qos: .default, attributes: .concurrent)
  
  // Add your API code here.
  func story(id: Int) -> AnyPublisher<Story, Error> {
    URLSession.shared.dataTaskPublisher(for: EndPoint.story(id).url)
      .receive(on: apiQueue)
      .map { $0.0 }
      .decode(type: Story.self, decoder: decoder)
      .catch { _ in Empty() }
      .eraseToAnyPublisher()
  }
  
  func mergedStories(ids storyIDs: [Int]) -> AnyPublisher<Story, Error> {
    let storyIDs = Array(storyIDs.prefix(maxStories))
    
    precondition(!storyIDs.isEmpty)

    let initialPublisher = story(id: storyIDs[0])
    let remainder = Array(storyIDs.dropFirst())
    
    return remainder.reduce(initialPublisher) { (combined, id) -> AnyPublisher<Story, Error> in
      return combined.merge(with: story(id: id))
        .eraseToAnyPublisher()
    }
  }
  
  func stories() -> AnyPublisher<[Story], Error> {
    URLSession.shared.dataTaskPublisher(for: EndPoint.stories.url)
      .map { $0.0 }
      .decode(type: [Int].self, decoder: decoder)
      .mapError { error in
        switch error {
        case is URLError:
          return Error.addressUnreachable(EndPoint.stories.url)
        default: return Error.invalidResponse
        }
      }
      .filter { !$0.isEmpty }
      .flatMap { storyIDs in
        return self.mergedStories(ids: storyIDs)
      }
      .scan([], { (stories, story) -> [Story] in
        return stories + [story]
      })
      .map { stories in
        return stories.sorted()
      }
      .eraseToAnyPublisher()
  }
}
