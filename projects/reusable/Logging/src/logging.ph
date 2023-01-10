import { Exception, Console, DateTime } from 'System';
import { StreamWriter, File, FileMode } from 'System/IO';
import { Thread } from 'System/Threading';

export enum LogLevel {
    VERBOSE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
}

export class Logger {
    public logLevel: LogLevel;
    public stdOut: bool;

    private _lock: object = new object();
    public fileOut: string;

    private logFileWriter: StreamWriter;

    constructor(logLevel:LogLevel, fileOut: string = '') {
        this.fileOut = fileOut;
        this.logLevel = logLevel;

        if (this.fileOut != '') {
            this.logFileWriter = new StreamWriter(File.Open(fileOut, FileMode.Append));
        }
    }

    public Log(message: string, loglevel: LogLevel): void {
        if (this.CanLog(loglevel)) {
            lock(this._lock) {
                if (this.stdOut) {
                    Console.WriteLine(message);
                }
                if (this.logFileWriter != null) {
                    this.logFileWriter.WriteLine(
                        `[${DateTime.Now.ToString('HH:mm:ss')}][${
                            Thread.CurrentThread.Name
                        }]${message}`
                    );
                }
            }
        }
    }

    public CanLog(requestedLogLevel: LogLevel): bool {
        return requestedLogLevel >= this.logLevel;
    }

    public Info(error: Exception): void {
        this.Log(error.ToString(), LogLevel.INFO);
    }

    public Info(message: string): void {
        this.Log(message, LogLevel.INFO);
    }

    public Error(message: string): void {
        this.Log(message, LogLevel.ERROR);
    }

    public Error(error: Exception): void {
        this.Log(error.ToString(), LogLevel.ERROR);
    }

    public Error(message: string, e: Exception): void {
        this.Log(message + ': ' + e.Message, LogLevel.ERROR);
    }

    public Verbose(error: Exception): void {
        this.Log(error.ToString(), LogLevel.VERBOSE);
    }

    public Verbose(message: string): void {
        this.Log(message, LogLevel.VERBOSE);
    }

    public Debug(error: Exception): void {
        this.Log(error.ToString(), LogLevel.DEBUG);
    }

    public Debug(message: string): void {
        this.Log(message, LogLevel.DEBUG);
    }

    public Warn(error: Exception): void {
        this.Log(error.ToString(), LogLevel.WARN);
    }

    public Warn(message: string): void {
        this.Log(message, LogLevel.WARN);
    }
}
