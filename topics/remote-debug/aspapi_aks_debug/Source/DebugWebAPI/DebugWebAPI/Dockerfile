#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.
FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine-amd64 AS base
# Install Visual Studio Snapshot Debugger prerequisites
RUN apk update \
    && apk add libxml2 libuuid libunwind

# Install Visual Studio Snapshot Debugger
ARG VSSNAPSHOTDEBUGGER_VERSION=2.0.26
ARG VSSNAPSHOTDEBUGGER_SHA512=9aae6abddf4c2e1fd9e2eee57a63bceea51443be8fee34ea758a28ee95da3057310e04abd59454487fd3e44c1d4e0866259daf90a72ed661141ccc478437c742
RUN wget -O vssnapshotdebugger.tar.gz "https://aka.ms/vssnapshotdebugger/release/${VSSNAPSHOTDEBUGGER_VERSION}/vssnapshotdebugger-${VSSNAPSHOTDEBUGGER_VERSION}-linux-musl-x64.tar.gz" \
    && echo "${VSSNAPSHOTDEBUGGER_SHA512}  vssnapshotdebugger.tar.gz" | sha512sum -c - \
    && mkdir -p /diag \
    && mkdir -p /tmp/diag \
    && tar -pzxf vssnapshotdebugger.tar.gz -C /diag \
    && rm vssnapshotdebugger.tar.gz

# Set environment variables to load Visual Studio Snapshot Debugger into .NET Core applications
ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={324F817A-7420-4E6D-B3C1-143FBED6D855}
ENV CORECLR_PROFILER_PATH_64=/diag/Instrumentation64/libInstrumentationEngine.so
ENV MicrosoftInstrumentationEngine_ConfigPath64_SnapshotDebugger=/diag/Instrumentation64/ProductionBreakpoints_x64.config
ENV MicrosoftInstrumentationEngine_FileLog=Errors
ENV MicrosoftInstrumentationEngine_FileLogPath=/tmp/diag/log.txt
ENV MicrosoftProductionDiagnostics_RuntimeFolder=/diag/Runtime
ENV MicrosoftProductionDiagnostics_UtilsPath=/diag/Utils/ProductionBreakpointsUtils.dll

# Install Visual Studio Debugger
# Check the repo's README for vsdbg version compatibility with Visual Studio
RUN wget -O getvsdbg.sh "https://aka.ms/getvsdbgsh" \
    && sh ./getvsdbg.sh -v vs2019 -l /diag/vsdbg \
    && rm getvsdbg.sh


WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["DebugWebAPI/DebugWebAPI.csproj", "DebugWebAPI/"]
RUN dotnet restore "DebugWebAPI/DebugWebAPI.csproj"
COPY . .
WORKDIR "/src/DebugWebAPI"
RUN dotnet build "DebugWebAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DebugWebAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DebugWebAPI.dll"]