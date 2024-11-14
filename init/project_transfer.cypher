CALL gds.graph.project('SecondPartyFraudNetwork',
    'Client',
    'TRANSFER_TO',
    {relationshipProperties:'amount'}
);