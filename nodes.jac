node dialogue_state {
    can bi_enc.infer;
    can tfm_ner.extract_entity;

    can classify_intent {
        intent_labels = -[intent_transition]->.edge.intent;
        visitor.wlk_ctx["intent"] = bi_enc.infer(
            contexts = [visitor.question],
            candidates = intent_labels ,
            context_type = "text",
            candidate_type = "text"
        )[0]["predicted"]["label"];
    }

  can extract_entities {
        res = tfm_ner.extract_entity(visitor.question);
        for ent in res {
            ent_type = ent["entity_value"];
            ent_text = ent["entity_text"];
            if (!(ent_type in visitor.wlk_ctx["entities"])){
                visitor.wlk_ctx["entities"][ent_type] = [];
            }
            visitor.wlk_ctx["entities"][ent_type].l::append(ent_text);
        }
    }

    can init_wlk_ctx {
        new_wlk_ctx = {
            "intent": null,
            "entities": {},
            "prev_state": null,
            "next_state": null,
            "respond": false,
            "voucher_number" : null
        };
        if ("entities" in visitor.wlk_ctx) {
            // Carry over extracted entities from previous interaction
            new_wlk_ctx["entities"] = visitor.wlk_ctx["entities"];
        }
        if ("flights" in visitor.wlk_ctx):{
            new_wlk_ctx["flights"] = visitor.wlk_ctx["flights"];

        }
        visitor.wlk_ctx = new_wlk_ctx;
    }
    can nlu {}
    can process {
        if (visitor.wlk_ctx["prev_state"]): visitor.wlk_ctx["respond"] = true;
        else {
            visitor.wlk_ctx["next_state"] = net.root();
            visitor.wlk_ctx["prev_state"] = here;
        }
    }
    can nlg {}
}

node dialogue_root:dialogue_state {
    has name = "dialogue_root";
    can nlu {
         ::classify_intent;
        
    }
    can process {
        
        visitor.wlk_ctx["prev_state"] = here ;
        visitor.wlk_ctx["next_state"] = (-[intent_transition(intent==visitor.wlk_ctx["intent"])]->)[0];
    }
    can nlg {
        visitor.response = "Sorry I can't handle that just yet. Anything else I can help you with?";
    }
}



