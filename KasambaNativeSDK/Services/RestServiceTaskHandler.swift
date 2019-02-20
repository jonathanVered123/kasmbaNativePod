//
//  NetworkTaskHandler.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/16/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation

/// Basic handler for tasks send to server via REST
class RestServiceTaskHandler: ServiceTaskHandlerProtocol, CustomStringConvertible {
    
    private var task: URLSessionTask? = nil
    
    private var host: String = ""
    private var path: String = ""
    private var query: [String: String]? = nil
    private var method: String = ""
    private var headers: [String: String]? = nil
    private var body: [String: Any]? = nil
    private var encoder: ContentEncoderProtocol = JsonEncoder.default
    
    private(set) var canceled = false
    
    var executed: Bool {
        return (task != nil && !canceled) ? true : false
    }
    
    var description: String {
        
        let url = "\(method) \(host)\(path)"
     
        return "<\(type(of: self)): 0x\(String(unsafeBitCast(self, to: Int.self), radix: 16, uppercase: false))> { \(url) }"
    }
    
    deinit {
    }
    
    // MARK: - Factory methods
    
    @discardableResult
    func url(_ url: () -> URL) -> Self {
        
        guard let components = URLComponents(url: url(), resolvingAgainstBaseURL: false) else {
            return self
        }
        
        self.host = "\(components.scheme ?? "")://\(components.host ?? "")"
        self.path = components.path
        
        if let queryItems = components.queryItems {
        
            self.query = queryItems.reduce([String:String]()) {
                
                if let value = $1.value {
                    return $0 + [$1.name: value]
                }
                
                return $0
            }
        }
        
        
        return self
    }
    
    @discardableResult
    func absolutePath(_ string: () -> String) -> Self {
        
        guard let url = URL(string: string()) else {
            return self
        }
        
        self.url { url }
        
        return self
    }
    
    /// Service host
    @discardableResult
    func host(_ host: () -> String) -> Self {
        self.host = host()
        return self
    }
    
    /// A path to specific service
    @discardableResult
    func path(_ path: () -> String) -> Self {
        self.path = path()
        return self
    }
    
    /// A query parameters added to the resulting request URL
//    @discardableResult
//    func query(_ query: () -> [String: String]?) -> Self {
//        queryAppend(query)
//        return self
//    }
    
    @discardableResult
    func query(_ query: () -> [String: String]?) -> Self {
        
        guard let query = query() else {
            return self
        }
        
        self.query = (self.query ?? [:]) + query
        
        return self
    }
    
    @discardableResult
    func queryOverride(_ query: () -> [String: String]?) -> Self {
        
        guard let query = query() else {
            return self
        }
        
        self.query = query
        
        return self
    }
    
    /// An HTTP method (GET, POST etc.)
    @discardableResult
    func method(_ method: () -> String) -> Self {
        self.method = method()
        return self
    }
    
    /// An HTTP Headers
//    @discardableResult
//    func headers(_ headers: () -> [String: String]?) -> Self {
//        headersAppend(headers)
//        return self
//    }
    
    @discardableResult
    func headers(_ headers: () -> [String: String]?) -> Self {
        
        guard let headers = headers() else {
            return self
        }
        
        self.headers = (self.headers ?? [:]) + headers
        
        return self
    }
    
    @discardableResult
    func headersOverride(_ headers: () -> [String: String]?) -> Self {
        
        guard let headers = headers() else {
            return self
        }
        
        self.headers = headers
        
        return self
    }

    
    /// HTTP JSON body send with request
//    @discardableResult
//    func body(_ body: @autoclosure () -> [String: Any]?) -> Self {
//        bodyAppend(body)
//        return self
//    }
    
    @discardableResult
    func body(_ body: () -> [String: Any]?) -> Self {

        guard let body = body() else {
            return self
        }
        
        self.body = (self.body ?? [:]) + body

        return self
    }
    
    @discardableResult
    func bodyOverride(_ body: () -> [String: Any]?) -> Self {
        
        self.body = body()
        
        return self
    }
    
    @discardableResult
    func encoder(_ encoder: () -> ContentEncoderProtocol) -> Self {
        
        self.encoder = encoder()
        
        return self
    }
    
    // MARK: - Task building overridables
    
