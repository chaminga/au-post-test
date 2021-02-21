/**
 * @description       : 
 * @author            : Chaminga Dissanayake
 * @group             : 
 * @last modified on  : 02-21-2021
 * @last modified by  : Chaminga Dissanayake
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   02-19-2021   Chaminga Dissanayake   Initial Version
**/
public class CaseTriggerHandler extends TriggerHandler{
    private Map<Id, Case> oldMap;
    private Map<Id, Case> newMap;

    public CaseTriggerHandler() {
        this.oldMap = (Map<Id, Case>) Trigger.oldMap;
        this.newMap = (Map<Id, Case>) Trigger.newMap;
    }
    
    public override void afterUpdate() {
        List<Callout__c> callouts = new List<Callout__c>();
        for(Id caseId : getClosedCases().keySet()){
            callouts.add(new Callout__c(Job_Id__c = System.enqueueJob(new CaseQueuebleJob(this.newMap.get(caseId))), 
                                        Related_Record__c = caseId));
        }
        if(callouts.size()>0){
            insert callouts;
        }
    }

    /**
    * @description Returns closed cases
    * @author Chaminga Dissanayake | 02-21-2021 
    * @return Map<Id, Case> 
    **/
    public Map<Id, Case> getClosedCases(){
        Map<Id, Case> closedCases = new Map<Id, Case>();
        for(Id caseId : this.newMap.keySet())
        {
            if(this.oldMap.get(caseId).Status != this.newMap.get(caseId).Status 
                && this.newMap.get(caseId).Status == 'Closed'
                && String.isBlank(this.newMap.get(caseId).Secret_Key__c))
            {
                closedCases.put(caseId, this.newMap.get(caseId));
            }
        }
        return closedCases;
    }
}