node nd_bookFlight:dialogue_state {
    has name = "book_flight";
    has ProcessedDate = true;
    can nlu {
        if (!visitor.wlk_ctx["intent"]): ::classify_intent;
        ::extract_entities;
    }

    can convertDate {
        count = 1 ;
        commonMonths = ["january","february", "march","april","may","june","july","august","september","october","november","december"];
        CapitalMonths = ["January","February", "March","April","May","June","July","August","September","October","November","December"];
        dateString = visitor.wlk_ctx["entities"]["date"][0];
        monthFound = false ;
        dayFound = false;
        here.ProcessedDate = "2022-" ;

        for month in commonMonths:{
            if(dateString.str::find(month) != -1):{
                monthFound = true ;
                if(count<10) : here.ProcessedDate = ProcessedDate + "0" + count.str + "-" ;
                else : here.ProcessedDate = ProcessedDate + count.str + "-" ;
                
                break;

            }
            count = count + 1 ;
        }

        if(!monthFound):{
           
            count = 1 ;
            for month in CapitalMonths:{
            if(dateString.str::find(month) != -1):{
                monthFound = true ;
                if(count<10) : here.ProcessedDate = ProcessedDate + "0" + count.str + "-" ;
                else : here.ProcessedDate = ProcessedDate + count.str + "-" ;
                break;

            }
            count = count + 1 ;
        }
        }

        // find day 
        if(monthFound):{
            for i = 31 to i>0 by i-=1 :{
           
            if(dateString.str::find(i.str) != -1):{
                dayFound = true ;
                if(i<10): here.ProcessedDate  = ProcessedDate + "0" + i.str ;
                else : here.ProcessedDate =  ProcessedDate + i.str ;
                break;
            }
        }
        }
        
    if(!dayFound):{
        here.ProcessedDate = false ;
        visitor.wlk_ctx["entities"]["date"] = null ;
    }

    visitor.wlk_ctx["entities"]["date"][0] = here.ProcessedDate ;
        
    }

    can process {
        
          // Check entity transition
        required_entities = -[entity_transition]->.edge[0].context["entities"];
    
        if (vector.sort_by_key(visitor.wlk_ctx["entities"].d::keys) == vector.sort_by_key(required_entities)) {
            std.out("did this run");
            ::convertDate ;
            if(visitor.wlk_ctx["entities"]["date"]):{
                    visitor.wlk_ctx["next_state"] = -[entity_transition]->[0];
                     visitor.wlk_ctx["prev_state"] = here;
            }
            else:{
                visitor.wlk_ctx["respond"] =true ;
            }
            
         
        } elif (visitor.wlk_ctx["prev_state"] and !visitor.wlk_ctx["prev_state"].context["name"] in ["book_flight", "book_flight_confirmation"]){
        
            next_state = -[intent_transition(intent==visitor.wlk_ctx["intent"])]->;
            if (next_state.length > 0 and visitor.wlk_ctx["intent"] != "no") {
                visitor.wlk_ctx["next_state"] = next_state[0];
                visitor.wlk_ctx["prev_state"] = here;
                
            } else {
                visitor.wlk_ctx["respond"] = true;
           
            }
        }    else {
           
            visitor.wlk_ctx["respond"] = true;
        }

    }

    can nlg {
            //modify to book agent 
        if("origin" not in visitor.wlk_ctx["entities"]):
            visitor.response = "Where will you be departing?";
        elif("destination" not in visitor.wlk_ctx["entities"]):
            visitor.response = "Where will you be going";
        elif("date" not in visitor.wlk_ctx["entities"]):{
                if(ProcessedDate):{
                    visitor.response = "What date do you want to leave";
                }
                else :{
                    visitor.response = "Please Enter date Properly";
                }
        }
            
        else : visitor.response = "Menno";
      
    }
    }

    node nd_book_confirmation:dialogue_state {
    has name = "book_flight_confirmation";
    can nlu {
        if (!visitor.wlk_ctx["intent"]): ::classify_intent;
    }
    can process {
        if (visitor.wlk_ctx["prev_state"]): visitor.wlk_ctx["respond"] = true;
        else {
            visitor.wlk_ctx["next_state"] = -[intent_transition(intent==visitor.wlk_ctx["intent"])]->[0];
            visitor.wlk_ctx["prev_state"] = here;
        }
    }
    can nlg {
        // modify for book flight
        visitor.response =  "You will be leaving " + visitor.wlk_ctx["entities"]["origin"][0] + " and going to  " + visitor.wlk_ctx["entities"]["destination"][0] + " and will be leaving on the " + visitor.wlk_ctx["entities"]["date"][0] + " ,is this fine ?";
    }
}


node nd_book_flight_confirmed:dialogue_state {
    has name = "flight_details_confirmed";
    can bookFlight {
        response = request.post("http://localhost:8080/airline/bookflight/",
        {
            "ID" : 1 ,
            "name" : visitor.flight["Flight"],
            "FlightID": visitor.flight["ID"],
            "class": visitor.wlk_ctx["entities"]["class"][0]
        },
        null
        );

        if(response["status_code"] == 404):{
            visitor.response = "There has been an error processing your Request";
        }
        else:
        visitor.response = "Your Flight has been booked";       
    }

    can process {
        if(visitor.wlk_ctx["prev_state"]): visitor.wlk_ctx["respond"] = true;


        else:{
            visitor.wlk_ctx["next_state"] = net.root();
            visitor.wlk_ctx["prev_state"] = here;
            visitor.wlk_ctx["intent"] = null ;
            visitor.wlk_ctx["entities"] = {} ;
            visitor.wlk_ctx["respond"] = false;
            visitor.wlk_ctx["voucher_number"] = null ;
          }
    }



    can nlg {

        ## API call to backend to get flights 
      ::bookFlight ;
    }
}

