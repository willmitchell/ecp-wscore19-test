FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS base
WORKDIR /app
RUN "powershell -c Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online; Install-WindowsFeature -Name 'RSAT-AD-PowerShell' -IncludeAllSubFeature"
RUN "powershell -c Invoke-WebRequest -Uri https://s3.amazonaws.com/aws-cli/AWSCLI64.msi -OutFile C:\AWSCLI64.msi; Start-Process msiexec.exe -Wait -ArgumentList '/i', 'C:\AWSCLI64.msi', '/qn', '/norestart'"
RUN "powershell -c $env:Path += ';C:\Program Files\Amazon\AWSCLIV2\'; [Environment]::SetEnvironmentVariable('Path', $env:Path, [EnvironmentVariableTarget]::Machine)"
ENV AWS_REGION=us-east-1

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["ecp-wscore19-test.csproj", "./"]
RUN dotnet restore "ecp-wscore19-test.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "ecp-wscore19-test.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -r win-x64 "ecp-wscore19-test.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["powershell"]
