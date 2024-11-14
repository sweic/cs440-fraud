CALL gds.graph.project('wcc',
    {
        Client: {
            label: 'Client'
        }
    },
    {
        SHARED_IDENTIFIERS:{
            type: 'SHARED_IDENTIFIERS',
            orientation: 'UNDIRECTED',
            properties: {
                count: {
                    property: 'count'
                }
            }
        }
    }
) YIELD graphName,nodeCount,relationshipCount,projectMillis;
