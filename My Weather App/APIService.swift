import Foundation

public class APIService {
    public static let shared = APIService()
    // Define an enumeration for API-related errors
    public enum APIError: Error {
        case error(_ errorString: String)
    }
    public func getJSON<T: Decodable> (urlString: String,
                                       dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                                       keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                  completion: @escaping (Result<T,APIError>) -> Void) {
        // Validate and create a URL from the given string
        guard let url = URL(string: urlString) else {
            completion(.failure(.error(NSLocalizedString("Error: Invalid URL", comment: ""))))
            return
        }
        // Create a URLRequest with the specified URL
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // Handle network errors
                completion(.failure(.error("Error: \(error.localizedDescription)")))
                return
            }
            // Ensure that data is available
            guard let data = data else {
                completion(.failure(.error(NSLocalizedString("Error: Data us corrupt", comment: ""))))
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            do {
                // Decode the JSON data into the specified generic type
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
                return
            } catch let decodingError {
                // Handle decoding errors
                completion(.failure(APIError.error("Error: \(decodingError.localizedDescription)")))
                return
            }
        }.resume()
    }
}

