// Visualise shared relationship
MATCH p = (c1:Client) - [s:SHARED_IDENTIFIERS] -> (c2:Client)
WHERE s.count >= 2
WITH c1, c2, s, p
MATCH r1 = (c1) -[:HAS_SSN|HAS_EMAIL|HAS_PHONE]->(other1)
MATCH r2 = (c2) -[:HAS_SSN|HAS_EMAIL|HAS_PHONE]->(other2)
WHERE other1 = other2
RETURN p, r1, r2
LIMIT 25;


// Visualise WCC fraud rings

MATCH (c:Client)
WITH c.firstPartyFraudGroup AS fpGroupID, collect(c.id) AS fGroup
WITH *, size(fGroup) AS groupSize WHERE groupSize = 5
WITH collect(fpGroupID) AS fraudRings
MATCH p=(c:Client)-[:HAS_SSN|HAS_EMAIL|HAS_PHONE|SHARED_IDENTIFIERS]->()
WHERE c.firstPartyFraudGroup IN fraudRings
RETURN p

// Jaccard Score

MATCH p = (c1:Client) -[s:SIMILAR_TO]-> (c2:Client)
WITH c1, c2, p, s
MATCH r1 = (c1) -[:HAS_SSN|HAS_EMAIL|HAS_PHONE]->(other1)
MATCH r2 = (c2) -[:HAS_SSN|HAS_EMAIL|HAS_PHONE]->(other2)
WHERE other1 = other2 AND s.jaccardScore >= 0.5 
RETURN p, r1, r2
LIMIT 25;


// Weighted degree similarity

MATCH (c:Client)
WHERE c.firstPartyFraudScore IS NOT NULL
WITH percentileCont(c.firstPartyFraudScore, 0.90) AS highScoreThreshold

MATCH p = (c:Client) -[s:SIMILAR_TO]-> (other:Client)
WHERE c.firstPartyFraudScore >= highScoreThreshold
RETURN p
LIMIT 25;

// Visualise transfer to from client <-> fraudster for 2nd party

MATCH p=(:Client:FirstPartyFraudster)-[:TRANSFER_TO]-(c:Client)
WHERE NOT c:FirstPartyFraudster
RETURN p;

// Visualise second party fraud score

MATCH p=(:Client:FirstPartyFraudster)-[:TRANSFER_TO]-(c:Client)
WHERE NOT c:FirstPartyFraudster
RETURN p;

MATCH (c:Client:SecondPartyFraud)-[r]->(otherClient:Client)
RETURN c, r, otherClient
ORDER BY c.secondPartyFraudScore DESC
LIMIT 100

// Visualise PageRank
MATCH (n:Client)
WHERE n.secondPartyFraudGroup IS NOT NULL
WITH collect(n) as nodes

UNWIND nodes as n1
UNWIND nodes as n2
MATCH (n1)-[r:TRANSFER_TO]->(n2)
WHERE n1 IN nodes AND n2 IN nodes

RETURN DISTINCT
    n1 as source,
    n2 as target,
    r.amount as amount;