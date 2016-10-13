//
//  NetworkUtilities.swift
//  SampleApp_Swift_iOS
//
//  Created by Pandiyaraj on 13/10/16.
//  Copyright © 2016 Pandiyaraj. All rights reserved.
//

import UIKit

extension NSURLSession
{
    /// Return data from synchronous URL request
    public func requestSynchronousData(request: NSURLRequest) -> (NSData?, NSURLResponse?) {
        var data: NSData? = nil
        var response: NSURLResponse? = nil
        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (taskData, taskResponse, taskError) in
            data = taskData
            response = taskResponse
            if data == nil, let taskError = taskError {print(taskError)}
            dispatch_semaphore_signal(semaphore);
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return (data,response)
    }
}

public class NetworkUtilities {
    
    //#-- For dummy url content
    static let BASEURL = "http://demo7139906.mockable.io/"
    /**
     create session
     
     - parameter contentType: either JSON OR URLENCODED
     
     - returns: URLSession
     */
    static func getSessionWithContentType(contentType : String) -> NSURLSession {
        let sessoinConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessoinConfiguration.HTTPAdditionalHeaders = ["content-type":contentType]
        let session : NSURLSession  = NSURLSession.init(configuration: sessoinConfiguration)
        return session
    }
    
    
    
    /**
     Create mutable url request to send the server
     
     - parameter actionName:  which action to be performed login
     - parameter httpMethod:  either POST OR GET OR PUT OR DELETE
     - parameter requestBody: parameters
     - parameter contentType: either JSON OR URLENCODED
     
     - returns: URLRequest
     */
    static func getUrlRequest(actionName:String , httpMethod : String, requestBody: AnyObject?,contentType : String) -> NSMutableURLRequest {
        
        var  urlString : String
        
        urlString = "\(BASEURL)/\(actionName)"
        
        let requestUrl = NSURL.init(string: urlString)
        let request  = NSMutableURLRequest.init(URL: requestUrl!)
        request.HTTPMethod = httpMethod
        request.timeoutInterval = 120
        
        if requestBody != nil {
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(requestBody!, options: .PrettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                
                //#-- For checking given format is json or not
                let jsonString = NSString.init(data: jsonData, encoding: NSUTF8StringEncoding)
                print(jsonString);
                
                request.HTTPBody? =  jsonData
                let postLength = String(jsonData.length)
                request.setValue(contentType, forHTTPHeaderField: "Content-type")
                request.setValue(postLength, forHTTPHeaderField: "Content-Length")
                request.setValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
            } catch let error as NSError {
                print(error)
            }
        }
        else{
            
        }
        
        return request
        
    }
    
    /**
     Synchronous request
     
     - parameter actionName:  action Name like Login
     - parameter httpMethod:  http methid like Get or Post
     - parameter requestBody: parameters with json format
     - parameter contentType: content type - json or urlencoded
     
     - returns: Object if success or error
     */
    static public func sendSynchronousRequestToServer(actionName : String,httpMethod : String, requestBody :AnyObject?, contentType : String ) -> AnyObject?{
        
        let request = self.getUrlRequest(actionName, httpMethod: httpMethod, requestBody: requestBody, contentType: contentType)
        let responseObject = self.getSessionWithContentType(contentType).requestSynchronousData(request)
        return self.getResponseData(responseObject.0, response: responseObject.1)
    }
    
    
    /**
     Asynchronous request
     
     - parameter actionName:        action Name like Login
     - parameter httpMethod:        http methid like Get or Post
     - parameter requestBody:       parameters with json format
     - parameter contentType:       ontent type - json or urlencoded
     - parameter completionHandler: completiontype Called after request was finished or failed
     */
    static public func sendAsynchronousRequestToServer(actionName:String, httpMethod:String, requestBody:AnyObject?, contentType:String, completionHandler: ((obj: AnyObject)->())){
        
        let request = self.getUrlRequest(actionName, httpMethod: httpMethod, requestBody: requestBody, contentType: contentType)
        let  postDataTask = self.getSessionWithContentType(contentType).dataTaskWithRequest(request) { (data, response, error) in
            completionHandler(obj: self.getResponseData(data, response: response)!)
        };
        postDataTask.resume()
    }
    
    
    static func getResponseData(responseData : NSData? , response: NSURLResponse?) -> AnyObject? {
        guard response != nil else{
            return "Your device is having poor or no connection to connect the server. Please check or reset your connection.";
        }
        let httpResponse = response as? NSHTTPURLResponse
        let statusCode = httpResponse?.statusCode
        let allHeaderFields : NSDictionary = (httpResponse?.allHeaderFields)!
        
        //#-- Response is success
        if statusCode == 200 {
            //#-- Check respose is either JSON or XML or TEXT
            let contentType = allHeaderFields.valueForKey("Content-Type") as? String
            if (contentType?.rangeOfString("application/json") != nil) {
                //#--  JSON
                var jsonResponse: AnyObject?
                do {
                    jsonResponse = try NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions())
                } catch let jsonError {
                    print(jsonError)
                }
                return jsonResponse
            }
            else {
                //#-- Do part other values
                
                let responseStr  = NSString.init(data:responseData!, encoding: NSUTF8StringEncoding)
                if (responseStr != nil)  {
                    return responseStr
                }
                
            }
            
        }else{
            //#-- Response is failure case
            var jsonResponse : AnyObject?
            do {
                jsonResponse = try NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions())
            } catch let jsonError {
                print(jsonError)
            }
            
            let  errorMessage  = jsonResponse?.valueForKey("message") as? String
            if errorMessage?.characters.count > 0{
                return errorMessage
            }
            else{
                return "Error while send request"
            }
        }
        return "Error while send request"
    }
}

