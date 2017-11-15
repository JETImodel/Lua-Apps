@REM Installation of F3K Training App V1.0.2 on Jeti Transmitters
@echo off
@echo ================================
@echo connection  transmitter
@echo ================================
@echo connect your transmitter USB and type in the drive letter e.g. E
@Set /P transmitter=SET transmitter:
@echo ================================
IF not exist %transmitter%:\apps\*.* goto  FAILPATH
@echo ================================
@echo Partial transmitter backup required ?
@echo ================================
@echo If partial backup should be done, type in Y or J 
@Set /P backup=SET backup:
IF "%backup%"=="Y" goto PARTIAL
IF "%backup%"=="y" goto PARTIAL
IF "%backup%"=="J" goto PARTIAL
IF "%backup%"=="j" goto PARTIAL
goto INSTAL

:PARTIAL
@echo ================================
@echo generating partial backup of transmitter, pleas wait
@echo ================================
set "backupFolder=%date%_partial"
IF exist %backupFolder% rd %backupFolder% /S /Q
md %backupFolder%
IF not exist %backupFolder% goto FAILPATH_BACK 
cd %backupFolder%
md Apps
cd ..
XCOPY /S %transmitter%:\Apps %backupFolder%\Apps  
cd %backupFolder%
md Audio
cd ..
XCOPY /S %transmitter%:\Audio %backupFolder%\Audio 
cd %backupFolder%
md Model
cd ..
XCOPY /S %transmitter%:\Model %backupFolder%\Model 
@echo ================================
@echo partial transmitter backup successful finished
@echo ================================

:INSTAL
@echo delete old files on transmitter please wait
setlocal
%transmitter%:
cd apps\F3K
rd /s /q Logs
endlocal
rd %transmitter%:\apps\F3K /S /Q && md %transmitter%:\apps\F3K
del %transmitter%:\audio\de\F3K*.*
del %transmitter%:\audio\en\F3K*.*
del %transmitter%:\apps\F3K.*
del %transmitter%:\audio\F3K*.*
@echo ================================
@echo copy new files to transmitter please wait
IF not exist apps\*.* goto FAILPATH_UPD
setlocal
%transmitter%:
cd apps
md F3K
cd F3K
md Logs
endlocal
XCOPY /S apps\f3k %transmitter%:\apps\f3k
copy apps\F3K.lc %transmitter%:\apps
copy audio\de\F3K*.wav %transmitter%:\audio\de
copy audio\en\F3K*.wav %transmitter%:\audio\en

@echo ================================
@echo installation successful finished
@echo ================================
goto END

:FAILPATH
@echo Installation failed transmitter is not connected or drive letter for transmitter is not correct
goto END
:FAILPATH_UPD
@echo Installation failed the apps folder does not exist.
goto END

:END
@PAUSE

