## Interview questions
1. What is DevOps how do you devops ?
2. What is a microservice and what are the advantages of it over monolithic
3. Why REST ?
4. How streaming services works design a messaging system.
5. Why you’re passionate about being an engineering manager at xxx in particular.
6. How you approach engineering management.
7. The team you’re most proud of supporting, and your role in helping it succeed.

## Time series database design
X = (t,v,q)
[*] Most of the time every data point is handled as a new entry instead of as an update for already saved data entry
[*] time series data usually is in time order when it arrives.
[*] third characteristic is time indexed data, making time the primary axis for the data
[*] Timestamp and k.v(Integer, String, floats and booleans)
[*] InfluxQL is SQL like language 

Elasticsearch support near real-time
reading which allows it to be used as NoSQL database. Elasticsearch uses JSON
formatted documents as it datatypes which allow users to create their own data
schema. As Elasticsearch is mainly a search and analytics engine, it has support for
extended querying with multiple aggregating, filtering, and indexing functions. Data
can be accessed through the REST API. Elasticsearch support scalability to multiple
nodes and replication.

. Scalability
. Security
. Availability
. Performance

## Databases

[*] Postgres  [link](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-18-04)

/usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/main -l logfile start

# Add user
createuser --interactive --pwprompt
Add database 
createdb movies

# System Design interviews
## Loadbalancer
1. Software LoadBalancer
2. Hardware Loadbalancer

### Loadbalancing algortithms
[*] Round Robin – Requests are distributed across the group of servers sequentially.
[*] Least Connections – A new request is sent to the server with the fewest current connections to clients. The relative computing capacity of each server is factored into determining which one has the least connections.
[*] Least Time – Sends requests to the server selected by a formula that combines the
fastest response time and fewest active connections.
[*] Hash – Distributes requests based on a key you define, such as the client IP address or
the request URL. 
[*] IP Hash – The IP address of the client is used to determine which server receives the request.
[*] Random with Two Choices – Picks two servers at random and sends the request to the
one that is selected by then applying the Least Connections algorithm (or for NGINX Plus
the Least Time algorithm, if so configured).

Session Persistence or Stickieness - > Two options either determined through the hash function which calculates hash based on the browser saved cookies else
stores the data locally at the load balancer.

L7 vs L4 Load balancing L7 is more CPU intensive as it has to do more processing till the packet reaches application layer rather at networking level.