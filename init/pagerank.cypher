CALL gds.pageRank.stream('SecondPartyFraudNetwork',
    {relationshipWeightProperty:'amount'}
)YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS client, score AS pageRankScore

WHERE client.secondPartyFraudGroup IS NOT NULL
        AND pageRankScore > 0 AND NOT client:FirstPartyFraudster

MATCH(c:Client {id:client.id})
SET c:SecondPartyFraud
SET c.secondPartyFraudScore = pageRankScore;