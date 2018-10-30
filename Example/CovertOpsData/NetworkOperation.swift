import Foundation
import CovertOps

struct NetworkOperationOutput<T> {
    let data: T?
    let error: Error?
}

struct None: Codable {}
struct NoReply: Codable {}

class NetworkOperation<OutputType: Codable, BodyType: Codable>: AsyncOperation<NetworkOperationOutput<OutputType>> {
    
    var baseUrl = URL(string: "https://jsonplaceholder.typicode.com")!
    
    enum Method: String {
        case get, post, put, patch, options, delete
    }
    
    let url: URL
    let method: Method
    let body: BodyType?
    
    init(method: Method, path: String, body: BodyType? = nil) {
        self.url = baseUrl.appendingPathComponent(path)
        self.body = body
        self.method = method
    }
    
    override func execute() {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        if let body = body {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try? encoder.encode(body)
        }
        
        let task = URLSession.shared.dataTask(
            with: urlRequest,
            completionHandler: { responseData, response, error in
                let decoder = JSONDecoder()
                if let error = error {
                    print("Error: \(error)")
                    self.finish(output: NetworkOperationOutput(data: nil, error: error))
                } else if let responseData = responseData,
                    let data = try? decoder.decode(OutputType.self, from: responseData) {
                    let output = NetworkOperationOutput(data: data, error: nil)
                    self.finish(output: output)
                } else {
                    let error = NSError(domain: "", code: 400, userInfo: [:]) as Error
                    print("Unkonwn error")
                    self.finish(output: NetworkOperationOutput(data: nil, error: error))
                }
            }
        )
        task.resume()
    }
}
