@isTest
private class Account_BatchTest {
    static void myUnitTest() {
     	test.startTest();
    	
    	Id batchInstanceId;
        Account_Batch batch1 = new Account_Batch();
        batchInstanceId = Database.executeBatch(batch1,1);
        
        Id batchInstanceId2;
        Account_BatchActiveDate batch2 = new Account_BatchActiveDate();
        batchInstanceId2 = Database.executeBatch(batch2,1);
       
       test.stopTest();
    }
}