/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.arguments;

import com.beust.jcommander.IStringConverter;
import com.beust.jcommander.ParameterException;
import java.io.IOException;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * The class-converter for directory input.
 * @author Косых Евгений
 */
public class DirectoryConverter implements IStringConverter<Path> {
    
    private static final Logger LOGGER = LogManager.getLogger(DirectoryConverter.class);
    
    
    @Override
    public Path convert(String value) {
        LOGGER.trace("The method convert() was invoked\n"
                + "\tString value <= " + value);
        
        Path path = Paths.get(value);
        
        try {
            Files.createDirectory(path);
            LOGGER.trace("convert() returned => " + path.normalize());
            return path;
        }
        catch (FileAlreadyExistsException e) {
            LOGGER.trace("Directory already exists.");
            LOGGER.trace("convert() returned => " + path.normalize());
            return path;
        }
        catch (IOException e) {
            LOGGER.error(e, e);
            throw new ParameterException("Can't create the export directory: " + value);
        }
    }
}
