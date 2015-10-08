/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.ParameterException;
import java.util.Arrays;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.arguments.Arguments;

/**
 *
 * @author Косых Евгений
 */
public final class Main {
    
    private static final Logger log = LogManager.getLogger();
    
    /**
     * 
     * @param args Command-line arguments
     */
    public static void main(String[] args) {
        log.info("The program started with arguments: {}", Arrays.toString(args));
        
        Arguments arguments = new Arguments();
        
        // Checking and setting CLI arguments.
        JCommander commander = new JCommander(arguments);
        try {
            commander.parse(args);

            // Print help and exit.
            if (arguments.isHelp()) {
                StringBuilder stringBuilder = new StringBuilder();
                commander.usage(stringBuilder);
                log.info(stringBuilder);
            }
        }
        catch (ParameterException e) {
            log.fatal(e);
        }

        try (OracleDatabase2File exporter = new OracleDatabase2File(arguments)) {
            exporter.execute();
        }
        catch (Throwable t) {
            log.fatal("Fatal error: ", t);
        }
        finally {
            log.info("Closing log writer");
        }
    }
}
