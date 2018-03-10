for /r %%i in (*.%1) do G:\ATFtools\windows\png2atf.exe -n 0,0 -i %%~pi%%~ni.png -o %%~pi%%~ni._atd
for /r %%i in (*.%1) do G:\ATFtools\windows\png2atf.exe -n 0,0 -i %%~pi%%~ni.png -o %%~pi%%~ni._ate
for /r %%i in (*.%1) do G:\ATFtools\windows\png2atf.exe -n 0,0 -i %%~pi%%~ni.png -o %%~pi%%~ni._atp

set classpath=%~dp0;classpath
java  MyZip

pause