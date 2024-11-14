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