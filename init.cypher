// Create relationship

MATCH (c1:Client)-[:HAS_EMAIL|:HAS_PHONE|:HAS_SSN] ->(n)<- [:HAS_EMAIL|:HAS_PHONE|:HAS_SSN]-(c2:Client)
WHERE id(c1) < id(c2)
WITH c1, c2, count(*) as cnt
MERGE (c1) - [:SHARED_IDENTIFIERS {count: cnt}] -> (c2);

// Project to WCC

CALL gds.graph.project('wcc',
    {
        Client: {
            label: 'Client'
        }
    },
    {
        SHARED_IDENTIFIERS:{
            type: 'SHARED_IDENTIFIERS',
            orientation: 'UNDIRECTED',
            properties: {
                count: {
                    property: 'count'
                }
            }
        }
    }
) YIELD graphName,nodeCount,relationshipCount,projectMillis;

// Write WCC back to database

CALL gds.wcc.stream('wcc',
    {
        nodeLabels: ['Client'],
        relationshipTypes: ['SHARED_IDENTIFIERS'],
        consecutiveIds: true
    }
)
YIELD componentId, nodeId
WITH componentId AS cluster, gds.util.asNode(nodeId) AS client
WITH cluster, collect(client.id) AS clients
WITH cluster, clients, size(clients) AS clusterSize WHERE clusterSize > 1
UNWIND clients AS client
MATCH (c:Client) WHERE c.id = client
SET c.firstPartyFraudGroup=cluster;

// Calculate node similarity

MATCH(c:Client) WHERE c.firstPartyFraudGroup is not NULL
WITH collect(c) as clients
MATCH(n) WHERE n:Email OR n:Phone OR n:SSN
WITH clients, collect(n) as identifiers
WITH clients + identifiers as nodes

MATCH(c:Client) -[:HAS_EMAIL|:HAS_PHONE|:HAS_SSN]->(id)
WHERE c.firstPartyFraudGroup is not NULL
WITH nodes, collect({source: c, target: id}) as relationships

CALL gds.graph.project.cypher('similarity',
    "UNWIND $nodes as n RETURN id(n) AS id,labels(n) AS labels",
    "UNWIND $relationships as r RETURN id(r['source']) AS source, id(r['target']) AS target, 'HAS_IDENTIFIER' as type",
    { parameters: {nodes: nodes, relationships: relationships}}
)
YIELD graphName, nodeCount, relationshipCount, projectMillis
RETURN graphName, nodeCount, relationshipCount, projectMillis

// Mutate to jaccardScore

CALL gds.nodeSimilarity.mutate('similarity',
    {
        topK:15,
        mutateProperty: 'jaccardScore',
        mutateRelationshipType:'SIMILAR_TO'
    }
);

// Write jaccard back to database

CALL gds.graph.writeRelationship('similarity', 'SIMILAR_TO', 'jaccardScore');

// Write back degree centrality score back to database

CALL gds.degree.write('similarity',
    {
        nodeLabels: ['Client'],
        relationshipTypes: ['SIMILAR_TO'],
        relationshipWeightProperty: 'jaccardScore',
        writeProperty: 'firstPartyFraudScore'
    }
);

// Attach fraudster label with jaccardScore

MATCH(c:Client)
WHERE c.firstPartyFraudScore IS NOT NULL
WITH percentileCont(c.firstPartyFraudScore, 0.95) AS firstPartyFraudThreshold

MATCH(c:Client)
WHERE c.firstPartyFraudScore > firstPartyFraudThreshold
SET c:FirstPartyFraudster;

// Create transfer to from fraudster to client

MATCH (c1:FirstPartyFraudster)-[]->(t:Transaction)-[]->(c2:Client)
WHERE NOT c2:FirstPartyFraudster
WITH c1, c2, sum(t.amount) AS totalAmount
SET c2:SecondPartyFraudSuspect
CREATE (c1)-[:TRANSFER_TO {amount:totalAmount}]->(c2);

// Create transfer to from client to fraudster

MATCH (c1:FirstPartyFraudster)<-[]-(t:Transaction)<-[]-(c2:Client)
WHERE NOT c2:FirstPartyFraudster
WITH c1, c2, sum(t.amount) AS totalAmount
SET c2:SecondPartyFraudSuspect
CREATE (c1)<-[:TRANSFER_TO {amount:totalAmount}]-(c2);

// Project graph for transfer to

CALL gds.graph.project('SecondPartyFraudNetwork',
    'Client',
    'TRANSFER_TO',
    {relationshipProperties:'amount'}
);


// Write back to datagbase

CALL gds.wcc.stream('SecondPartyFraudNetwork')
YIELD nodeId, componentId
WITH gds.util.asNode(nodeId) AS client, componentId AS clusterId
WITH clusterId, collect(client.id) AS cluster
WITH clusterId, size(cluster) AS clusterSize, cluster
WHERE clusterSize > 1
UNWIND cluster AS client
MATCH(c:Client {id:client})
SET c.secondPartyFraudGroup=clusterId;

// Use pagerank

CALL gds.pageRank.stream('SecondPartyFraudNetwork',
    {relationshipWeightProperty:'amount'}
)YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS client, score AS pageRankScore

WHERE client.secondPartyFraudGroup IS NOT NULL
        AND pageRankScore > 0 AND NOT client:FirstPartyFraudster

MATCH(c:Client {id:client.id})
SET c:SecondPartyFraud
SET c.secondPartyFraudScore = pageRankScore;

// cleanup 
CALL gds.graph.list()
YIELD graphName AS namedGraph
WITH namedGraph
CALL gds.graph.drop(namedGraph)
YIELD graphName
RETURN graphName;
