## Steps to reproduce Error

### Load actions and model
 actions load module jaseci_kit.bi_enc
jac run bi_enc.jac -walk bi_train -ctx "{\"train_file\": \"training_data/clf_train_1.json\"}"
jac run bi_enc.jac -walk bi_save_model -ctx "{\"model_path\": \"dialogue_intent_model\"}"
jac run bi_enc.jac -walk bi_load_model -ctx "{\"model_path\": \"dialogue_intent_model\"}"
 
 actions load module jaseci_kit.tfm_ner
 jac run tfm_ner.jac -walk tfm_train   -ctx "{\"train_file\": \"training_data/ner_train.json\"}"
  jac run tfm_ner.jac -walk tfm_save_model -ctx  "{\"model_path\": \"dialogue_entity_model\"}"
 jac run tfm_ner.jac -walk tfm_load_model -ctx "{\"model_path\": \"dialogue_entity_model\"}"


## start django server
### In new terminal 
- cd AirlineBackend/Airline 
- run : python3 manage.py runserver 8080

 ## run program 

 jac run main.jac 

 Responses to add to follow 

 I want to book a flight
 i will be leaving Guyana
 i will be going to Peru
 I will be leaving the 6th May
 yes
 one
 yes
 i want to be in first class
 yes
 VA123 
 no
 yes

### Break code to test error 


remove semicolon line 85 in nodes.jac

Run : jac run main.jac
- no change will occur if compied 

follow same flow as above