node nd_selectflight:dialogue_state{
    has name = "selectFlight" ;
    has count = 1 ;
    has textToAppend = "";
    has ProcessedDate = "";
    

    can generateFlights{
    origin = visitor.wlk_ctx["entities"]["origin"][0];
    origin = origin.str::capitalize ;
    destination =  visitor.wlk_ctx["entities"]["destination"][0] ;
    destination = destination.str::capitalize ;

    response = request.get("http://localhost:8080/airline/get/",
    {
    "origin" : origin,
    "destination" : destination,
    "date" : "2022-09-01"
    },
    null);
    if( response["response"]["flights"]):{
         visitor.wlk_ctx["flights"] = response["response"]["flights"];

    }

    else : {
        visitor.wlk_ctx["flights"] = "There are no flights";
    }
   

    # will edit when ui is connected


   }

   can getInterger {
            if(visitor.wlk_ctx["intent"] == "one") :visitor.wlk_ctx["flight_chosen"] = 0;
            elif (visitor.wlk_ctx["intent"] == "two") :visitor.wlk_ctx["flight_chosen"] = 1;
            elif (visitor.wlk_ctx["intent"] == "three") :visitor.wlk_ctx["flight_chosen"] = 2;
   }

    can nlu {
        if(!visitor.wlk_ctx["intent"]):{
            intent_labels = -[intent_transition]->.edge.intent;
            intent_labels.l::append("one") ;
            intent_labels.l::append("two") ;
            intent_labels.l::append("three") ;
            visitor.wlk_ctx["intent"] = bi_enc.infer(
                contexts = [visitor.question],
                candidates = intent_labels ,
                context_type = "text",
                candidate_type = "text"
            )[0]["predicted"]["label"];
        }
    }


    can process {
        
        if(visitor.wlk_ctx["prev_state"] != null): {
            if(visitor.wlk_ctx["prev_state"].name == "book_flight_confirmation"){
                    visitor.wlk_ctx["respond"] = true ;
                    ::generateFlights;
            }
           
    
        }

        elif(visitor.wlk_ctx["prev_state"] == null):{
            if(visitor.wlk_ctx["intent"]=="yes"):{
                visitor.wlk_ctx["next_state"] = -[intent_transition(intent==visitor.wlk_ctx["intent"])]->[0];
                visitor.wlk_ctx["prev_state"] = here ;
            }
            elif(visitor.wlk_ctx["intent"] == "no"):{
                visitor.wlk_ctx["respond"] = true ;
                ::generateFlights;
            }
            elif(visitor.wlk_ctx["intent"] in ["one","two", "three"]):{
                visitor.wlk_ctx["respond"] = true ;
                ::getInterger;
                ::generateFlights;
                visitor.flight = visitor.wlk_ctx["flights"][visitor.wlk_ctx["flight_chosen"]];



            }
        }

    }


     can nlg {
        
        if(visitor.wlk_ctx["prev_state"] != null):{
            if(visitor.wlk_ctx["prev_state"].name == "book_flight_confirmation"):{
                visitor.response = ["Please select Flight:"];
                for flight in visitor.wlk_ctx["flights"]:{

                    textToAppend = count.str + " ) " + flight["Flight"] + ", Leaving: " + flight["Departing"] + " on the " + flight["DateDeparting"] + " at " + flight["TimeLeaving"]+ " and arriving in " + flight["Destination"] + " on the " + flight["DateArriving"] + " at " + flight["TimeArriving"] + "\n" ;
                    count = count +1 ;

                    visitor.response.l::append(textToAppend) ;
                    textToAppend = "";

                }
               
            }
            
        }

        elif(visitor.wlk_ctx["intent"] in ["one","two","three"]):{
            visitor.response = "The flight you want to book is as follows: Flight Name: " + visitor.flight["Flight"] + ", Leaving: " + visitor.flight["Departing"] + " on the " + visitor.flight["DateDeparting"] + " at " + visitor.flight["TimeLeaving"]+ " and arriving in " + visitor.flight["Destination"] + " on the " + visitor.flight["DateArriving"] + " at " + visitor.flight["TimeArriving"] + " are you okay with this?" ;
        }
        elif(visitor.wlk_ctx["intent"] == "no"){
            visitor.response = ["Please select another flight"] ;
            for flight in visitor.wlk_ctx["flights"]:{

                    textToAppend = count.str + " ) " + flight["Flight"] + ", Leaving: " + flight["Departing"] + " on the " + flight["DateDeparting"] + " at " + flight["TimeLeaving"]+ " and arriving in " + flight["Destination"] + " on the " + flight["DateArriving"] + " at " + flight["TimeArriving"] + "\n" ;
                    count = count +1 ;

                    visitor.response.l::append(textToAppend);
                    textToAppend = "";

                }

        }

    }
}

