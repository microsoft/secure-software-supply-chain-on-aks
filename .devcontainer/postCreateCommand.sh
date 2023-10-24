AKV_PLUGIN_VERSION=0.6.0
mkdir -p /home/vscode/.config/notation/plugins/azure-kv \
    && cd /home/vscode/.config/notation/plugins/azure-kv \
    && curl -Lo notation-azure-kv.tar.gz https://github.com/Azure/notation-azure-kv/releases/download/v${AKV_PLUGIN_VERSION}/notation-azure-kv_${AKV_PLUGIN_VERSION}_Linux_amd64.tar.gz \
    && tar -zxf notation-azure-kv.tar.gz notation-azure-kv \
    && rm notation-azure-kv.tar.gz