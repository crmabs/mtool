@echo off
REM dir /B /N /W /S %1\*.%2 
REM same type in tree
REM [dir name] [extension]
FOR /F "tokens=*" %%a IN ('dir /B /N /W /S %1\*.%2') DO echo %%a 