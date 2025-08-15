# awsprojet-mcit
diagram using from website
![Project Graph](images/graph.webp)

-First what is the purpose of these project. Its to create a ressource to be able to host a standart web application with data base.

-Create two-tier AWS architecture containing the following:
-Custom VPC with:
2 Public Subnets for the Web Server Tier

2 Private Subnets for the RDS Tier

-Appropriate route tables

-Launch an EC2 Instance with your choice of webserver in each public web tier subnet (apache, NGINX, etc).

-One RDS MySQL Instance (micro) in the private RDS subnets

-Security Groups properly configured for needed resources ( web servers, RDS)

-Deploy this using Terraform Cloud as a CI/CD tool to check your build.

Here i am gonna explain how i decided each ressource i will use:

-Choosing a region to create all my ressource in it. That would be AWS us-east-1 region since its to closest region to where the client would be using it from.

-Using a vpc to isolate my project in the cloud.

-For the ec2 its gonna be the t2.micro since the web server will be ligth its enough to host it. Also using public subnet so it has access to internet.

-Using a load balancer so it will distribute the incomming traffic coming to the web application.

-Rds will be on private subnet for security purpose since it doesnt need access to the internet.

-For security purpose only poort that are essential will be open ssh(22) (http(80)since its free not viable in real life project should go with a https(443))

-Using terraform since once the code writted is quicker to make adjustment if need to scale afterward or need to recreate a similar project.