node nd_secondaryDetails:dialogue_state{
    has name = "secondaryDetails" ;

    can nlu {
        ::extract_entities ;
    }


    can process {
         
         if("class" in visitor.wlk_ctx["entities"]){
            if(visitor.wlk_ctx["entities"]["class"].length != 0):{
            visitor.wlk_ctx["prev_state"] = here ;
            visitor.wlk_ctx["next_state"] = -[entity_transition] ->[0] ;

            }
            else: visitor.wlk_ctx["respond"] = true;
           
         }

         else: visitor.wlk_ctx["respond"] = true;


    }

    can nlg {
        visitor.response = "What class do you want to be in ?";
    }


}

node nd_secondaryDetailsConfirmation:dialogue_state {
    has name = "secondaryDetailsConfirmed";
    can nlu {
        if(!visitor.wlk_ctx["intent"]): ::classify_intent ;

    }

    can process {
        if(visitor.wlk_ctx["prev_state"] != null):{
            if(visitor.wlk_ctx["prev_state"].name =="secondaryDetails"):{
                visitor.wlk_ctx["respond"] = true;
            }

        }

        else: {
            if(visitor.wlk_ctx["intent"] == "yes"):{
                visitor.wlk_ctx["prev_state"] = here;
                visitor.wlk_ctx["next_state"] = -[intent_transition(intent==visitor.wlk_ctx["intent"])]->[0];
            }

            elif(visitor.wlk_ctx["intent"] == "no"):{
                
                visitor.wlk_ctx["prev_state"] = here;
                visitor.wlk_ctx["next_state"] = -[intent_transition(intent==visitor.wlk_ctx["intent"])]->[0];
                visitor.wlk_ctx["entities"]["class"] = [] ;
            }
        }
    }


    can nlg {
        if(visitor.wlk_ctx["prev_state"] != null):{
            if(visitor.wlk_ctx["prev_state"].name == "secondaryDetails"):{
                visitor.response = "Are you okay with the class " + visitor.wlk_ctx["entities"]["class"][0] ;
            }
        }



    }

}

