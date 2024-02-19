import { LightningElement, track } from 'lwc';
import getCertifications from '@salesforce/apex/ExamPageController.getCertifications';
import getQuestions from '@salesforce/apex/ExamPageController.getQuestions';


export default class ExamPage extends LightningElement {
    @track
    //Templates
    examStart = false;
    certTemaplate = true;
    reponsesExam = false;
    finishExam = true;
    correctResponsesQuestions = false;
    examIsFinished = false;

    //Arrays
    certs = [];
    questions = [];
    numberOfQuestions = 0;

    //Variables
    successPercent = 0;
    canStart = false;
    chooseNumber = false;
    certId;

    //Maps
    correctResponses = new Map();
    userResponses = new Map();
    checkedExam = new Map();


    connectedCallback(){
        getCertifications().then(response => {
            this.certs = response;
        });

    }

    handleOptionclick(event) {
        let questionId = event.target.name;
        let optionId = event.target.value;
        if(this.userResponses.size == 0){
            this.userResponses.set(questionId, optionId)
        }else{
            let notExit = true;
            this.userResponses.forEach((value, key, map) => {
                if(key == questionId && !value.includes(optionId)){
                    this.userResponses.set(key ,value + optionId);
                    notExit = false;
                }
                
                if(key == questionId && value.includes(optionId)){
                    this.userResponses.set(key ,value.replace(optionId,''));
                    if(value == ''){
                        map.delete(key);
                    }
                    notExit = false;
                }
            });
            if(notExit){
                this.userResponses.set(questionId, optionId)
            }
        }
    }

    checkResponses() {
        this.finishExam = false;
        this.correctResponsesQuestions = true;
        const userInputs = this.template.querySelectorAll("lightning-input");
        userInputs.forEach( input => {
            input.disabled = true;
        });

        this.correctResponses.forEach((value, key) => {
            this.userResponses.forEach((v, k) => {
                if(key == k){
                    if(value == v){
                        this.checkedExam.set(key, "Success");
                    }else{
                        this.checkedExam.set(key, "Failed")
                    }
                }
            });
        });

        let success = 0;
        this.correctResponses.forEach((value, key) => {
            this.checkedExam.forEach((v, k) => {
                if(key == k){
                    if(v == 'Success'){
                        this.template.querySelector(".question-item[data-id='" + key + "']").classList.add('successColor');
                        success++;
                    }else{
                        this.template.querySelector(".question-item[data-id='" + key + "']").classList.add('failColor');
                    }
                }
            });
        }); 
        this.examIsFinished = true;
        this.successPercent = ((success / this.correctResponses.size) * 100).toFixed(2);
    }

    reload(){
        window.location.reload();
    }

    handleItemClick(event) {
        this.certId = event.target.dataset.key;
        const allButtons = this.template.querySelectorAll(".item");
        allButtons.forEach( input => {
            input.classList.remove("selected");
        });
        this.template.querySelector(".item[data-id='" + this.certId + "']").classList.add('selected');
        this.chooseNumber = true;
    }

    chooseExamQuestion(event){
        const num = event.target.value;
        const allButtons = this.template.querySelectorAll(".typeExam");
        allButtons.forEach( input => {
            input.classList.remove("selected");
        });
        this.template.querySelector(".typeExam[value='" + num + "']").classList.add('selected');
        this.numberOfQuestions = num;
        this.canStart = true;
    }

    startExam(){
        if(this.canStart){
            this.examStart = true;
            this.certTemaplate = false;
            getQuestions({certId : this.certId, numberOfQuestions : this.numberOfQuestions}).then(response => {
                this.questions = response;
                for(let i = 0; i < response.length; i++){
                    this.correctResponses.set(response[i].Id,response[i].Correct_Answer__c)
                }
            });
        }
    }
}