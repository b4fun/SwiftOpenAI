//
//  Endpoint.swift
//
//
//  Created by James Rochabrun on 10/11/23.
//

import Foundation

// MARK: HTTPMethod

enum HTTPMethod: String {
   case post = "POST"
   case get = "GET"
   case delete = "DELETE"
}

// MARK: Endpoint

protocol Endpoint {
   
   var base: String { get }
   var path: String { get }
}

// MARK: Endpoint+Requests

extension Endpoint {

   private func urlComponents(
      queryItems: [URLQueryItem]? = nil)
      -> URLComponents
   {
      var components = URLComponents(string: base)!
      components.path = path
      components.queryItems = queryItems
      return components
   }
   
   func request(
      apiKey: String,
      organizationID: String?,
      method: HTTPMethod,
      params: Encodable? = nil,
      queryItems: [URLQueryItem]? = nil)
      throws -> URLRequest
   {
      var request = URLRequest(url: urlComponents(queryItems: queryItems).url!)
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
      if let organizationID {
         request.setValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
      }
      request.httpMethod = method.rawValue
      if let params {
         request.httpBody = try JSONEncoder().encode(params)
      }
      return request
   }
   
   func multiPartRequest(
      apiKey: String,
      organizationID: String?,
      method: HTTPMethod,
      params: MultipartFormDataParameters,
      queryItems: [URLQueryItem]? = nil)
      throws -> URLRequest
   {
      var request = URLRequest(url: urlComponents(queryItems: queryItems).url!)
      request.httpMethod = method.rawValue
      let boundary = UUID().uuidString
      request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
      if let organizationID {
         request.setValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
      }
      request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
      request.httpBody = params.encode(boundary: boundary)
      return request
   }
}
