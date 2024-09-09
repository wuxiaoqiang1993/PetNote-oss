//
//  ModelData.swift
//  mymx
//
//  Created by ice on 2024/6/17.
//

import Foundation
import Alamofire

class ModelData: ObservableObject {
    @Published var user: UserModel?
    @Published var coffeeList = [CoffeeModel]()
    @Published var error: AFError?
    
    init() {
        if let data = UserDefaults.standard.data(forKey: DataKeys.LOGIN_RESULT) {
            do {
                let decoder = JSONDecoder()
                let loginResult = try decoder.decode(LoginResult.self, from: data)
                self.user = loginResult.user
                GlobalParams.token = loginResult.token
            } catch {
                print("Unable to Decode LoginResult (\(error))")
            }
        }
    }
    
    func getCoffeeList(){
        print("getCoffeeList")
        // 使用 Alamofire 进行 GET 请求
        let headers: HTTPHeaders = [
            "Authentication": "Bearer " + GlobalParams.token
        ]
        AF.request(Urls.GET_COFFEE_LIST, headers: headers)
            .validate()
            .responseDecodable(of: BaseResult<[CoffeeModel]>.self) { response in
                switch response.result {
                case .success(let res):
                    // Handle the decoded object
                    if let coffeeList = res.data {
                        self.coffeeList = coffeeList
                    }
                case .failure(let error):
                    // Handle any errors
                    self.error = error
                    print("Request failed with error: \(error)")
                }
            }
    }
}


