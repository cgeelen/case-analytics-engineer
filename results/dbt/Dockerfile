FROM python:3.12-alpine

RUN pip install poetry

WORKDIR /app

COPY . .

RUN poetry install --without dev

ENTRYPOINT ["poetry", "run", "python", "-m", "main"]