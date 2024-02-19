global class InsertQuestionsFromJSON Implements Schedulable {

    global void execute(SchedulableContext sc){
        InsertQuestionsFromJSON();
    }

    public static void InsertQuestionsFromJSON() {

        List<Question__c> deleteQuestions = [SELECT id FROM Question__c];
        delete deleteQuestions;

        List<Certification_Exam__c> certs = [SELECT Id, Name FROM Certification_Exam__c];

        Set<Id> certsId = new Set<Id>();
        for(Certification_Exam__c cert : certs){
            certsId.add(cert.Id);
        }

        List<ContentDocumentLink> documents = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: certsId];
        
        Map<Id, Id> certsMap = new Map<Id, Id>();
        for(ContentDocumentLink doc : documents){
            certsMap.put(doc.ContentDocumentId, doc.LinkedEntityId);
        }

        List<ContentVersion> versionDoc = [SELECT Title, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: certsMap.keySet() AND IsLatest = true];
        List<Question__c> questionSet = new List<Question__c>();
        for(ContentVersion v : versionDoc){
            Blob jsonFile = v.VersionData;
            String jsonString= jsonFile.toString();
            List<Question> wrapper = (List<Question>)JSON.deserialize(jsonString, List<Question>.class);

            for(Question pregunta : wrapper) {
                Question__c unitQuestion = new Question__c();
                unitQuestion.Question__c = pregunta.question;
                unitQuestion.Certification_Exam__c = certsMap.get(v.ContentDocumentId);
                if(pregunta.options.A != null){
                    unitQuestion.Answer_A__c = 'A) ' + pregunta.options.A;
                }else{
                    unitQuestion.Answer_A__c = '';
                }
                if(pregunta.options.B != null){
                    unitQuestion.Answer_B__c = 'B) ' + pregunta.options.B;
                }
                else{
                    unitQuestion.Answer_B__c = '';
                }
                if(pregunta.options.C != null){
                    unitQuestion.Answer_C__c = 'C) ' + pregunta.options.C;
                }
                else{
                    unitQuestion.Answer_C__c = '';
                }
                if(pregunta.options.D != null){
                    unitQuestion.Answer_D__c = 'D) ' + pregunta.options.D;
                }
                else{
                    unitQuestion.Answer_D__c = '';
                }
                if(pregunta.options.E != null){
                    unitQuestion.Answer_E__c = 'E) ' + pregunta.options.E;
                }
                else{
                    unitQuestion.Answer_E__c = '';
                }
                unitQuestion.Correct_Answer__c = pregunta.correct_answer;
                questionSet.add(unitQuestion);
            }
        }

        insert questionSet;
    }

    public class Question {
        public String question {get; set;}
        public Options options {get; set;}
        public String correct_answer {get; set;}
    }
    
    public class Options {
        public String A {get; set;}
        public String B {get; set;}
        public String C {get; set;}
        public String D {get; set;}
        public String E {get; set;}

    }
}