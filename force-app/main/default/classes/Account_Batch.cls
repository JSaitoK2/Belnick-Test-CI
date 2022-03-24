global with sharing class Account_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
   final static string CLASSNAME = '\n\n**** Account_Batch.METHODNAME()';
   private integer ReccordCount {get; set;}
   private datetime dt {get; set;}
   
   global Account_Batch()
   {
   	  ReccordCount = 0;
   	  
   	  if (dt == null){
	    	date d = date.Today();
	        integer currentyear = d.year();
	        dt = datetime.newInstance(currentyear,1,1,0,0,0);
	  }
   }
   global Database.QueryLocator start(Database.BatchableContext BC){ 
		string str = '';
		string dtString = dt.formatGMT('yyyy-MM-dd');
      	 str += 'select id,Last_Sales_Date__c from account where Type=\'Flash Dealer\' and Last_Sales_Date__c > ' + dtString;
      	 if(Test.isRunningTest()){
		   str += ' Limit 1';
		 }
	     Database.QueryLocator ql;
	     ql = Database.getQueryLocator(str);
	     return ql;
	}
	global void execute(Database.BatchableContext BC, List<Sobject> scope){ 
		final string METHODNAME = CLASSNAME.replace('METHODNAME','execute');
    	
	    
	    try{
	    	
	    Id sId;   //This will only work with a scope of 1 
	    list<Account> lstAccounts = new list<Account>();
	    for (sObject s : scope ){  
	      Account a = (Account)s;
	      sId = a.Id;
	    }
	    
	    AggregateResult[] groupedResults = [
        								select 
        								    Sum(FOB_Total__c) Value, 
        									Max(createddate) LastDate
        								from 
        									SCRB_SalesOrderLineItem__c 
        								where 
        								    createddate > :dt and
        								    SalesOrderId__r.AccountId__c = :sId and
        								    Item_Status__c != 'Cancelled' and 
        								    Item_Status__c != 'Canceled' and 
        								    Quantity_Ordered__c > 0
        								];
	    for (AggregateResult result : groupedResults){
                 Account a = new Account();
                 a.Id = sId;
                 a.Flash_YTD_Sales__c = SysProc.ToDecimal(result.get('Value'));
                                  
                 if (result.get('LastDate') != null){
                 	DateTime dtLasteDate = (DateTime)result.get('LastDate');
                    a.Last_Sales_Date__c = date.newInstance(dtLasteDate.year(), dtLasteDate.month(), dtLasteDate.day() );
                 }
                                  
                 ReccordCount += 1;
                 lstAccounts.add(a);                       	
        }
        if (!lstAccounts.isEmpty()){
        	SysProc.CanIRun('TopShelfClient');
        	update lstAccounts;
        }	
	    }catch(Exception ex){
    		   Exception_Handler.ReportIt(ex, 'Account_Batch', 'execute()');
               throw ex;
        }
	    
	}
	global void finish(Database.BatchableContext BC){
		List<string> toEmails = new List<string>();
		toEmails.add('roberttaggart@belnickinc.com');
        toEmails.add('DebbieSpellman@flashfurniture.com');
		string str = 'Flash YTD Sales(Total Accounts Updated=: ' + Sysproc.ToString(ReccordCount) + ' from Date=: ' + Sysproc.ToString(dt) + ')';
		list<Messaging.SingleEmailMessage> lstEmail = new list<Messaging.SingleEmailMessage>();
        lstEmail.add(SysProc.createEmail('Account Totals have been updated',str,toEmails));
        if(!Test.isRunningTest()){
          Messaging.SendEmailResult [] r = Messaging.sendEmail(lstEmail);      
		}
		
		Id batchInstanceId2;
        Account_BatchActiveDate batch2 = new Account_BatchActiveDate();
        batchInstanceId2 = Database.executeBatch(batch2,1);
		
	}
	
	/*comentario to test if I can commit1 */
   /*comentario to test if I can commit2 */
   /*comentario to test if I can commit3 */
   /*comentario to test if I can commit4 */
   /*comentario to test if I can commit5 */
    /*comentario to test if I can commit6 */
}