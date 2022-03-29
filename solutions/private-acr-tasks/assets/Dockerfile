FROM mcr.microsoft.com/azure-cli
RUN az cloud set --name AzureUSGovernment
RUN az login --identity
RUN az storage blob download \
    --account-name stgl5366k57ssoak \
    --container-name artifact \
    --file /tmp/test.txt \
    --auth-mode login \
    --name test.txt
ENTRYPOINT ["cat", "/tmp/test.txt"]