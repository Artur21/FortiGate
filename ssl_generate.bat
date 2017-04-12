::Certificate Generation Batch Script for FortiGate VPN Authentication
::By: JVanDerZee
::Date: 2014-08-01

@echo off

echo Install these tools prior to running this script
echo.
echo C++ Redistributable Package (x64)
echo http://download.microsoft.com/download/d/2/4/d242c3fb-da5a-4542-ad66-f9661d0a8d19/vcredist_x64.exe
echo.
echo OpenSSL (x64)
echo https://slproweb.com/download/Win64OpenSSL_Light-1_0_1h.exe
echo.
echo.
echo Keep the pass phrase used to generate the certificate keys in a safe place  
echo I suggest making the passwords the same for both CA and Intermediate 
echo as well as the export pass
echo.
echo This script assumes you've install OpenSSL to the C:\OpenSSL directory
echo All your certificates (.cer, .p12) and key (.key) files will be initially 
echo stored in "C:\OpenSSL-Win64\bin" directory
echo Move them somewhere else if they need to be backed up.
echo.
Pause


set OPENSSL_CONF=C:\OpenSSL-Win64\bin\openssl.cfg

::Check path
echo.
echo Path to the openssl config file: %OPENSSL_CONF%
echo.
Pause

SET /P caname=Name of CA private key and cert (ex fgtca01):
SET /P intname=Name of intermediate key and cert (ex fgtint01):
SET /P pass=Password for keys, be sure to document!(ex pass123):
SET /P country=Enter your Country (ex US):
SET /P state=Enter your state (ex California):
SET /P days=How many days will the certs be valid (ex 3650 for 10yrs):

::Change to OpenSSL Directory
c:
cd C:\OpenSSL-Win64\bin\

::Create Certificate Authority Cert
openssl genrsa -des3 -out %caname%.key -passout pass:%pass% 2048
openssl req -new -x509 -days %days% -extensions v3_ca -key %caname%.key -out %caname%.crt -subj "/C=%country%/ST=%state%/CN=%caname%" -passin pass:%pass%

::Generate Intermediate Cert for use with VPN Client
openssl genrsa -des3 -out %intname%.key -passout pass:%pass% 2048
openssl req -new -key %intname%.key -out %intname%.csr -subj "/C=%country%/ST=%state%/CN=%intname%" -passin pass:%pass%
openssl x509 -req -days %days% -in %intname%.csr -CA %caname%.crt -CAkey %caname%.key -set_serial 02 -out %intname%.crt -passin pass:%pass%

::Generate combined key file to install on client PC.
openssl pkcs12 -export -in %intname%.crt -inkey %intname%.key -certfile %caname%.crt -name "%intname%" -out %intname%.p12 -password pass:%pass% -passin pass:%pass%

echo.
echo All keys have been generated!
echo.
echo You need to upload the CA cert "%caname%.crt" to the FortiGate under 
echo System ^> Certificates ^> CA Certificates
echo and the corresponding intermediate cert "%intname%.p12"
echo to the client machine, install to the automatic location.  
echo Require client certificates on the Fortigate SSL VPN Settings under
echo VPN ^> SSL ^> Settings ^> Require Client Certificate
echo. 
echo If a machine is compromised remove the CA from the FortiGate and the
echo client(s) with the intermediate cert will no longer have access.
echo.
pause
:END
