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