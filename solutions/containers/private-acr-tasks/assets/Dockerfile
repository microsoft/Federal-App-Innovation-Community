FROM mcr.microsoft.com/azure-cli
RUN az login --identity
RUN az storage blob download \
    --account-name teststghs123 \
    --container-name test \
    --file /tmp/test.txt \
    --auth-mode login \
    --name test.txt
ENTRYPOINT ["cat", "/tmp/test.txt"]