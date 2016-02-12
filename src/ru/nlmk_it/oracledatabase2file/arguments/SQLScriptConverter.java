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
import java.sql.SQLException;
import org.apache.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.database.SQLScript;

/**
 * The class that configures and builds {@see SQLScript} object.
 * @author Косых Евгений
 */
public final class SQLScriptConverter implements IStringConverter<SQLScript> {
    
    private static final Logger LOGGER = Logger.getLogger(SQLScriptConverter.class);
    
    @Override
    public SQLScript convert(String value) {
        LOGGER.trace("The method convert() was invoked\n"
                + "\tString value <= " + value);
		
        try {
            File f = new File(value);

            if (!f.isFile()) {
                throw new ParameterException(value + ": file not found");
            }

            if (!f.canRead()) {
                throw new ParameterException(value + ": unable to read file");
            }

            SQLScript result = new SQLScript(f);
            
            LOGGER.trace("convert() returned => " + result);
            return result;
        }
        catch (SQLException | IOException e) {
            LOGGER.error(e.getMessage(), e);
            throw new ParameterException(e);
        }
    }
    
}
