// Jaccard Similarity

MATCH p = (c1:Client) -[s:SIMILAR_TO]-> (c2:Client)
WITH c1, c2, p, s
MATCH r1 = (c1) -[:HAS_SSN|HAS_EMAIL|HAS_PHONE]->(other1)
MATCH r2 = (c2) -[:HAS_SSN|HAS_EMAIL|HAS_PHONE]->(other2)
WHERE other1 = other2 AND s.jaccardScore >= 0.5 
RETURN p, r1, r2
LIMIT 25;
