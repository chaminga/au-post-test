/**
 * @description       : 
 * @author            : Chaminga Dissanayake
 * @group             : 
 * @last modified on  : 02-21-2021
 * @last modified by  : Chaminga Dissanayake
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   02-21-2021   Chaminga Dissanayake   Initial Version
**/
@isTest
public class CaseQueuebleJobTest {
    @testSetup
    static void setup() {
        // Create case with closed status
        Case testCase = TestDataFactory.createCase('Phone');
        testCase.Status = 'Closed';
        insert testCase;
    }

    static testMethod void testCallout_Success() {
        // query for test data to pass to queueable class
        Case testCase = [SELECT Id, Status, OwnerId FROM Case WHERE Status = 'Closed' AND Secret_Key__c = NULL LIMIT 1];

        // set callout mock
        Test.setMock(HttpCalloutMock.class, new CaseQueuebleJobTest.MockHttpResponseSuccess());

        // Create Queueable instance
        CaseQueuebleJob queuebleJob = new CaseQueuebleJob(testCase);

        // startTest/stopTest block to force async processes to run
        Test.startTest();
        Id jobId = System.enqueueJob(queuebleJob);

        // Create test callout
        Callout__c testCallout = TestDataFactory.createCallout(jobId, testCase.Id);
        insert testCallout;

        Test.stopTest();

        // Validate the job ran. Check if record have secrect key
        System.assert([SELECT Secret_Key__c FROM Case WHERE Id = :testCase.Id].Secret_Key__c != null);
    }

    static testMethod void testCallout_Failure() {
        // query for test data to pass to queueable class
        Case testCase = [SELECT Id, Status, OwnerId FROM Case WHERE Status = 'Closed' AND Secret_Key__c = NULL LIMIT 1];

        // set callout mock
        Test.setMock(HttpCalloutMock.class, new CaseQueuebleJobTest.MockHttpResponseFailure());

        // Create Queueable instance
        CaseQueuebleJob queuebleJob = new CaseQueuebleJob(testCase);

        // startTest/stopTest block to force async processes to run
        Test.startTest();
        Id jobId = System.enqueueJob(queuebleJob);

        // Create test callout
        Callout__c testCallout = TestDataFactory.createCallout(jobId, testCase.Id);
        insert testCallout;

        Test.stopTest();

        // Validate the job ran. Check if record dosn't have a secrect key
        System.assert([SELECT Secret_Key__c FROM Case WHERE Id = :testCase.Id].Secret_Key__c == null);
    }

    public class MockHttpResponseSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"success":true,"secretKey":"0ab31f00f2be9d98de4f9a9df10e48e2"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockHttpResponseFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"success":false,"error":"id is invalid"}');
            res.setStatusCode(500);
            return res;
        }
    }
}