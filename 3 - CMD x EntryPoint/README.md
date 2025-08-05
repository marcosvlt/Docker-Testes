# Index

- [CMD vs ENTRYPOINT in Docker](#cmd-vs-entrypoint-in-docker)
    - [Key Differences](#key-differences)
    - [Code Examples](#code-examples)
        - [1. CMD Example](#1-cmd-example)
        - [2. ENTRYPOINT Example](#2-entrypoint-example)
        - [3. Combining ENTRYPOINT + CMD](#3-combining-entrypoint--cmd)
    - [Summary](#summary)

# CMD vs ENTRYPOINT in Docker

## **Key Differences**

| Feature | CMD | ENTRYPOINT |
| --- | --- | --- |
| Purpose | Provides default command/arguments | Defines the executable to run |
| Overridden by Docker Run? | ✅ Yes (replaced by arguments in `docker run`) | 🚫 No (arguments are appended, not replaced) |
| Common Use | Default parameters or fallback command | Main command or application always run |
| Override Method | Just add arguments at end of `docker run` | Use `--entrypoint` flag to override |

* * *

# Code Examples

## 1\. **CMD Example**

```Dockerfile
# Dockerfile.cmd
FROM alpine:3.20
CMD ["echo", "Hello from CMD"]
```

Run:

```bash
docker build -t cmd-example -f Dockerfile.cmd .
docker run --rm cmd-example  # Outputs: Hello from CMD

# Override CMD
docker run --rm cmd-example echo "Overridden CMD"  # Outputs: Overridden CMD
```

* * *

## 2\. **ENTRYPOINT Example**

```Dockerfile
# Dockerfile.entrypoint
FROM alpine:3.20
ENTRYPOINT ["echo", "Hello from ENTRYPOINT"]
```

Run:

```bash
docker build -t entrypoint-example -f Dockerfile.entrypoint .
docker run entrypoint-example  # Outputs: Hello from ENTRYPOINT

# Append arguments (not override)
docker run entrypoint-example "and more"  # Outputs: Hello from ENTRYPOINT and more

# Override ENTRYPOINT completely
docker run --entrypoint echo entrypoint-example "Override"  # Outputs: Override
```

* * *

## 3\. **Combining ENTRYPOINT + CMD**

```Dockerfile
# Dockerfile.cmd_entrypoint
FROM alpine:3.20
ENTRYPOINT ["echo"]
CMD ["Default message"]
```

Run:

```bash
docker build -t combined-example .
docker run --rm combined-example  # Outputs: Default message

# Override CMD only (ENTRYPOINT still "echo")
docker run combined-example "Custom message"  # Outputs: Custom message
```

* * *

# Summary

- **CMD**: Easy to override; good for default arguments or fallback behavior.
    
- **ENTRYPOINT**: Harder to override; ideal for always-running specific commands or apps.
    
- **Together**: ENTRYPOINT sets the command; CMD sets default arguments (which can be overridden). Docker combines both when running the container.