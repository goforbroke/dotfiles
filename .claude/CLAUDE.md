## 言語設定

- すべての回答・説明・提案は日本語で行う

## コード規約

- GitHubへのコミットは [Conventional commits](https://www.conventionalcommits.org/ja/v1.0.0/) に従う

## Gitコミットルール

- **コミットは利用者が差分確認のうえ実施**する想定（エージェントは原則 `git commit` / `git push` しない）。

## Brew パッケージ管理

### 禁止事項
- `brew install` / `brew uninstall` を直接実行しない
- 必ず Brewfile を経由する

### パッケージ追加時
1. `Brewfile` の該当セクションに追記する（各セクション内でアルファベット順）
2. `brew bundle --file=~/Library/CloudStorage/Dropbox/Brewfile` を実行してインストール

## Skills

- japanese-tech-writing: 日本語技術文書・書籍原稿の文章規範。
  日本語で技術記事、章、解説文を書く・推敲するときに使用する。
  SKILL.md: ~/.claude/skills/japanese-tech-writing/SKILL.md
