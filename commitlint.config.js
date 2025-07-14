module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // 新機能
        'fix',      // バグ修正
        'docs',     // ドキュメントのみの変更
        'style',    // コードの意味に影響を与えない変更（空白、フォーマット、セミコロンの欠落など）
        'refactor', // バグ修正でも機能追加でもないコード変更
        'perf',     // パフォーマンスを向上させるコード変更
        'test',     // 不足しているテストの追加や既存のテストの修正
        'chore',    // ビルドプロセスやドキュメント生成などの補助ツールやライブラリの変更
        'revert',   // 以前のコミットを元に戻す
        'ci',       // CI設定ファイルとスクリプトの変更
        'build',    // ビルドシステムや外部依存関係に影響する変更
      ],
    ],
    'type-case': [2, 'always', 'lower-case'],
    'subject-case': [0],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 72],
    'body-max-line-length': [0],
    'footer-max-line-length': [0],
  },
  parserPreset: {
    parserOpts: {
      headerPattern: /^(\w+)(?:\(([^)]+)\))?:\s(.+)$/,
      headerCorrespondence: ['type', 'scope', 'subject'],
    },
  },
  helpUrl:
    'https://github.com/conventional-changelog/commitlint/#what-is-commitlint',
};

/*
コミットメッセージの例:

feat: AI音声配車機能を追加
feat(api): 新しいエンドポイントを追加
fix: ドライバーマッチングのバグを修正
docs: READMEを更新
style: コードフォーマットを修正
refactor: 認証ロジックをリファクタリング
perf: データベースクエリを最適化
test: ユニットテストを追加
chore: 依存関係を更新
ci: GitHub Actionsワークフローを追加
*/