node nd_voucher:dialogue_state{
    has name = "voucher";
    has voucherNumber = false;
    can checkVoucher{
        response = request.get("http://localhost:8080/airline/getVoucher/",
    {
        "voucherNumber": voucherNumber
    },
    null);
    visitor.voucherInfo = response["response"] ;

    }
    can nlu {
        if (visitor.question.str::startswith("VA")):{
            voucherNumber = visitor.question;
        }
        elif(!visitor.wlk_ctx["intent"]):{
                ::classify_intent;
                
                
        }  
    }

    can process {
        if(visitor.wlk_ctx["prev_state"] != null):{
            if(visitor.wlk_ctx["prev_state"].name == "secondaryDetailsConfirmed" or visitor.wlk_ctx["prev_state"].name == "voucher"):{
                visitor.wlk_ctx["respond"] = true;
            }
        }
        else:{

            // check voucher number function will be here
            if(voucherNumber):{
                #visitor.voucherInfo = {"valid":false , "reduction": 103 , "voucherNumber" : visitor.question} ;
                ::checkVoucher;
                if(visitor.voucherInfo["valid"] == true):{
                    visitor.wlk_ctx["prev_state"] = here ;
                    visitor.wlk_ctx["next_state"] = -[intent_transition(intent=="no")]->[0];
                
                }
                else:{
                visitor.wlk_ctx["respond"] = true ;
                visitor.question = null;
                voucherNumber = false;
                }
            }
            else:{
                if(visitor.wlk_ctx["intent"] == "yes"):{
                    visitor.wlk_ctx["prev_state"] = here ;
                    visitor.wlk_ctx["next_state"] = here ;
                    

                }
                elif(visitor.wlk_ctx["intent"] == "no"):{
                    visitor.wlk_ctx["prev_state"] = here ;
                    visitor.wlk_ctx["next_state"] = -[intent_transition(intent=="no")]->[0];

                }
            }

            

            }
        }


        can nlg {
             if(visitor.wlk_ctx["prev_state"] != null):{
                if(visitor.wlk_ctx["prev_state"].name == "secondaryDetailsConfirmed" or visitor.wlk_ctx["prev_state"].name == "voucher"):{
                visitor.response = "Please Enter Voucher number alone";
            }
        }
        elif(visitor.voucherInfo["valid"] == false):{
                visitor.response = "Your Voucher number is invalid. Would you like to try again?";
        }



        }
    }
     

node nd_FlightDetails:dialogue_state{
    has name = "FlightDetails";
    has flightDetails = null ;

    can nlu {
        if(!visitor.wlk_ctx["intent"]): ::classify_intent;
    }

    can process {
        if(visitor.wlk_ctx["prev_state"] != null):{
            if(visitor.wlk_ctx["prev_state"].name = "voucher"):{
                visitor.wlk_ctx["respond"] = true ;
            }

        }

        else:{
            if(visitor.wlk_ctx["intent"] == "yes"):{
                visitor.wlk_ctx["prev_state"] = here ;
                visitor.wlk_ctx["next_state"] = -[intent_transition(intent=="yes")] ->[0];
            }
            elif(visitor.wlk_ctx["intent"] == "no"):{
                 visitor.wlk_ctx["prev_state"] = here ;
                visitor.wlk_ctx["next_state"] = -[intent_transition(intent=="no")] ->[0];

            }
        }

    }

    can nlg{
        if(visitor.wlk_ctx["prev_state"] != null):{
            if(visitor.wlk_ctx["prev_state"].name = "voucher"):{
                flightDetails = visitor.flight;
                flightDetails["class"] = visitor.wlk_ctx["entities"]["class"][0];
                if(visitor.voucherInfo["valid"]):{
                    flightDetails["discount"] = visitor.voucherInfo["reduction"];
                }

                visitor.response = "The flight you want to book is as follows: Flight Name: " + flightDetails["Flight"] + ", Leaving: " + flightDetails["Departing"] + " on the " + flightDetails["DateDeparting"] + " at " + flightDetails["TimeLeaving"]+ " and arriving in " + flightDetails["Destination"] + " on the " + flightDetails["DateArriving"] + " at " + flightDetails["TimeArriving"] + " and Class " + flightDetails["class"] + " are you okay with this?";
            }

    }

}
}

// cancel flight conversation 

