# awsprojet-mcit
diagram using from website
![Project Graph](images/graph.webp)

First what is the purpose of these project. Its to create a ressource to be able to host a standart web application with data base.

Create two-tier AWS architecture containing the following:
Custom VPC with:
2 Public Subnets for the Web Server Tier

2 Private Subnets for the RDS Tier

Appropriate route tables

Launch an EC2 Instance with your choice of webserver in each public web tier subnet (apache, NGINX, etc).

One RDS MySQL Instance (micro) in the private RDS subnets

Security Groups properly configured for needed resources ( web servers, RDS)

Deploy this using Terraform Cloud as a CI/CD tool to check your build.

Here i am gonna explain how i decided each ressource i will use:

I am choosing a region to create all my ressource in it. That would be AWS us-east-1 region since its to closest region to where the client would be using it from.


