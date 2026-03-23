FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl git jq cron ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# Node.js (Claude CLI依存)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Claude CLI (npm経由)
RUN npm install -g @anthropic-ai/claude-code

# GitHub CLI
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# git設定
RUN git config --global user.name "harness-harness-patrol" \
    && git config --global user.email "patrol@harness-harness.local"

WORKDIR /workspace

# パトロールスクリプトをコピー
COPY patrol-runner.sh /patrol/patrol-runner.sh
COPY patrol-prompt.md /patrol/patrol-prompt.md
COPY crontab /etc/cron.d/patrol

RUN chmod +x /patrol/patrol-runner.sh \
    && chmod 0644 /etc/cron.d/patrol \
    && crontab /etc/cron.d/patrol \
    && mkdir -p /patrol-logs /patrol-cache/pages \
    && chmod 777 /patrol-cache /patrol-cache/pages

CMD ["cron", "-f"]
