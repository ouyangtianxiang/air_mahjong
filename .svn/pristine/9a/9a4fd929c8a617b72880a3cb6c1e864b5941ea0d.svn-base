for /r %%i in (*.%1) do G:\ATFtools\windows\png2atf.exe -c d -n 0,0 -i %%~pi%%~ni.png -o %%~pi%%~ni._atd
for /r %%i in (*.%1) do G:\ATFtools\windows\png2atf.exe -c e -n 0,0 -i %%~pi%%~ni.png -o %%~pi%%~ni._ate
for /r %%i in (*.%1) do G:\ATFtools\windows\png2atf.exe -c p -n 0,0 -i %%~pi%%~ni.png -o %%~pi%%~ni._atp

set classpath=%~dp0;classpath
"D:\Program Files\Java\jre7\bin\java"  MyZip

pause