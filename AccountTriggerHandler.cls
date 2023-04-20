public with sharing class AccountTriggerHandler {
    public static void createTwoTeamRelatedToAccount(List<Account> triggeredAccount){
        List<SQX_Team_Members__c> teamMemberList = new List<SQX_Team_Members__c>{new SQX_Team_Members__c(Name = 'Team Member 1'), new SQX_Team_Members__c(Name = 'Team Member 2')};
        
        for(Account accountInst: triggeredAccount){
            teamMemberList.get(0).Account__c = accountInst.Id;
            teamMemberList.get(1).Account__c = accountInst.Id;
        }

        insert teamMemberList;
    }

    public static void checkTeamMemberBeforeActivatingTheAccount(List<Account> newTriggeredAccount, Map<Id,Account> oldTriggeredAccountMap){
        List<Account> activatedAccount = new List<Account>();
        for(Account accountInst: newTriggeredAccount){
            if(accountInst.Active__c != oldTriggeredAccountMap.get(accountInst.Id).Active__c){
                activatedAccount.add(accountInst);
            }
        }

        if(activatedAccount.size()>0){
            List<PermissionSetAssignment> assignedPermissionSet = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name='Account_Admin' and AssigneeId =: UserInfo.getUserId()];
            List<SQX_Team_Members__c> allTeamMember = [SELECT Id,Account__c,Member_Type__c  FROM SQX_Team_Members__c WHERE Account__c IN: activatedAccount];
            
            Map<Id, List<String>> mapOfAccountIdAndMemberType = new Map<Id, List<String>>();
            for(SQX_Team_Members__c member: allTeamMember){
                if(!mapOfAccountIdAndMemberType.containsKey(member.Account__c))
                    mapOfAccountIdAndMemberType.put(member.Account__c, new List<String>());
                mapOfAccountIdAndMemberType.get(member.Account__c).add(member.Member_Type__c);
            }

            for(Id accountId: mapOfAccountIdAndMemberType.keySet()){
                System.debug('HR-->'+mapOfAccountIdAndMemberType.get(accountId).contains('HR'));
                System.debug('Admin-->'+mapOfAccountIdAndMemberType.get(accountId).contains('Admin'));
                System.debug('Permission-->'+assignedPermissionSet.size());
                if((!mapOfAccountIdAndMemberType.get(accountId).contains('HR') || !mapOfAccountIdAndMemberType.get(accountId).contains('Admin')) || assignedPermissionSet.size()==0){
                    Trigger.newMap.get(accountId).addError('You cannot Activate this Account');
                }
            }
        }
    }
}