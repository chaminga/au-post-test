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
public class CaseQueuebleJob implements Queueable, Database.AllowsCallouts {
    private Case record {get; set;}

    public CaseQueuebleJob(Case record) {
        this.record = record;
    }

    public void execute(QueueableContext context) {
        // Get related callout record
        Callout__c callout = [SELECT Id, Status__c, Response__c, Job_ID__c 
                              FROM Callout__c Where Job_ID__c = :context.getJobId()];

        try{                      
            // Create HTTP request                     
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Workforce_Planning_API');
            request.setMethod('POST');
            request.setHeader('Content-Type', HttpFormBuilder.GetContentType());

            // Generate form body
            String body = '';
            body += HttpFormBuilder.WriteBoundary();
            body += HttpFormBuilder.WriteBodyParameter('id', this.record.Id);
            body += HttpFormBuilder.WriteBoundary();
            body += HttpFormBuilder.WriteBodyParameter('agentid', this.record.Id);
            body += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);

            Blob formBlob = EncodingUtil.base64Decode(body);

            request.setHeader('Content-Length', String.valueOf(formBlob.size()));
            request.setBodyAsBlob(formBlob);

            // Keep start time
            Long startTime = System.now().getTime();

            // Send HTTP request
            HttpResponse response = http.send(request);

            // Store response
            callout.Response__c = response.getBody();

            // Get request duration
            callout.Duration__c = System.now().getTime() - startTime;

            // Store status code
            callout.Status_Code__c = response.getStatusCode();

            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() == 200) {
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                // Get the secret key
                String secrectKey = (String) results.get('secretKey');

                // If secrect key is present
                if(String.isNotBlank(secrectKey)){
                    // Update case record
                    Case caseRecord = new Case(Id = this.record.Id, Secret_Key__c = secrectKey);
                    update caseRecord;

                    // Set callout status
                    callout.Status__c = 'Successful';
                }
            }else{
                // Set callout status
                callout.Status__c = 'Failed';
            }

            // Store request blob as attachment
            Attachment file = new Attachment(Name = 'request', 
                                                Body = formBlob, 
                                                ContentType = HttpFormBuilder.GetContentType(),
                                                ParentId = callout.Id);
            insert file;

        }catch(Exception e){
            // Set callout status
            callout.Status__c = 'Failed';
        }

        // Update callout
        update callout;
    }
}
