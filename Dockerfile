FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as build
ARG NUGET_USERNAME
ARG NUGET_API_KEY

WORKDIR /build

COPY ./nuget.config ./

COPY ./NugetConsumerApi/NugetConsumerApi.csproj ./NugetConsumerApi/NugetConsumerApi.csproj
COPY github-nuget-consumer.sln .

RUN sed -i -e "s/ACTOR/$NUGET_USERNAME/g" -e "s/APIKEY/$NUGET_API_KEY/g" nuget.config

#RUN dotnet restore --configfile nuget.config github-nuget-consumer.sln
RUN dotnet restore github-nuget-consumer.sln

COPY . .

RUN dotnet publish ./NugetConsumerApi/NugetConsumerApi.csproj -c Release -o /publish

RUN rm nuget.config

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 as runtime
WORKDIR /api

COPY --from=build /publish .

CMD ["dotnet", "NugetConsumerApi.dll"]

#NOTE: Build Image Command 
# docker build -t nuget-consumer-api —build-arg GITHUB_ACTOR=[GITUB_USER] —build-arg GITHUB_TOKEN=[GITHUB_TOKEN] .