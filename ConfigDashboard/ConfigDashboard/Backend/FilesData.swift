//
//  FilesData.swift
//  ConfigDashboard
//
//  Created by Alok Sahay on 10.10.2024.
//

import Foundation

struct ConfigFileData: Codable {
    let id: String
    let name: String
    let cid: String
    let createdAt: String
    let size: Int
    let numberOfFiles: Int
    let mimeType: String
    let userId: String
    let groupId: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case cid
        case createdAt = "created_at"
        case size
        case numberOfFiles = "number_of_files"
        case mimeType = "mime_type"
        case userId = "user_id"
        case groupId = "group_id"
    }
}
