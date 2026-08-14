FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DBT_PROFILES_DIR=/usr/app/dbt

RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/app/dbt

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN useradd --create-home --uid 1000 dbtuser \
 && chown -R dbtuser:dbtuser /usr/app
USER dbtuser

COPY --chown=dbtuser:dbtuser . .

ENTRYPOINT ["dbt"]
CMD ["--version"]
