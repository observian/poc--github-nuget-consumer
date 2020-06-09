FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as build
ARG NUGET_USERNAME
ARG NUGET_API_KEY

COPY ./NugetConsumerApi/NugetConsumerApi.csproj ./NugetConsumerApi/NugetConsumerApi.csproj

COPY github-nuget-consumer.sln .
COPY nuget.config .
RUN echo NUGET_API_KEY=$NUGET_API_KEY
RUN sed -i "s/USERNAME/${NUGET_USERNAME}/g; s/TOKEN/${NUGET_API_KEY}/g" nuget.config
RUN cat nuget.config
RUN dotnet restore github-nuget-consumer.sln

COPY . .

RUN dotnet publish ./NugetConsumerApi/NugetConsumerApi.csproj -c Release -o /publish
RUN rm nuget.config

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 as runtime
WORKDIR /app

COPY --from=build /publish .
CMD ["dotnet", "NugetConsumerApi.dll"]
