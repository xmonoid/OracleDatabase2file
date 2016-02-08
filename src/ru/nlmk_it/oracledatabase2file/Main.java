/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file;

import com.beust.jcommander.JCommander;
import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Collection;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.core.LoggerContext;
import ru.nlmk_it.oracledatabase2file.arguments.Arguments;

/**
 *
 * @author Косых Евгений
 */
public final class Main {
    
    private static final Logger LOGGER = LogManager.getLogger();
    
    /**
     * 
     * @param args Command-line arguments
     */
    public static void main(String[] args) {
        reconfigurationLog4j2();
        LOGGER.info("The program started with arguments: {}", Arrays.toString(args));
        
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
            
            arguments.setParametersFromConfigFile(new File(System.getProperty("db2file.configurationFile")));
            
            try (OracleDatabase2File exporter = new OracleDatabase2File(arguments)) {
                exporter.execute();
            }
        }
        catch (IOException | SQLException | RuntimeException t) {
            LOGGER.fatal("Fatal error: ", t);
        }
        finally {
            LOGGER.info("Closing log writer.");
        }
    }
    
    /**
     * 
     */
    private static void reconfigurationLog4j2() {
        
        /*
        Цель: нужно, чтобы приложение создавало новый файл лога каждый запуск.
        
        Ситауация: Log4j2 создаёт новый файл либо в соответствии со временем,
        либо при достижении заданного размера. Опция для создания нового файла
        при запуске в конфигурационном файле есть, но она не работает.
        
        При запуске нового приложения нужно текущий файл логов переименовать,
        добавив к нему временной штамп. А также было бы неплохо и переименовать
        на основе заданного SQL сценария.
        */
        
        LoggerContext context = (LoggerContext) LogManager.getContext(false);
        
        Collection<org.apache.logging.log4j.core.Logger> loggers = context.getLoggers();
        
        
    }
}
