import {*} with './nodes.jac';
import {*} with './graphs.jac';
import {*} with './edges.jac';
import {*} with './walkers.jac';
import {*} with './bi_enc.jac';
import {*} with './tfm_ner.jac';


walker init {
    root {
        spawn here --> graph::dialogue_system;
        #spawn here --> graph::accounts;
        #spawn here walker::talk ;
    }
}