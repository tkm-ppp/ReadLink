
#!/bin/bash

# 今日の日付を取得（YYYY-MM-DD形式）
DATE=$(date +%Y-%m-%d)

# ブランチ名を設定
BRANCH_NAME="$DATE"

# 新しいブランチを作成し、切り替え
git checkout -b $BRANCH_NAME

# 変更をステージング
git add .

# コミットメッセージを設定
COMMIT_MESSAGE="Add learning records for $DATE"

# 変更をコミット
git commit -m $BRANCH_NAME

# リモートリポジトリにプッシュ
git push origin $BRANCH_NAME

# 成功メッセージを表示
echo "ブランチ '$BRANCH_NAME' を作成し、変更をコミットしてプッシュしました。"
