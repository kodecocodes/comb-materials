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

// 1
import Foundation
import SwiftUI
import CoreData
import ChuckNorrisJokesModel

// 2
extension JokeManagedObject {
  // 3
  static func save(joke: Joke, inViewContext viewContext: NSManagedObjectContext) {
    // 4
    guard joke.id != "error" else { return }
    // 5
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
      entityName: String(describing: JokeManagedObject.self))
    // 6
    fetchRequest.predicate = NSPredicate(format: "id = %@", joke.id)
    
    // 7
    if let results = try? viewContext.fetch(fetchRequest),
       let existing = results.first as? JokeManagedObject {
      existing.value = joke.value
      existing.categories = joke.categories as NSArray
      existing.languageCode = joke.languageCode
      existing.translationLanguageCode = joke.translationLanguageCode
      existing.translatedValue = joke.translatedValue
    } else {
      // 8
      let newJoke = self.init(context: viewContext)
      newJoke.id = joke.id
      newJoke.value = joke.value
      newJoke.categories = joke.categories as NSArray
      newJoke.languageCode = joke.languageCode
      newJoke.translationLanguageCode = joke.translationLanguageCode
      newJoke.translatedValue = joke.translatedValue
    }
    
    // 9
    do {
      try viewContext.save()
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
}

extension Collection where Element == JokeManagedObject, Index == Int {
  // 1
  func delete(at indices: IndexSet, inViewContext viewContext: NSManagedObjectContext) {
    // 2
    indices.forEach { index in
      viewContext.delete(self[index])
    }
    
    // 3
    do {
      try viewContext.save()
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
}
