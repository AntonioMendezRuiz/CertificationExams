public with sharing class LoginPageController {
    public String username { get; set; }
    public String password { get; set; }
    
    public boolean login() {
        system.debug('username: ' + username);
        system.debug('password: ' + password);
        try {
            List<Vanguard_User__c> vanUsers = [SELECT Username__c, Password__c FROM Vanguard_User__c];

            for(Vanguard_User__c us : vanUsers){
                if(us.Username__c == this.username && us.Password__c == this.password){
                    return true;
                }
            }   
            return false;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error al iniciar sesión: ' + e.getMessage()));
            return null;
        }
    }
}