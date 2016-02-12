package ru.nlmk_it.oracledatabase2file.logutils;

import java.io.File;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Layout;
import org.apache.log4j.spi.ErrorCode;

/**
 *
 * @author Косых Евгений
 */
public class NewLogForEachRunFileAppender extends FileAppender {
    
    public NewLogForEachRunFileAppender() {
	}

    public NewLogForEachRunFileAppender(
            Layout layout,
            String filename,
            boolean append,
            boolean bufferedIO,
            int bufferSize) throws IOException {
        super(layout, filename, append, bufferedIO, bufferSize);
    }

    public NewLogForEachRunFileAppender(
            Layout layout,
            String filename,
            boolean append) throws IOException {
        super(layout, filename, append);
    }

    public NewLogForEachRunFileAppender(
            Layout layout,
            String filename) throws IOException {
        super(layout, filename);
    }
    
//    @Override
//    public synchronized void activateOptions() {
//        if (fileName != null) {
//            try {
//                fileName = getNewLogFileName(null);
//                setFile(fileName, fileAppend, bufferedIO, bufferSize);
//            } catch (Exception e) {
//                errorHandler.error("Error while activating log options", e,
//                        ErrorCode.FILE_OPEN_FAILURE);
//            }
//        }
//    }
    
    private String getNewLogFileName(String newFileName) {
        if (fileName != null) {
            final DateFormat format = new SimpleDateFormat("dd.MM.yyyy-HH.mm.ss.SSS");
            final File logFile = new File(fileName);
            final String oldFileName = newFileName == null ? logFile.getName() : newFileName;

            final int dotIndex = oldFileName.lastIndexOf(".");
            if (dotIndex != -1) {
                // the file name has an extension. so, insert the time stamp
                // between the file name and the extension
                newFileName = oldFileName.substring(0, dotIndex) + "-"
                                + format.format(new Date()) + "."
                                + oldFileName.substring(dotIndex + 1);
            } else {
                // the file name has no extension. So, just append the timestamp
                // at the end.
                newFileName = oldFileName + "-" + format.format(new Date());
            }
            return logFile.getParent() + File.separator + newFileName;
        }
        return null;
    }
    
    @Override
    public synchronized void setFile(String file) {
        super.setFile(file);
    }
    
    /**
     * 
     * @param newName 
     */
    public synchronized void renameFile(String newName) {
        
        File oldFile = new File(fileName);
        if (fileName != null) {
            try {
                fileName = getNewLogFileName(newName);
                setFile(fileName, fileAppend, bufferedIO, bufferSize);
            } catch (Exception e) {
                errorHandler.error("Error while activating log options", e,
                        ErrorCode.FILE_OPEN_FAILURE);
            }
        }
        oldFile.delete();
    }
    
    public String getFileName() {
        return this.fileName;
    }
}
