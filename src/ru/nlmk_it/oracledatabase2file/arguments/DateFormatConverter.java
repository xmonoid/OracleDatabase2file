/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.arguments;

import com.beust.jcommander.IStringConverter;
import com.beust.jcommander.ParameterException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author Косых Евгений
 */
public final class DateFormatConverter implements IStringConverter<DateFormat> {
    
    private static final Logger LOGGER = LogManager.getLogger(DateFormatConverter.class);

    @Override
    public DateFormat convert(String value) {
        LOGGER.trace("The method convert() was invoked:\n"
                + "\tString value => " + value);
        try {
            
            DateFormat result = new SimpleDateFormat(value);
            
            LOGGER.trace("convert() returned => " + result);
            return result;
        }
        catch (IllegalArgumentException | NullPointerException e) {
            
            throw new ParameterException(e);
        }
    }
    
}
