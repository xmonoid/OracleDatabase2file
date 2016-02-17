/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.arguments;

import com.beust.jcommander.IStringConverter;
import com.beust.jcommander.ParameterException;
import java.io.File;
import java.io.IOException;
import org.apache.log4j.Logger;

/**
 * The class-converter for directory input.
 * @author Косых Евгений
 */
public final class DirectoryConverter implements IStringConverter<File> {
    
    private static final Logger LOGGER = Logger.getLogger(DirectoryConverter.class);
    
    
    @Override
    public File convert(String value) {
        LOGGER.trace("The method convert() was invoked\n"
                + "\tString value <= " + value);
        
        File path = new File(value);
        
        try {
            path.mkdirs();
            LOGGER.trace("convert() returned => " + path.getCanonicalPath());
            return path;
        }
        catch (IOException e) {
            LOGGER.error(e, e);
            throw new ParameterException("Can't create the export directory: " + value);
        }
    }
}
