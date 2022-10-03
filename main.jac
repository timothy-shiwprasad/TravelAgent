import {*} with './nodes.jac';
import {*} with './graphs.jac';
import {*} with './edges.jac';
import {*} with './walkers.jac';


walker init {
    root {
        spawn here --> graph::dialogue_system;
        spawn here walker::talk ;
    }
}