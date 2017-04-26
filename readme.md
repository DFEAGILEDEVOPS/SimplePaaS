# "Contoso University" ASP.NET Core and Entity Framework Core with SQLServer on Docker (Linux/Mac)

"Contoso University" demonstrates how to use Entity Framework Core in an
ASP.NET Core MVC web application. This repository makes minor patches to be
able to configure the connection settings via Environment Variables. The instructions below show how to run it all in OpenShift Origin PaaS on Mac OS. 

The code isn't aiming for production quality. By way of example the logging of SQL strings happens in production builds. In a real application you would use the DotNet core convensions of checking a standard Env Var to enable or disable it. Still those modifications are easy to make so why not have a go and send me a PR. 

## Run It with Docker on Mac OS

_Personal Opinion:_ I recommend using  "Docker for Mac" as there is less messing around with network issues than using a brew install of Docker Engine. Visual Studio 2017 now has good support for "Docker for Windows" so the Docker native tooling seems to be something that Microsoft are getting behind.

SQLServer wont get out of bed for less than 3.5G RAM so you need to up your memory settings on Docker for Mac and restart it. Then start up SQLServer on under docker with:

```
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=<YourStrong!Passw0rd>' -p 1433:1433 -d microsoft/mssql-server-linux
```

Now we need to create the database and tables with `SqlServer.sql`:

```
# replace d961b29f54df with your container uid shown using "docker ps"
docker cp SqlServer.sql d961b29f54df:/var/opt/mssql/data/SqlServer.sql
# login
docker exec -it d961b29f54df bash
# this will only outpout "Changed database context to 'mydatabase'."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '<YourStrong!Passw0rd>' -i /var/opt/mssql/data/SqlServer.sql
# query a table to check it is there. use exit twice to quite out to the host
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '<YourStrong!Passw0rd>'
1> use mydatabase;
2> GO
Changed database context to 'mydatabase'.
1> select * from [dbo].[OfficeAssignment];
2> GO
InstructorID Location                                          
------------ --------------------------------------------------

(0 rows affected)
1>
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

## Run It on Openshift Origin PaaS on Mac OS

First build the production release container which doesn't need a writable file system:

```
# build the production version
dotnet publish -c Release -o out
docker build -t cu-final-mssql .
```

If you have private containers you are going to have to "docker push" into the docker repo OpenShift will start up below. With opensource code is far easier to deploy via your own free account on docker hub:

```
# in the following commands you need to change "username" to be your docker hub user name
docker login
docker tag cu-final-mssql username/cu-final-mssql:latest
docker push username/cu-final-mssql:latest
```

_Personal Opinion:_ There are multiple ways to run Openshift PaaS on Mac and I found the old ways a real headache. The latest Openshift Origin "oc cluster up" approach is a breath of fresh air. I really wanted to use the enterprise distro but that doesn't yet support this developer friendly approach. 

At the time of writing Openshift thought that the latest stable Docker for Mac was using an unstable version number so refused to run. I had to downgrade to the previous stable Docker for Mac.

First create the machine if it is the first time. Note the user of the stable Origin 1.5.0 "oc" binary which has the cluster up feature and the use of the "alpha.3" server version to avoid a regression which slipped in after it:

```
# CREATE MACHINE here change the host data folder to your own folder
../openshift-origin-client-tools-v1.5.0/oc cluster up --version=v1.5.0-alpha.3 --create-machine=true   \
                --use-existing-config   \
                --host-data-dir=/Users/you/oc_data \
                --metrics=false
```

Now run the machine:

```
# RUN CLUSTER here change the host data folder to your own folder
../openshift-origin-client-tools-v1.5.0/oc cluster up --version=v1.5.0-alpha.3   \
                --use-existing-config   \
                --host-data-dir=/Users/you/oc_data  \
                --metrics=false
```

If you now run ```docker ps``` you should now see a load of Openshift services running in their own containers. 

In the following when I created a project on the command-line I got access denied trying to access it on the web console. If you run into that issue run `oc delete project cu-final-mssql` and recreated it via the web console.

Deploy SQLSerer into Openshift (OMG!):

```
# login to Openshift
oc login -u system:admin
# see warning above about perhaps not being able to login to this project
oc new-project cu-final-mssql
# in case this your second attempt after having to create the project via the web console
oc project cu-final-mssql
# check you have the volume I used in the pvc.yaml
oc get pv | fgrep pv0002
# If you didn't find it you are going to have to author some yaml to create it
# Create the persistent volume claim:
cat pvc.yaml | oc create -f -
# create the "mssql" SQLServer POD:
cat mssql_pod.yaml | oc create -f -
# create the "mssql" SQLServer service:
cat mssql_service.yaml | oc create -f -
```

Login to the web console and click on the logs tab of the POD check it is healthy.

You now need to run the `SQLServer.sql` against the database to create the tables.
Rather than creating a new image with the sql file in it with a mechanism
to start it I cheated. I logged into the openshift web console, selected the pod,
click on the Terminal tab, and open the sqlcmd tool and pasted in the SQL:

```
# Log in to the web console the url is shown at the bottom of the `oc cluster up` output
# open the Terminal tab of the pod to get into the running container
# check the sqlcmd tool is there
find / -name sqlcmd
# login to the local SQLServer as SA
/opt/mssql-tools/bin/sqlcmd -S 127.0.0.1 -U SA -P '<YourStrong!Passw0rd>'
# now paste the sql from SQLServer.sql. the terminal will badly format it. hit enter. 
...
# check that the last table got created by querying form it:
1> select * from  [dbo].[OfficeAssignment];                                                                                                                           
2> G0
```

Then deploy the app via the web console:

1. Log in to the web console the url is shown at the bottom of the `oc cluster up` output
2. Open the project
3. Browse to the mssql *service* and note down its IP address on its details page.
4. Click Add to Project at the top
5. Deploy image
6. Select Image Name and past in your image path on dockerhub e.g. `username/cu-final-mssql:latest`
7. Click on the search icon and wait for it to load the details. Ignore the warning about root user.
8. Set an Environment Variable "ConnectionStrings__DefaultConnection" with the following value edited with to contain the service IP address `Server=172.30.219.45;Database=mydatabase;User Id=sa;Password=<YourStrong!Passw0rd>`
9. Click on Create
10. Check that everything deployed correctly. On the pod log it should say its listening on port 5000.
11. On the Overview click on "Create Route" for the CU FINAL MSSQL service. Just hit Create.
12. The overview should show a http link to an xip.io url which opens a browser pointing at your apps IP address.
13. Navigate to the Student tab and click Create New to confirm you can write to the dataase.

Enjoy!