    func buildRequest() -> URLRequest? {
        
        guard var urlComponents = URLComponents(string: host) else {
            return nil
        }
        
        urlComponents.path = path
        
        if let query = query, query.count > 0 {
            
            let queryItems = query.reduce([URLQueryItem]()) {
                $0 + URLQueryItem(name: $1.key, value: $1.value)
            }
            
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        let session = Services.session
        
        request.cachePolicy = session.configuration.requestCachePolicy
        request.timeoutInterval = session.configuration.timeoutIntervalForRequest
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = method
        
        // Prepare body
        if let body = body, body.count > 0 {
            
            var error: Error? = nil
            
            guard let data = encoder.encode(content: body, error: &error) else {
                return nil
            }
            
            request.setValue(encoder.encodedContentType, forHTTPHeaderField: "Content-Type")
            request.setValue(String(data.count), forHTTPHeaderField: "Content-Length")
            request.httpBody = data
            
        }
        
        return request
    }
    
    func buildTask(responseHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        
        guard let request = buildRequest() else {
            return nil
        }
        
        return createTask(with: request, completionHandler: responseHandler)
        
    }
    
    /// Override task type
    func createTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionTask {
        
        return Services.session.dataTask(with: request, completionHandler: completionHandler)
    }
    
    // MARK: - Lifecycle
    
    /// Execute request
    @discardableResult
    func execute() -> Self {
        
        canceled = false
        
        let responseWrapper: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            
            self.task = nil
            
            if self.canceled {
                return
            }
            
            self.handleResponse(data: data, response: response, error: error)
            
        }
        
        if let task = buildTask(responseHandler: responseWrapper) {
            
            var parameters = [String: Any]()
            
            if let query = query {
                parameters["query"] = query as AnyObject
            }
            
            if let headers = task.currentRequest?.allHTTPHeaderFields, headers.count > 0 {
                parameters["headers"] = headers as AnyObject
            }
            
            if let body = body {
                parameters["body"] = body as AnyObject
            }
            
            self.task = task
            task.resume()
        }
        
        return self
    }
    
    func resume() {
        
        if !executed {
            
            execute()
        }
        
    }
    
    func cancel() {
        
        if let task = task {
            
            canceled = true
            task.cancel()
        }
        
    }
    
    // MARK: - Response blocks
    
    private var responseHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil
    private var errorResponseHandler: ((Error) -> Void)? = nil
    private var failureResponseHandler: ((Data?, HTTPURLResponse) -> Void)? = nil
    private var successResponseHandler: (() -> Void)? = nil
    private var dataResponseHandler: ((Data) -> Void)? = nil
    
    // MARK: - Response setters
    
    /// Base response handler will be executed when receved any response
    @discardableResult
    func response(_ handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Self {
        self.responseHandler = handler
        return self
    }
    
    @discardableResult
    func error(_ handler: @escaping (Error) -> Void) -> Self {
        self.errorResponseHandler = handler
        return self
    }
    
    /// Failure response handler executed when received HTTP status code different from 200
    @discardableResult
    func failure(_ handler: @escaping (Data?, HTTPURLResponse) -> Void) -> Self {
        self.failureResponseHandler = handler
        return self
    }
    
    @discardableResult
    func success(_ handler: @escaping () -> Void) -> Self {
        self.successResponseHandler = handler
        return self
    }
    
    @discardableResult
    func data(_ handler: @escaping (Data) -> Void) -> Self {
        self.dataResponseHandler = handler
        return self
    }
    
    // MARK: - Sublings overridable handlers

    /// Handle response
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        
        if let responseHandler = responseHandler {
            responseHandler(data, response, error)
            return
        }
        
        if let error = error {
            
            let error = NSError(domain: ServiceError.domain, code: ServiceError.requestFailed, userInfo: [NSLocalizedDescriptionKey: "Request failed", "originalError": error])
            handleResponseError(error)
            
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            
            
            let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Got unknown response"])
            handleResponseError(error)
            return
        }
        
        guard response.statusCode == 200 else {
            
            if !handleResponseFailure(data: data, response: response) {
                
                let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Got failure response (\(response.statusCode))"])
                handleResponseError(error)
            }
            
            return
        }
        
        guard let data = data, handleDataResponse(data: data, response: response) else {
            
            if !handleResponseSuccess() {
                let error = NSError(domain: ServiceError.domain, code: ServiceError.notHandled, userInfo: [NSLocalizedDescriptionKey: "Response not handled"])
                handleResponseError(error)
            }
            
            return
        }
        
        // Response handled
    }
    
    /// Handle any error response
    func handleResponseError(_ error: Error) {
        if let responseErrorHandler = errorResponseHandler {
            responseErrorHandler(error)
        }
    }
    
    /// Handle failure response (when status code different from 200 OK)
    @discardableResult
    func handleResponseFailure(data: Data?, response: HTTPURLResponse) -> Bool {
        
        if let failureResponseHandler = failureResponseHandler {
            failureResponseHandler(data, response)
            return true
        }
        
        return false
    }
    
    /// Handle success response without data processing
    @discardableResult
    func handleResponseSuccess() -> Bool {
        
        if let responseSuccessHandler = successResponseHandler {
            responseSuccessHandler()
            return true
        }
        
        return false
    }
    
    /// Handle response with data. Return "true" in subclasses if you want handle request in your implementation
    @discardableResult
    func handleDataResponse(data: Data, response: HTTPURLResponse) -> Bool {
        
        if let dataResponseHandler = dataResponseHandler {
            dataResponseHandler(data)
            return true
        }
        
        return false
    }
    
}

