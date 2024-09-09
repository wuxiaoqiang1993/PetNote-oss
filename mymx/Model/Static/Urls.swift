//
//  Urls.swift
//  mymx
//
//  Created by ice on 2024/6/17.
//

import Foundation

struct Urls {
    static let BASE_URL = "https://your-api-base-url.com/api"
    
    // Authentication
    static let LOGIN = BASE_URL + "/auth/login"
    static let GET_AUTH_CODE = BASE_URL + "/auth/getAuthCode"
    
    // Coffee endpoints
    static let GET_COFFEE_LIST = BASE_URL + "/coffee/list"
    static let ADD_COFFEE = BASE_URL + "/coffee/add"
    static let UPDATE_COFFEE = BASE_URL + "/coffee/update"
    static let DELETE_COFFEE = BASE_URL + "/coffee/delete"
    
    // User related
    static let UPDATE_USER_INFO = BASE_URL + "/user/update"
    
    // Image upload
    static let STS_COFFEE_IMAGE = BASE_URL + "/sts/coffeeImage"
    
    // Other endpoints (if needed)
    static let POETRY_WAETHER = BASE_URL + "/poetry/weather"
    static let CAT_FACT = "https://catfact.ninja/fact"
    static let GET_RANDOM_IMAGE = BASE_URL + "/image/random"
}
