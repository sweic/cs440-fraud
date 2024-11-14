// Visualise shared relationship
MATCH p = (c1:Client) - [s:SHARED_IDENTIFIERS] -> (c2:Client)
WHERE s.count >= 2
WITH c1, c2, s, p
MATCH r1 = (c1) -[:HAS_SSN|HAS_EMAIL|HAS_PHONE]->(other1)
MATCH r2 = (c2) -[:HAS_SSN|HAS_EMAIL|HAS_PHONE]->(other2)
WHERE other1 = other2
RETURN p, r1, r2
LIMIT 25;
