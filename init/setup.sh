#!/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR"
cypher-shell -f ./shared_identifiers.cypher
cypher-shell -f ./wcc.cypher
cypher-shell -f ./write_wcc.cypher
cypher-shell -f ./node_similarity.cypher
cypher-shell -f ./jaccard_score.cypher
cypher-shell -f ./write_jaccard.cypher
cypher-shell -f ./write_centrality.cypher
cypher-shell -f ./attach_label.cypher
cypher-shell -f ./create_transfer.cypher
cypher-shell -f ./create_transfer2.cypher
cypher-shell -f ./project_transfer.cypher
cypher-shell -f ./write_second_party.cypher
cypher-shell -f ./pagerank.cypher

