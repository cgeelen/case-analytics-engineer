FROM ubuntu:latest
# Install SQLite and PG loader
RUN apt update
RUN apt install sqlite3 pgloader -y
# Create a directory to store the database
WORKDIR /db

# Expose the port if needed
EXPOSE 1433

# Put CMD in place, we are going to override this in the docker-compose.yaml
CMD ["pgloader",  "sqlite:///db/data.sqlite", "pgsql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres/${POSTGRES_DB}"]