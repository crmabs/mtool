@echo off


REM echo %str%
REM echo %1 %2
REM echo lock placed  %2   %1

cmd /C %1 %2 %3 %4 %5

REM make dos path to delete the key
set fnd=/
set rep=\
set str=%MTRASH%
call set str=%%str:%fnd%=%rep%%%
REM delete the task key
del /Q /F %str%\%2


REM echo lock removed  %2    %1
REM sleep 10