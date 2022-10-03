  
walker talk {
    has question;
    has wlk_ctx = {};
    has response;
    has flight ; 
    has voucherInfo = {} ;
    root {
        take --> node::dialogue_root;
    }
    dialogue_state { 
      
        if (!question) {
            question = std.input("Input( Ctrl-C to exit)> ");
            here::init_wlk_ctx;
        }
         
        here::nlu;
        here::process;
       
        if (visitor.wlk_ctx["respond"]) {
            here::nlg;
            std.out(response);
            question = null;
            
            take here; 
        } else {
            take visitor.wlk_ctx["next_state"] else: take here;
        }
    }
}


