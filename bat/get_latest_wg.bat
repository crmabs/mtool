@echo OFF

echo " "
echo "You are about to update all stuff / submodules and things!"
echo " "



setlocal
:PROMPT
SET /P AREYOUSURE=Are you sure (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END

git submodule foreach --recursive git pull origin master

:END
endlocal