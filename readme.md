# CS440 Fraud Detection in Fintech

This project, "Fraud Detection in Fintech," demonstrates fraud detection capabilities using Neo4j, focusing on fintech data analysis with graph-based approaches. The setup includes Dockerized Neo4j with sample data to visualize fraud patterns, relationships between entities and aggregated graph algorithms.

## Live Demo

A live hosted application is available for demonstration at [http://145.223.20.213:7474/](http://145.223.20.213:7474/). Once on the browser console, connect to the database at `bolt://145.223.20.213:7687` without any username/password. You can access the Neo4j console and explore the data directly without setting up the application locally. You can use the cypher commands found in the `./queries` folder.

## Getting Started

The project provides a Docker setup for easy deployment. You can either build the Docker image from the provided Dockerfile or pull the prebuilt image from Docker Hub.

### Prerequisites

- [Docker](https://www.docker.com/) installed on your machine.

### Docker Setup

1. **Clone the repository** (if applicable).
2. **Build the Docker Image (Optional):**

   ```bash
   docker build -t cs440-fraud-detection .
   ```

   Alternatively, pull the prebuilt image:

   ```bash
   docker pull sweic69/cs440-fraud-detection
   ```

3. **Run the Docker Container:**

   ```bash
   docker run -p 7474:7474 -p 7687:7687 -d --name cs440-fraud-detection cs440-fraud-detection
   ```

4. **Access Neo4j Console:**
   Open your browser and navigate to [http://localhost:7474](http://localhost:7474) to access the Neo4j console.

### Database Initialization

To initialize the database and create relationships, you have two options:

1. **Run Cypher Mutation Commands Directly:**

   - Execute the mutation commands from `./init/init.cypher` in the Neo4j console.

2. **Use the Initialization Script:**
   - Enter the running container:
     ```bash
     docker exec -it cs440-fraud-detection /bin/bash
     ```
   - Run the setup script:
     ```bash
     cd ./init
     ./setup.sh
     ```
     This will automatically execute the Cypher scripts to set up the database with the required relationships.

### Running Queries

Once the database is initialized, you can explore the data and visualize fraud patterns by running the Cypher queries located in the `./queries` folder. These queries demonstrate the relationships and potential fraud indicators in the dataset.

## Additional Notes

- **Port Mapping:** The default Neo4j ports are mapped as follows:

  - **7474:** HTTP
  - **7687:** Bolt protocol

- **Container Management:** To stop the container, use:
  ```bash
  docker stop cs440-fraud-detection
  ```
