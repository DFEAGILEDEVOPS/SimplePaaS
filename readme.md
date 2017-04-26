# Contoso University ASP.NET Core and Entity Framework Core with SQLServer on Docker (Linux/Mac)

Contoso University demonstrates how to use Entity Framework Core in an
ASP.NET Core MVC web application. This repository makes minor patches to be
able to configure the connection settings via Environment Variables. It also
provides some yaml file to deploy the demo app and SQLServer Linux on Docker
to run on Mac OS (Mac OSX).

## Run It with Docker on Mac OS

_Personal Opinion:_ I recommend using with "Docker for Mac" as there is less messing around with network issues than using a brew install of Docker Engine. Visual Studio 2017 now has good support for "Docker for Windows" so the ocker native tooling seems to be something that Microsoft are getting behind.

First start up SQLServer on under docker with:

```docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=<YourStrong!Passw0rd>' -p 1433:1433 -d microsoft/mssql-server-linux
```

Now we need to run the `SqlServer.sql` script into the database to create the tables:

```# replace d961b29f54df with your container uid found using "docker ps"
docker cp SqlServer.sql d961b29f54df:/var/opt/mssql/data/SqlServer.sql
# login
docker exec -it d961b29f54df bash
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '<YourStrong!Passw0rd>' -i /var/opt/mssql/data/SqlServer.sql
# now login and query a table to check it is there. use exit twice to quite out to the host
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '<YourStrong!Passw0rd>'
1> select * from [dbo].[Person];
2> go
```

You can also use Visual Studio Code the free cross platform IDE to execute SQL against MS SQLServer following the instructions at https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-develop-use-vscode

Now set an connection string Environment Variable which points to that database and build and run the code against it:

```
ConnectionStrings__DefaultConnection="Server=10.229.45.241;Database=mydatabase;User Id=sa;Password=<YourStrong"'!'"Passw0rd>"
export ConnectionStrings__DefaultConnection
dotnet restore
dotnet run
```

It should come up on http://localhost:5000 and allow you to query or create students etc.

## Download it

Download the [completed project](https://github.com/aspnet/Docs/tree/master/aspnetcore/data/ef-mvc/intro/samples/cu-final) from GitHub by downloading or cloning the [aspnet/Docs repository](https://github.com/aspnet/Docs) and navigating to `aspnetcore\data\ef-mvc\intro\samples\cu-final` in your local file system.  After downloading the project, create the database by entering `dotnet ef database update` at a command-line prompt. As an alternative you can use **Package Manager Console** -- for more information, see [Command-line interface (CLI) vs. Package Manager Console (PMC)](https://docs.microsoft.com/en-us/aspnet/core/data/ef-mvc/migrations#command-line-interface-cli-vs-package-manager-console-pmc).
