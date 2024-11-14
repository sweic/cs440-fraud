# Use the Neo4j base image
FROM neo4j:5.24

# Disable authentication and set the default database
ENV NEO4J_dbms_security_auth__enabled=false
ENV NEO4J_dbms_default__database=fraud
ENV NEO4J_dbms_security_procedures_unrestricted=gds.*,apoc.*

# Copy the dump file into the container
RUN mkdir -p /dumps
COPY ./dumps/fraud.dump /dumps
COPY ./plugins /var/lib/neo4j/plugins
COPY ./init /var/lib/neo4j/init
RUN chmod +x /var/lib/neo4j/init/setup.sh
# Run the load command and start the server
CMD neo4j-admin database load fraud --from-path=/dumps && \ 
    neo4j console
