/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.arguments;

import ru.nlmk_it.oracledatabase2file.exporters.FiletypeEnum;
import com.beust.jcommander.IStringConverter;
import com.beust.jcommander.ParameterException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * The class-converter for filetype input.
 * @author Косых Евгений
 */
public class FiletypeEnumConverter implements IStringConverter<FiletypeEnum> {
    
    private static final Logger LOGGER = LogManager.getLogger(FiletypeEnumConverter.class);
    
    @Override
    public FiletypeEnum convert(String value) {
        LOGGER.trace("The method convert() was invoked\n"
                + "\tString value <= " + value);
        
        FiletypeEnum convertedValue = FiletypeEnum.valueOf(value.toUpperCase());
	
        if (convertedValue == null) {
            throw new ParameterException("The value " + value + " can't be converted to "
                    + FiletypeEnum.class.getName() + "."
                    + "Available values are: " + FiletypeEnum.toStringAll());
        }
        
        LOGGER.trace("convert() returned => " + convertedValue);
        return convertedValue;
    }
}
