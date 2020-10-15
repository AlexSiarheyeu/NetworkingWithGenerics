import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

struct Comment: Codable {
    let userId: Int
    let title: String
}

struct User: Codable {
    let id: Int
    let name: String
}

enum HTTPMethod<Body> {
    case get
    case post(Body)
}

extension HTTPMethod {
    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}

struct Resource<A> {
    var urlRequest: URLRequest
    let parse: (Data) -> A?
}

extension Resource where A: Decodable {
    
    init(get url: URL) {
        self.urlRequest = URLRequest(url: url)
        self.parse = { data in
            try? JSONDecoder().decode(A.self, from: data)
        }
    }
    
    init<Body: Encodable>(url: URL, method: HTTPMethod<Body>) {
        self.urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.method
        switch method {

        case .get: ()
        case .post(let body):
            self.urlRequest.httpBody = try! JSONEncoder().encode(body)
        }
        self.parse = { data in
             try? JSONDecoder().decode(A.self, from: data)

        }
    }
}

extension URLSession {
    func load<A>(_ resource: Resource<A>, completion: @escaping (A?) -> ()) {
        dataTask(with: resource.urlRequest) { data, _, _ in
            completion(data.flatMap(resource.parse))
        }.resume()
    }
}

let posts = Resource<[Comment]>(get: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
let users = Resource<[User]>(get: URL(string: "https://jsonplaceholder.typicode.com/users")!)

URLSession.shared.load(users) { print($0) }
