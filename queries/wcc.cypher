// Visualise WCC fraud rings

MATCH (c:Client)
WITH c.firstPartyFraudGroup AS fpGroupID, collect(c.id) AS fGroup
WITH *, size(fGroup) AS groupSize WHERE groupSize = 5
WITH collect(fpGroupID) AS fraudRings
MATCH p=(c:Client)-[:HAS_SSN|HAS_EMAIL|HAS_PHONE|SHARED_IDENTIFIERS]->()
WHERE c.firstPartyFraudGroup IN fraudRings
RETURN p