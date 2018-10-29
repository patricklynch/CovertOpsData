import Foundation
import CovertOps

struct NetworkOperationOutput<T> {
    let data: T?
    let error: Error?
}

class NetworkOperation<T: Codable>: AsyncOperation<NetworkOperationOutput<T>> {
    
    let url: URL
    var baseUrl = URL(string: "https://jsonplaceholder.typicode.com")!
    
    init(apiPath: String) {
        self.url = baseUrl.appendingPathComponent(apiPath)
    }
    
    override func execute() {
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(
            with: urlRequest,
            completionHandler: { responseData, response, error in
                let decoder = JSONDecoder()
                if let error = error {
                    print("Error: \(error)")
                    self.finish(output: NetworkOperationOutput(data: nil, error: error))
                } else if let responseData = responseData,
                    let data = try? decoder.decode(T.self, from: responseData) {
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
