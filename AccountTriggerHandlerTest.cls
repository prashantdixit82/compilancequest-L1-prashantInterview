@IsTest
public with sharing class AccountTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Account accountInst = new Account(Name='TestAccount');
        insert accountInst;

        Account accountInst1 = new Account(Name='TestAccount1');
        insert accountInst1;

        List<SQX_Team_Members__c> teamMemberList = new List<SQX_Team_Members__c>{new SQX_Team_Members__c(Name = 'Test Team Member 1',Member_Type__c='HR',Account__c=accountInst.Id), new SQX_Team_Members__c(Name = 'Test Team Member 2',Member_Type__c='Admin',Account__c=accountInst.Id),
        new SQX_Team_Members__c(Name = 'Test Team Member 1',Member_Type__c='HR',Account__c=accountInst1.Id), new SQX_Team_Members__c(Name = 'Test Team Member 2',Member_Type__c='Admin',Account__c=accountInst1.Id)};
        insert teamMemberList;
    }

    @IsTest
    static void checkTeamMemberBeforeActivatingTheAccountTest(){
        List<Account> accountList = [SELECT Id,Active__c FROM Account];

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'testSt', Email='teststanyueqyiuyewqi@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='teststanyueqyiuyewqi@testorg.com');

        insert u;

        //Standard User
        System.runAs(u){ 
            accountList[0].Active__c = true;
            Database.SaveResult result= Database.update(accountList[0],false);
            System.assertEquals('You cannot Activate this Account', result.getErrors()[0].getMessage());
        }

        //System User
        accountList[1].Active__c = true;
        Database.SaveResult result= Database.update(accountList[1]);
        System.assertEquals('You cannot Activate this Account', result.getErrors()[0].getMessage());
    } 
}