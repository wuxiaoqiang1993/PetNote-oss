//
//  AddCoffeeVM.swift
//  mymx
//
//  Created by ice on 2024/7/8.
//

import Foundation
import Combine
import Alamofire
import UIKit

class AddCoffeeVM: ObservableObject {
    private var isUpdate = false
    @Published var error: AFError?
    @Published var errorMsg = ""
    @Published var loading = false
    @Published var coffee = CoffeeModel()
    @Published var success = false
    
    init(isUpdate: Bool){
        self.isUpdate = isUpdate
    }
    
    func updateCoffee(coffee: CoffeeModel, image: UIImage?){
        errorMsg = ""
        if coffee.name.isEmpty {
            errorMsg = "请输入咖啡名称～"
            return
        }
        if !isUpdate && image == nil {
            errorMsg = "请为咖啡选择一张图片～"
            return
        }
        if coffee.description.count < 5 {
            errorMsg = "描述需多于 5 字～"
            return
        }
        
        print("addCoffee: \(coffee)")
        self.loading = true
        self.coffee = coffee
        if let img = image{
            self.getStsTokenThenUploadImage(image: img)
        }else{
            addCoffeeToServer()
        }
    }
    
    private func addCoffeeToServer(){
        print("addCoffeeToServer")
        print("is update: \(isUpdate)")
        // 使用 Alamofire 进行 GET 请求
        let headers: HTTPHeaders = [
            "Authentication": "Bearer " + GlobalParams.token
        ]
        AF.request(self.isUpdate ? Urls.UPDATE_COFFEE : Urls.ADD_COFFEE, method: .post, parameters: ["coffee": coffee], encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: BaseResult<CoffeeModel>.self) { response in
                print(response)
                self.loading = false
                switch response.result {
                case .success(let res):
                    // Handle the decoded object
                    if  let coffee = res.data {
                        self.coffee = coffee
                        print(coffee)
                        self.success = true
                    }else{
                        self.errorMsg = res.error ?? ""
                    }
                case .failure(let error):
                    // Handle any errors
                    self.error = error
                    self.errorMsg = error.errorDescription ?? "提交遇到了一点小问题，请重试。"
                    print("Request failed with error: \(error)")
                }
            }
    }
    
    // ... (rest of the methods remain the same, just replace 'pet' with 'coffee')
}