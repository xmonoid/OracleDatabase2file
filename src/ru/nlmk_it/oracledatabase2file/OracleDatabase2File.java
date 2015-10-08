/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.arguments.Arguments;

/**
 *
 * @author Косых Евгений
 */
public final class OracleDatabase2File implements AutoCloseable {
    
    private static final Logger log = LogManager.getLogger(OracleDatabase2File.class);
    
    public OracleDatabase2File(Arguments arguments) {
        log.trace("It was created an object of OracleDatabase2File class\n"
                + "\t Arguments arguments <= " + arguments.toString());
    }
    
    public void execute() {
        log.trace("It was invoked execute() method");
    }
    
    @Override
    public void close() {
        log.trace("It was invoked close() method");
    }
}
