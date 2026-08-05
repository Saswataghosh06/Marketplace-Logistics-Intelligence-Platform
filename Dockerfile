FROM python:3.9-slim

WORKDIR /app


COPY scripts/ /app/scripts/


CMD ["python", "--version"]