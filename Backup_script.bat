:to do
:subir el backup en la carpeta comporatida \\servidor_backup\fw-backup
:generar backup con SSH public key
:Securizar el proceso de backup
:integrar repo git
color 2
@ECHO ###########################################################################
@ECHO # Backup Script  FortiGate                                    		#
@ECHO # By Artur                                                   #
@ECHO # Mailto: xxxxx@xxx.com                                          	#
@ECHO # Created on 15/05/2017                                                   #
@ECHO ###########################################################################



:modificar datestamp por -
FOR /f %%a IN ('WMIC OS GET LocalDateTime ^| FIND "."') DO SET DTS=%%a
SET DateTime=%DTS:~6,2%-%DTS:~4,2%-%DTS:~0,4%_%DTS:~8,2%-%DTS:~10,2%-%DTS:~12,2%
cd C:\Program Files\PuTTY
pscp -pw passw00rd backup@192.168.1.99:sys_config C:\Users\admin\Desktop\backup_test\Fw-test%DateTime%.conf
