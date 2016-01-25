/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.arguments;

import java.io.File;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author Косых Евгений
 */
public class ArgumentsTest {

    /**
     * Test of setParametersFromConfigFile method, of class Arguments.
     * @throws java.lang.Exception
     */
    @Test
    public void testSetParametersFromConfigFile() throws Exception {
        
        Arguments arguments = new Arguments();
        arguments.setParametersFromConfigFile(new File("./etc/parameters.property"));
        
        assertNotNull(arguments.getURL());
        assertNotNull(arguments.getLogin());
        assertNotNull(arguments.getPassword());
        assertNotNull(arguments.getSqlVariableMarker());
    }

    /**
     * Test of validate method, of class Arguments.
     */
    @Test
    public void testValidate() {
    }
}
