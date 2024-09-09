//
//  DeleteCoffeeVM.swift
//  mymx
//
//  Created by ice on 2024/8/3.
//

import Foundation
import Alamofire

class DeleteCoffeeVM: ObservableObject{

    func deleteCoffee(coffeeId: Int){
        print("deleteCoffee")
        let headers: HTTPHeaders = [
            "Authentication": "Bearer " + GlobalParams.token
        ]
        let parameters: [String: Any] = [
            "coffeeId": coffeeId
        ]
        AF.request(Urls.DELETE_COFFEE, method: .post, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: BaseResult<Bool>.self) {response in
                switch response.result{
                case .success(let res):
                    print(res)
                    if(res.data!){
                        print("delete coffee succeed: \(coffeeId)")
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
}