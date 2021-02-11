//
//  EmployeeModel.swift
//  RNSRestExample
//
//  Created by Mark Descalzo on 3/13/20.
//  Copyright © 2020 Ringneck Software, LLC. All rights reserved.
//

import Foundation

struct EmployeeModel: Codable {
    
    let id: Int
    let name: String
    let salary: Int
    let age: Int
    let profileImagePath: String
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "id"
        case name = "employee_name"
        case salary = "employee_salary"
        case age = "employee_age"
        case profileImagePath = "profile_image"
    }
}
