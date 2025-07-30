# Dockerfile Practice: Automating Nginx Customization

* * *

## Steps

1.  **Create a Dockerfile**
    
    - In a **new empty folder**, create a file named `Dockerfile`.
2.  **Set Up Your IDE**
    
    - (Optional but recommended) Install **Docker extensions** for better syntax support (e.g., Docker by Microsoft in VSCode).

* * *

## Dockerfile Contents

```Dockerfile
FROM nginx:1.27.0          # Base image
RUN apt-get update         # Update package list
RUN apt-get install -y vim # Install vim with automatic "yes" flag
```

* * *

## Build the Docker Image

- Use Docker CLI in the same folder:

```bash
docker build -t webserver_image .
```

- Note:
    
    - `-t webserver_image`: Assigns a **tag/name** to the image.
        
    - `.` : Specifies the **current directory** as context.
        

* * *

## Run the Container

```bash
docker run -d webserver_image
```

- `-d`: Detached mode (runs in background).
    
- Verify with:
    

```bash
docker ps
```

- Access container and verify `vim`:

```bash
docker exec -it <container_id> bash
vim   # should be available inside the container
```

* * *

## Clean Up and Retag (Optional)

- Stop & remove container:

```bash
docker stop <container_id>
docker rm <container_id>
```

- Remove image:

```bash
docker rmi webserver_image
```

- Rebuild with better name:

```bash
docker build -t webserver_image .
```

* * *

## Key Concepts Highlighted

- 🟢 **Automation**: Dockerfile simplifies repetitive tasks.
    
- 🟢 **Reproducibility**: Anyone can build the same container.
    
- 🟢 **Layer Caching**: Docker **reuses layers** when instructions don’t change, speeding up rebuilds.
    
- 🟢 **Image Tagging**: Use **descriptive tags** to avoid confusion with container names.
    

* * *

