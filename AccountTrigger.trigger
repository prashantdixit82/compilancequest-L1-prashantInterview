trigger AccountTrigger on Account (after insert, before update) {
    if(trigger.isAfter && trigger.isInsert){
        AccountTriggerHandler.createTwoTeamRelatedToAccount(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        AccountTriggerHandler.checkTeamMemberBeforeActivatingTheAccount(trigger.new, trigger.oldMap);
    }
}