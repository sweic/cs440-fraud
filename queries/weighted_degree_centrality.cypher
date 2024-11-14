// Weighted degree similarity

MATCH (c:Client)
WHERE c.firstPartyFraudScore IS NOT NULL
WITH percentileCont(c.firstPartyFraudScore, 0.90) AS highScoreThreshold

MATCH p = (c:Client) -[s:SIMILAR_TO]-> (other:Client)
WHERE c.firstPartyFraudScore >= highScoreThreshold
RETURN p
LIMIT 25;