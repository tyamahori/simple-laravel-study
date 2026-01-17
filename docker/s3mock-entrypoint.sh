#!/bin/bash
set -euxo pipefail

echo "Starting MinIO server..."

# バックグラウンドでMinIOを起動
# --address: APIポート
# --console-address: 管理画面ポート
minio server /data --console-address ":80" &
MINIO_PID=$!

# MinIOがAPIに応答するまで待機（ヘルスチェック）
echo "Waiting for MinIO to become healthy..."
until curl -s -f http://localhost:9000/minio/health/live > /dev/null; do
    sleep 1
done

echo "MinIO is running. Configuring bucket..."

# mcの設定（エイリアス作成）
mc alias set local http://localhost:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"

# バケット作成（存在しない場合のみ）
if mc ls local/"$BUCKET_NAME" > /dev/null 2>&1; then
    echo "Bucket '$BUCKET_NAME' already exists."
else
    mc mb local/"$BUCKET_NAME"
    echo "Bucket '$BUCKET_NAME' created successfully."
fi

# バケットポリシーをpublicにする
mc anonymous set public local/"$BUCKET_NAME"

echo "Setup complete. MinIO is ready."

# フォアグラウンドプロセスとして待機
wait $MINIO_PID
