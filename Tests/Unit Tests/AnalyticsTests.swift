/*
*     Copyright 2015 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/

import XCTest
import BMSCore
@testable import BMSAnalytics

class AnalyticsTests: XCTestCase {
    
    override func tearDown() {
        Analytics.lifecycleEvents = [:]
        Analytics.startTime = 0
        Analytics.uninitialize()
    }
    
    
    /**
        1) Check Analytics properties prior to initialization
        2) Initialize Analytics with empty strings
        3) Confirm that Analytics properties (apiKey, appName) are not yet initialized
        4) Initialize Analytics with real values
        5) Confirm that properties have been updated properly
    */
    func testInitializeWithAppName() {
     
        XCTAssertNil(Analytics.apiKey)
        XCTAssertNil(Analytics.appName)
        XCTAssertEqual(Analytics.appName, NSBundle.mainBundle().bundleIdentifier)
        
        Analytics.initializeWithAppName("", apiKey: "")
        XCTAssertNil(Analytics.apiKey)
        XCTAssertNil(Analytics.appName)
        XCTAssertEqual(Analytics.appName, NSBundle.mainBundle().bundleIdentifier)
        
        Analytics.initializeWithAppName("testAppName", apiKey: "testApiKey")
        XCTAssertEqual(Analytics.apiKey, "testApiKey")
        XCTAssertEqual(Analytics.appName, "testAppName")
    }
    
    
    func testInitializeWithAppNameRegistersUncaughtExceptionHandler() {
        
        Analytics.initializeWithAppName("Unit Test App", apiKey: "1234")
        XCTAssertNotNil(NSGetUncaughtExceptionHandler())
    }
    
    
    func testInitializeWithAppNameAndDeviceEvents() {
        
        let referenceTime = Int64(NSDate.timeIntervalSinceReferenceDate() * 1000)
        
        Analytics.initializeWithAppName("Unit Test App", apiKey: "1234", deviceEvents: DeviceEvent.LIFECYCLE)
        
        // When registering LIFECYCLE events, the Analytics.logSessionStart() method should get called immediately, assigning a new value to Analytics.startTime and Analytics.lifecycleEvents
        XCTAssertTrue(Analytics.startTime >= referenceTime)
        XCTAssertFalse(Analytics.lifecycleEvents.isEmpty)
    }
    
    
    /**
        1) Call logSessionStart(), which should update Analytics.lifecycleEvents and Analytics.startTime.
        2) Call logSessionStart() again. This should cause Analytics.lifecycleEvents to be updated:
            - The original start time should be replaced with the new start time.
            - The session (TAG_CATEGORY_APP_SESSION) is a unique ID that should contain a different value each time logSessionStart()
                is called.
     */
    func testLogSessionStartUpdatesCorrectly() {
        
        XCTAssertTrue(Analytics.lifecycleEvents.isEmpty)
        XCTAssertEqual(Analytics.startTime, 0)
        
        Analytics.logSessionStart()
        
        let firstSessionStartTime = Analytics.startTime
        let firstSessionId = Analytics.lifecycleEvents[Constants.Metadata.Analytics.sessionId] as! String
        XCTAssert(firstSessionStartTime > 0)
        
        // Need a little time delay so that the first and second sessions don't have the same start time
        let timeDelay = dispatch_time(DISPATCH_TIME_NOW, 1)
        dispatch_after(timeDelay, dispatch_get_main_queue()) { () -> Void in
            
            Analytics.logSessionStart()
            
            let secondSessionStartTime = Analytics.startTime
            let secondSessionId = Analytics.lifecycleEvents[Constants.Metadata.Analytics.sessionId] as! String
            
            XCTAssertTrue(secondSessionStartTime > firstSessionStartTime)
            XCTAssertNotEqual(firstSessionId, secondSessionId)
            
        }
    }
    
    
    /**
        1) Call logSessionStart(), which should update Analytics.lifecycleEvents.
        2) Call logSessionEnd(). This should reset Analytics.lifecycleEvents by removing the session ID.
        3) Call logSessionStart() again. This should cause Analytics.lifecycleEvents to be updated:
            - The original start time should be replaced with the new start time.
            - The session (TAG_CATEGORY_APP_SESSION) is a unique ID that should contain a different value each time logSessionStart()
                is called.
     */
    func testLogSessionAfterCompleteSession() {
        
        XCTAssertTrue(Analytics.lifecycleEvents.isEmpty)
        XCTAssertEqual(Analytics.startTime, 0)
        
        Analytics.logSessionStart()
        
        let firstSessionStartTime = Analytics.startTime
        let firstSessionId = Analytics.lifecycleEvents[Constants.Metadata.Analytics.sessionId] as! String
        
        Analytics.logSessionEnd()
        
        XCTAssertTrue(Analytics.lifecycleEvents.isEmpty)
        XCTAssertEqual(Analytics.startTime, 0)
        
        // Need a little time delay so that the first and second sessions don't have the same start time
        let timeDelay = dispatch_time(DISPATCH_TIME_NOW, 1)
        dispatch_after(timeDelay, dispatch_get_main_queue()) { () -> Void in
            
            Analytics.logSessionStart()
            
            let secondSessionStartTime = Analytics.startTime
            let secondSessionId = Analytics.lifecycleEvents[Constants.Metadata.Analytics.sessionId] as! String
            
            XCTAssertTrue(secondSessionStartTime > firstSessionStartTime)
            XCTAssertNotEqual(firstSessionId, secondSessionId)
        }
    }
    
    
    /**
        1) Call logSessionEnd(). This should have no effect since logSessionStart() was never called.
        2) Call logSessionStart().
     */
    func testlogSessionEndBeforeLogSessionStart() {
        
        XCTAssertTrue(Analytics.lifecycleEvents.isEmpty)
        XCTAssertEqual(Analytics.startTime, 0)
        
        Analytics.logSessionEnd()
        
        XCTAssertTrue(Analytics.lifecycleEvents.isEmpty)
        XCTAssertEqual(Analytics.startTime, 0)
        
        Analytics.logSessionStart()
        
        let sessionStartTime = Analytics.startTime
        
        XCTAssertFalse(Analytics.lifecycleEvents.isEmpty)
        XCTAssert(sessionStartTime > 0)
    }
    
    
    func testGenerateOutboundRequestMetadata() {
        
        Analytics.initializeWithAppName("Unit Test App", apiKey: "1234")
        
        guard let outboundMetadata: String = Analytics.generateOutboundRequestMetadata() else {
            XCTFail()
            return
        }
        XCTAssert(outboundMetadata.containsString("\"os\":\"iOS\""))
        XCTAssert(outboundMetadata.containsString("\"brand\":\"Apple\""))
        XCTAssert(outboundMetadata.containsString("\"model\":\"Simulator\""))
        XCTAssert(outboundMetadata.containsString("\"mfpAppName\":\"Unit Test App\""))
        XCTAssert(!outboundMetadata.containsString("\"deviceID\":\"\"")) // Make sure deviceID is not empty
        
        let osVersion = UIDevice.currentDevice().systemVersion
        XCTAssert(outboundMetadata.containsString("\"osVersion\":\"" + "\(osVersion)" + "\""))
    }
    
    
    func testGenerateOutboundRequestMetadataWithoutAnalyticsAppName() {
        
        Analytics.uninitialize()
        
        let requestMetadata = Analytics.generateOutboundRequestMetadata()
        
        XCTAssertNotNil(requestMetadata)
        // Since Analytics has not been initialized, there will be no app name.
        // In a real app, this should default to the bundle ID. Unit tests have no bundle ID.
        XCTAssert(!requestMetadata!.containsString("mfpAppName"))
    }
    
    
    func testAddAnalyticsMetadataToRequestWithAnalyticsAppName() {
        
        Analytics.initializeWithAppName("Test app", apiKey: "asdfjasdfj")
        
        let requestMetadata = Analytics.generateOutboundRequestMetadata()
        
        XCTAssertNotNil(requestMetadata)
        // Since Analytics has not been initialized, there will be no app name.
        // In a real app, this should default to the bundle ID. Unit tests have no bundle ID.
        XCTAssert(requestMetadata!.containsString("\"mfpAppName\":\"Test app\""))
    }

    
    func testGenerateInboundResponseMetadata() {
        
        class MockRequest: MFPRequest {
            
            override var startTime: NSTimeInterval {
                get {
                    return 0
                }
                set { }
            }
            
            override var trackingId: String {
                get {
                    return ""
                }
                set { }
            }
            
            init() {
                super.init(url: "", headers: nil, queryParameters: nil)
            }
        }
        
        let requestUrl = "http://example.com"
        let request = MockRequest()
        request.sendWithCompletionHandler(nil)
        
        let responseInfo = "{\"key1\": \"value1\", \"key2\": \"value2\"}".dataUsingEncoding(NSUTF8StringEncoding)
        let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "http://example.com")!, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: ["key": "value"])
        let response = Response(responseData: responseInfo, httpResponse: urlResponse, isRedirect: false)
        
        let responseMetadata = Analytics.generateInboundResponseMetadata(request, response: response, url: requestUrl)
        
        let outboundTime = responseMetadata["$outboundTimestamp"] as? NSTimeInterval
        let inboundTime = responseMetadata["$inboundTimestamp"] as? NSTimeInterval
        let roundTripTime = responseMetadata["$roundTripTime"] as? NSTimeInterval
        
        XCTAssertNotNil(outboundTime)
        XCTAssertNotNil(inboundTime)
        XCTAssertNotNil(roundTripTime)
        
        XCTAssert(inboundTime > outboundTime)
        XCTAssert(roundTripTime > 0)
        
        let responseBytes = responseMetadata["$bytesReceived"] as? Int
        XCTAssertNotNil(responseBytes)
        XCTAssert(responseBytes == 36)
    }


    func testUniqueDeviceId() {
        
        let mfpUserDefaults = NSUserDefaults(suiteName: "com.ibm.mobilefirstplatform.clientsdk.swift.BMSCore")
        mfpUserDefaults?.removeObjectForKey("deviceId")
        
        // Generate new ID
        let generatedId = Analytics.uniqueDeviceId
        
        // Since an ID was already created, this method should keep returning the same one
        let retrievedId = Analytics.uniqueDeviceId
        XCTAssertEqual(retrievedId, generatedId)
        let retrievedId2 = Analytics.uniqueDeviceId
        XCTAssertEqual(retrievedId2, generatedId)
    }
    
}