node nd_cancel_flight_co:dialogue_state {
    has name = "cancelflight";
    has flightstoCancell = null;
    has count =1;
    has textToAppend = "";
    can getUsersFlight {

         response = request.get("http://localhost:8080/airline/userflights/",
        {
            "UserID" : 1
        },
        null
        );

        if(response["response"]):{
            flightstoCancell = response["response"]["flights"];
            #std.out(flightstoCancell);
        }
        else:{
            flightstoCancell = "There are no flights to Cancell";
        }

    }
     can getInterger {
            if(visitor.wlk_ctx["intent"] == "one") :visitor.wlk_ctx["flight_chosen"] = 0;
            elif (visitor.wlk_ctx["intent"] == "two") :visitor.wlk_ctx["flight_chosen"] = 1;
            elif (visitor.wlk_ctx["intent"] == "three") :visitor.wlk_ctx["flight_chosen"] = 2;
   }
     can nlu {
        if (!visitor.wlk_ctx["intent"]):{
            intent_labels = -[intent_transition]->.edge.intent;
            intent_labels.l::append("one") ;
            intent_labels.l::append("two") ;
            intent_labels.l::append("three") ;
            visitor.wlk_ctx["intent"] = bi_enc.infer(
                contexts = [visitor.question],
                candidates = intent_labels ,
                context_type = "text",
                candidate_type = "text"
            )[0]["predicted"]["label"];

        }
    }

    can process {
        if(visitor.wlk_ctx["prev_state"] != null):{
            if(visitor.wlk_ctx["prev_state"].name == "dialogue_root" or visitor.wlk_ctx["prev_state"].name == "cancelflight"):{
                visitor.wlk_ctx["respond"] =true;
                ::getUsersFlight ;
            }
        }

        else:{
            if(visitor.wlk_ctx["intent"] in ["one", 'two',"three", "four"]):{
                ::getInterger ;
                ::getUsersFlight ;
                visitor.flight = flightstoCancell[visitor.wlk_ctx["flight_chosen"]];
                visitor.wlk_ctx["respond"] = true ;
                
            }
            elif(visitor.wlk_ctx["intent"] == "yes"):{
                visitor.wlk_ctx["next_state"] = -[intent_transition(intent==visitor.wlk_ctx["intent"])] ->[0];
                visitor.wlk_ctx["prev_state"] = here;
            }
            elif(visitor.wlk_ctx["intent"] == "no"):{
                visitor.wlk_ctx["next_state"] = -[intent_transition(intent==visitor.wlk_ctx["intent"])] ->[0];
                visitor.wlk_ctx["prev_state"] = here;

            }

            
        }

    }

    can nlg {
        if(visitor.wlk_ctx["prev_state"] != null):{
            if(visitor.wlk_ctx["prev_state"].name == "dialogue_root" or visitor.wlk_ctx["prev_state"].name == "cancelflight"):{
                visitor.response = ["Please select Flight to cancell:"]  ;
                 for flight in flightstoCancell:{

                    textToAppend = count.str + " ) " + flight["flightName"] + ", Leaving: " + flight["origin"] + " on the " + flight["DateLeaving"] + " at " + flight["TimeLeaving"]+ " and arriving in " + flight["destination"] + " on the " + flight["DateArriving"] + " at " + flight["TimeArriving"];
                    count = count +1 ;

                    visitor.response.l::append(textToAppend) ;
                    textToAppend = "";

                }
            }
        }

        elif(visitor.wlk_ctx["intent"] in ["one" ,"two","three", "four"]):{
            visitor.response = "Is this flight the one you want to cancell?  " + visitor.flight["flightName"] + ", Leaving: " + visitor.flight["origin"] + " on the " + visitor.flight["DateLeaving"] + " at " + visitor.flight["TimeLeaving"]+ " and arriving in " + visitor.flight["destination"] + " on the " + visitor.flight["DateArriving"] + " at " + visitor.flight["TimeArriving"] ;
    }
/*
    can getflights{
        # makes an APi call to server with user ID 
    }
*/
} 
}


