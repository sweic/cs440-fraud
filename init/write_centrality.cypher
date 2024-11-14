CALL gds.degree.write('similarity',
    {
        nodeLabels: ['Client'],
        relationshipTypes: ['SIMILAR_TO'],
        relationshipWeightProperty: 'jaccardScore',
        writeProperty: 'firstPartyFraudScore'
    }
);