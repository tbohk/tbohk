FROM python:3.13-slim-bookworm
ENV PYTHONUNBUFFERED=1 TBOHK_ENV=staging TBOHK_HOST=0.0.0.0 TBOHK_PORT=8080 TBOHK_DB=/data/tbohk.sqlite TBOHK_ACCOUNTS_DB=/data/accounts.sqlite TBOHK_ACCOUNT_DATA_DIR=/data/accounts TBOHK_ARTIFACT_ROOT=/data/artifacts
RUN apt-get update && apt-get install -y --no-install-recommends unzip ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY TBOHK_0.59.2_REALITY_PHASE3_BLITZ_FREE_STAGING_CHECKPOINT.zip /tmp/t.zip
RUN unzip -q /tmp/t.zip -d /tmp/t && cp -a /tmp/t/tbohk_phase2/. /app/ && rm -rf /tmp/t /tmp/t.zip
RUN sed -i 's/starlette==0.51.0/starlette==0.49.3/' requirements.lock && pip install --no-cache-dir -r requirements.lock
RUN useradd -u 1000 -m tbohk && mkdir -p /data/artifacts /data/accounts && chown -R 1000:1000 /app /data
EXPOSE 8080
USER 1000:1000
ENTRYPOINT ["python","-m","infra.blitz.entrypoint"]
