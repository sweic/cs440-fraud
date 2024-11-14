CALL gds.nodeSimilarity.mutate('similarity',
    {
        topK:15,
        mutateProperty: 'jaccardScore',
        mutateRelationshipType:'SIMILAR_TO'
    }
);
