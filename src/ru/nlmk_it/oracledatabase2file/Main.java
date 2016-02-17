package ru.nlmk_it.oracledatabase2file;

import com.beust.jcommander.JCommander;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import org.apache.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.arguments.Arguments;
import ru.nlmk_it.oracledatabase2file.logutils.NewLogForEachRunFileAppender;

/**
 *
 * @author Косых Евгений
 */
public final class Main {
    
    private static final Logger LOGGER = Logger.getLogger(Main.class);
    
    /**
     * 
     * @param args Command-line arguments
     * @throws java.lang.Exception
     */
    public static void main(String[] args) throws Exception {
        renameLogFile(args);
        LOGGER.info("The program started with arguments: " + Arrays.toString(args));
        
        try {
            Arguments arguments = new Arguments();
        
            // Checking and setting CLI arguments.
            JCommander commander = new JCommander(arguments);
            
            // Parsing CLI arguments.
            commander.parse(args);

            // Print help and exit.
            if (arguments.isHelp()) {
                StringBuilder stringBuilder = new StringBuilder();
                commander.usage(stringBuilder);
                LOGGER.info(stringBuilder);
                return;
            }
            
            arguments.setParametersFromConfigFile(new File(System.getProperty("OracleDatabase2File.configurationFile")));
            
            OracleDatabase2File exporter = new OracleDatabase2File(arguments);
            try {
                exporter.execute();
            }
            finally {
                exporter.close();
            }
        }
        catch (IOException t) {
            LOGGER.fatal("Fatal error: ", t);
        }
        catch (SQLException t) {
            LOGGER.fatal("Fatal error: ", t);
        }
        catch (RuntimeException t) {
            LOGGER.fatal("Fatal error: ", t);
        }
        finally {
            LOGGER.info("Closing log writer.");
        }
    }
    
    /**
     * 
     * @param newName
     */
    private synchronized static void renameLogFile(String[] args) {
        
        String newName = null;
        
        try {
            for (int i = 0; i < args.length; i++) {
                if (args[i].equalsIgnoreCase("-script")) {
                    File f = new File(args[i + 1]);
                    newName = f.getName().substring(0, f.getName().lastIndexOf(".")) + ".log";
                }
            }
        } 
        catch (RuntimeException e) { /*NOP*/ }
        
        final Logger logger = Logger.getLogger("ru.nlmk_it.oracledatabase2file");
        final NewLogForEachRunFileAppender appender = (NewLogForEachRunFileAppender) logger.getAppender("MAIN");
        
        appender.renameFile(newName);
    }
}
