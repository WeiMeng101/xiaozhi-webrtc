FROM python:3.12-slim

LABEL maintainer="dairoot"

RUN apt-get update -o Acquire::Check-Valid-Until=false && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgl1 \
    libportaudio2 \
    portaudio19-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN pip install uv

COPY ./pyproject.toml ./pyproject.toml

COPY ./uv.lock ./uv.lock

RUN uv sync --index-url https://pypi.org/simple

COPY ./src ./src

COPY ./main.py ./main.py

EXPOSE 51000

ENV PORT=51000

CMD ["uv", "run", "main.py"]