node nd_confirmCancellation:dialogue_state{
    has name = "cancelFlightConfirm";
    has sucess = false ;
can cancelflight{
     response = request.post("http://localhost:8080/airline/cancelflight/",
        {
            "BookedFlightID" : visitor.flight["BookedFlightId"]
        },
        null
        );

        here.sucess = response["response"]["Sucess"];
       
    
}

can process {

    if(visitor.wlk_ctx["prev_state"] != null): {
        if(visitor.wlk_ctx["prev_state"].name == "cancelflight"):{
            visitor.wlk_ctx["respond"] = true ;

            // ability to cancel flight
            ::cancelflight ;
            

        }
    }

    else: {

        visitor.wlk_ctx["next_state"] = net.root();
        visitor.wlk_ctx["prev_state"] = here;

    }

}

can nlg {
    if(sucess == true): visitor.response =  "This Flight has been cancelled: " +   visitor.flight["flightName"] + ", Leaving: " + visitor.flight["origin"] + " on the " + visitor.flight["DateLeaving"] + " at " + visitor.flight["TimeLeaving"]+ " and arriving in " + visitor.flight["destination"] + " on the " + visitor.flight["DateArriving"] + " at " + visitor.flight["TimeArriving"] ;
    else : visitor.response = "There was a problem processig your request";
}
    
}


//faq 

node FAQRoot:dialogue_state {
    can use.qa_classify ;
    has name = "faqroot" ;
    has answered = false ;
    can nlu {
        if(!visitor.wlk_ctx["intent"]): visitor.wlk_ctx["intent"] = visitor.question;
    }

    can process {
        if(visitor.wlk_ctx["prev_state"] != null):{
            if(visitor.wlk_ctx["prev_state"].name == "dialogue_root"): visitor.wlk_ctx["respond"] = true ;
        }
        elif(visitor.wlk_ctx["prev_state"] == null):{
            std.out(here.answered);
                if(!here.answered):{
                
                visitor.wlk_ctx["respond"] = true;
                answers = -[answer]->.answer;
                std.out(answers);
                best_answer = use.qa_classify(
                text = visitor.wlk_ctx["intent"],
                classes = answers
                );
                visitor.wlk_ctx["intent"] = best_answer["match"];
                std.out(best_answer);
                here.answered = true;
                }

                else:{
                    std.out(answered);
                    here.answered = false ;
                    visitor.wlk_ctx["next_state"] = -[intent_transition(intent="yes")]->[0] ;
                    visitor.wlk_ctx["prev_state"] = here ;
                }
                
}
        
        }

    can nlg {
         if(visitor.wlk_ctx["prev_state"] != null):{
            if(visitor.wlk_ctx["prev_state"].name == "dialogue_root"): visitor.response = "Ask your question" ;
        
        }
        else:{
            visitor.response = visitor.wlk_ctx["intent"];
        }

    }
}

node FAQState {
    has answer;

}




// account nodes 
/*
node accountState{

can nlu {
    if(!visitor.wlk_ctx["intent"]):{
        user_Id = -[user_transition]->.edge.id;
        if(visitor.question in user_Id):{
        visitor.account = -[user_transition(id=visitor.question)]->[0];
    }
    }
    
}

    can process {
        if(visitor.account){
            if(visitor.question = visitor.account.context["password"]){
                visitor.access= true ;
                visitor.wlk_ctx["next_state"] = net.root();
            }
            else: visitor.wlk_ctx["respond"] = true ;


        }
        else:{
            if(visitor.wlk_ctx["userId"]):{
            visitor.account = -[user_transition(id==question)]->[0];
            if(!visitor.account):{
                visitor.wlk_ctx["respond"] = true;
            }
        }

             else : visitor.wlk_ctx["respond"] = true ;

        }
       

    }
}


node user {
    has password;
}

/*
        response = "Please Enter User Id";
         if(interactive): std.out(response);
           else:{
            yield report response ;
           }

        

        if (account):{
            response = "Please Enter Password";
             if(interactive): std.out(response);
           else{
            yield report response ;

        }

        Password = question;
        if(password==account.context["password"]):{
            access = true;
            response = "Access Granted";
            if(interactive): std.out(response);
           else:{
            report response;
            take net.root();     
        }
        }
        else:{
            response = "Wrong Password";
            if(interactive): std.out(response);
           else{
            report response;
            take net.root();
        }

    }
        }
    else :{
         response = "No such account exits for that ID";
             if(interactive): std.out(response);
           else{
            report response;
            take net.root();

    }
}

*/