@echo on
REM dir /B /N /W /S %1\*.%2 
echo masik.bat
echo %1 %2
FOR /F "tokens=*" %%a IN ('%MWIN%\intree.bat %1 %2') DO  cmd /C %MWIN%\fupath.bat %%a

sleep 15