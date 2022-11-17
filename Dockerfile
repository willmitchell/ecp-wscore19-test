FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS base
WORKDIR /app
# TODO install dotnet 6.0
# TODO Add Windows Capabilities

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
ENTRYPOINT ["dotnet", "ecp-wscore19-test.dll"]
