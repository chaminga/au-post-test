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
public class TestDataFactory {
    public static Case createCase(String caseOrigin) {
        return new Case(Origin = caseOrigin);
    }

    public static Callout__c createCallout(Id jobId, Id relatedRecordId) {
        return new Callout__c(Job_Id__c = jobId, Related_Record__c = relatedRecordId);
    }
}