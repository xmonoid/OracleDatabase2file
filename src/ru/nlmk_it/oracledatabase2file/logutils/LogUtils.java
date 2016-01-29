package ru.nlmk_it.oracledatabase2file.logutils;

/**
 * 
 * @author Косых Евгений
 */
public final class LogUtils {
    
    /**
     * 
     * @param logString
     * @return
     * @throws IllegalArgumentException 
     */
    public static String substring(String logString) throws IllegalArgumentException {
        return substring(logString, 50);
    }
    
    /**
     * 
     * @param logString
     * @param length
     * @return
     * @throws IllegalArgumentException 
     */
    public static String substring(String logString, int length) throws IllegalArgumentException {
        
        if (length <= 0) {
            throw new IllegalArgumentException("The length parameter must be more than 0");
        }
        
        if (logString == null)
            return "null";
        
        int logStringLength = logString.length();
        return  (logStringLength <= length ? logString
                : logString.substring(0, length) + "...(" +
                (logStringLength - length) + " symbols skipped)");
    }
}
