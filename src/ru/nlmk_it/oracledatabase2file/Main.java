/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file;

import java.util.Arrays;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author Косых Евгений
 */
public class Main {
    
    private static final Logger logger = LogManager.getLogger();
    
    /**
     * 
     * @param args Command-line arguments
     */
    public static void main(String[] args) {
        logger.info("The program started with arguments: {}", Arrays.toString(args));
        
        
    }
}
