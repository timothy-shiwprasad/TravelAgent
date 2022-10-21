  
walker talk {
    has access = false;
    has question = false ;
    has interactive = false;
    has wlk_ctx = {
        "respond" : false ,
        "prev_state" :null ,
        "next_state" : null,
        "flight_chosen" : null,
        "intent" : null ,
        "entities" : {},
        "voucher_number" :null

    };
    has response;
    has account = null;
    has flight ; 
    has voucherInfo = {
        "valid" : false
    };
    root {
            take --> node::dialogue_root;
       
    } 

    dialogue_state { 
            std.out(here.name);
            if(!question and interactive):{
            question = std.input("Input( Ctrl-C to exit)> ");
            here ::init_wlk_ctx;
            }
            elif(!question and !interactive) {
                std.err("Errror");
                disengage;

            }
          
      
         
        here::nlu;

        here::process;
        if(visitor.wlk_ctx["respond"]):{
            here::nlg;
            if(interactive): std.out(response);
           else{
            yield report response ; 
            here ::init_wlk_ctx;
           }
            question = null;
            
            take here; 
        } else {
            
            take visitor.wlk_ctx["next_state"] else: take here;
        }
    }

}


