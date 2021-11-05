//
//  CryptoService.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 05.11.2021.
//

import Foundation

class CryptoService {
    
    static let defaultLocationLimit = 100
    
    struct QueryParams {
        static let btcPriceQueryParams = "?ids=bitcoin&vs_currencies=usd&include_24hr_change=true"
    }
    
    enum Endpoints {
        
        static let baseUrl = "https://api.coingecko.com/api/v3/"
        
        case getBtcPrice
        
        var stringValue: String {
            switch self {
            case .getBtcPrice: return Endpoints.baseUrl + "simple/price" + QueryParams.btcPriceQueryParams
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getBtcPrice(completion: @escaping (BitcoinPrice?, Error?) -> Void) {
        let url = Endpoints.getBtcPrice.url
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let response = try decoder.decode(BitcoinPriceResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(response.bitcoin, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
}
