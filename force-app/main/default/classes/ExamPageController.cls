public with sharing class ExamPageController {
    @AuraEnabled(cacheable=true)
    public static List<Certification_Exam__c> getCertifications(){
        try {
            return [SELECT Id, Name FROM Certification_Exam__c];   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Question__c> getQuestions(Id certId, Integer numberOfQuestions){
        try {
            List<Question__c> response = new List<Question__c> ();
            List<Question__c> questions = [SELECT Id, Question__c, Correct_Answer__c, Answer_A__c, Answer_B__c, Answer_C__c, Answer_D__c, Answer_E__c
                                                FROM Question__c WHERE Certification_Exam__c =: certId];

            response = randomizeQuestionList(questions, numberOfQuestions);
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    private static List<Question__c> randomizeQuestionList(List<Question__c> lst, Integer numberOfQuestions){
        integer currentIndex = lst.size();
        Question__c question;
        integer randomIndex;
        List<Question__c> reponse = new List<Question__c>();
        while (0 != currentIndex) {
            // Pick a remaining element...
            randomIndex = integer.valueOf(Math.floor(Math.random() * currentIndex));
            currentIndex -= 1;
            question = lst[currentIndex];
            lst[currentIndex] = lst[randomIndex];
            lst[randomIndex] = question;
        }
        if(lst.size() >= numberOfQuestions){
            for (Integer i = 0; i< numberOfQuestions; i++) {
                reponse.add(lst[i]);
            }
        }else{
            for (Integer i = 0; i< lst.size(); i++) {
                reponse.add(lst[i]);
            }
        }
        
        return reponse;
    }
}