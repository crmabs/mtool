@echo off
set fnd=\
set rep=\\
set str=%1
call set str=%%str:%fnd%=%rep%%%
echo %str%