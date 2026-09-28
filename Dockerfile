FROM python:3.13-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TBOHK_ENV=staging \
    TBOHK_HOST=0.0.0.0 \
    TBOHK_PORT=8080 \
    TBOHK_DB=/data/tbohk.sqlite \
    TBOHK_ACCOUNTS_DB=/data/accounts.sqlite \
    TBOHK_ACCOUNT_DATA_DIR=/data/accounts \
    TBOHK_ARTIFACT_ROOT=/data/artifacts

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY TBOHK_0.59.2_REALITY_PHASE3_BLITZ_FREE_STAGING_CHECKPOINT.zip /tmp/tbohk.zip

RUN unzip -q /tmp/tbohk.zip -d /tmp/tbohk \
    && cp -a /tmp/tbohk/tbohk_phase2/. /app/ \
    && rm -rf /tmp/tbohk /tmp/tbohk.zip

RUN pip install --no-cache-dir -r requirements.lock \
    && python -m compileall -q tbohk run_production.py scripts_worker.py scripts_staging_smoke.py

RUN useradd --uid 1000 --create-home --shell /usr/sbin/nologin tbohk \
    && mkdir -p /data/artifacts /data/accounts \
    && chown -R 1000:1000 /app /data

EXPOSE 8080

USER 1000:1000

ENTRYPOINT ["python", "infra/blitz/entrypoint.py"]
