@echo off
 
set Cont  =

echo MsgBox "El cable a llegado a su limite de usos.", 48, "ADVERTENCIA" >%temp%\mensaje.vbs

FOR /F          %%a IN (Contador.txt) DO CALL:Proceso  %%a
FOR /F "skip=1" %%a IN (Contador.txt) DO echo.%%a>>Contador.tmp

if %suma% GEQ 10 start %temp%\mensaje.vbs

GOTO:EOF

:Proceso
if not "%Cont%" == "" GOTO:EOF
if     "%Cont%" == "" set Cont=%1
set /a suma = %Cont% + 1
echo %suma%
del Contador.txt
echo %suma% > Contador.txt

GOTO:EOF