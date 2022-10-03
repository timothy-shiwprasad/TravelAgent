 graph dialogue_system {
    has anchor dialogue_root;
    spawn {
        dialogue_root = spawn node::dialogue_root;
        book_flight = spawn node::nd_bookFlight;
        bookflightConfirmation = spawn node:: nd_book_confirmation;
        confirmed = spawn node::nd_book_flight_confirmed;
        selectFlight = spawn node:: nd_selectflight;
        secondaryDetails = spawn node::nd_secondaryDetails;
        secondaryDetailsConfirmed = spawn node::nd_secondaryDetailsConfirmation;
        #voucher = spawn node :: nd_voucher ;
        #flightDetail = spawn node :: nd_flightDetailsComplete ;
 
       
        cancel_flight = spawn node::nd_cancel_flight_co;

        dialogue_root -[intent_transition(intent="book flight")]-> book_flight;
        #book_flight -[intent_transition(intent="cancel booking")]-> cancelBooking;
        book_flight -[entity_transition(entities=["origin", "destination", "date"])]-> bookflightConfirmation;
        book_flight -[intent_transition(intent="provide origin or destination or date")]-> book_flight;
        #bookflightConfirmation - [intent_transition(intent="cancel booking")]-> cancelBooking;
        bookflightConfirmation - [intent_transition(intent="no")]-> book_flight;
        bookflightConfirmation - [intent_transition(intent="yes")]-> selectFlight;
        selectFlight - [intent_transition(intent="no")]-> selectFlight;
        selectFlight - [intent_transition(intent="yes")]-> secondaryDetails;
        secondaryDetails -[entity_transition(entities=["class"])] -> secondaryDetailsConfirmed;
        secondaryDetailsConfirmed -[intent_transition(intent="no")] ->secondaryDetails;
        secondaryDetailsConfirmed -[intent_transition(intent="yes")] ->confirmed;

        #secondaryDetails  -[intent_transition(intent= "yes")]  ->   voucher;
        #voucher  -[intent_transition(intent ="yes")] -> flightDetail;
        dialogue_root -[intent_transition(intent="cancel Flight")]-> cancel_flight;
    }
}