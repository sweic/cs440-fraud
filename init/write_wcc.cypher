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