
for /r %%i in (*.png) do G:\ATFtools\windows\png2atf.exe -n 0,0 -i %%~pi%%~ni.png -o %%~pi%%~ni.atf


pause