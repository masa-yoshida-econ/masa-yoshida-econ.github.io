# m-yoshida.com (Quarto)

個人サイトのソース。`quarto preview` でローカル確認、`main` に push すると
GitHub Actions が render して GitHub Pages に公開する（ワークフローは未検証）。

## ファイル構成

- `_quarto.yml` : サイト設定（ナビ・テーマ・フォント）
- `styles.scss` : 配色・余白・ナビバーの上書き
- `index.qmd` : Home（`talks.md` を include して Recent Talks を表示）
- `talks.md` : Recent Talks の正本。1 行 1 件、新しい順に書く
- `research.qmd` : Research（`papers.bib` を読んで自動描画）
- `writing.qmd`, `writing.md` : Non-Technical Writing（本と一般向け記事。`writing.md` が正本）
- `teaching.qmd` : Teaching（授業歴は qmd に直接書く）
- `statements/` : Research / Teaching Statement の PDF 置き場
- `R/statements.R` : Statement ボタン（PDF があればリンク、なければ coming soon）
- `cv.pdf` : CV（ナビの CV から直接開く。同じ名前で上書き更新）
- `papers.bib` : 論文リストの正本
- `taglines.md` : 各論文の一言紹介（Research ページで状況の下に表示。見出しはサイトのタイトルと完全一致させる）
- `papers/` : 論文・スライド・記事の PDF（Wix から移管済み）
- `R/render_bib.R` : bib を読んで HTML にする関数（base R のみ）
- `scripts/strip_generator.sh` : render 後に generator メタタグを削除
- `legacy_urls.tsv`, `scripts/copy_legacy.sh` : 旧 Wix の PDF リンクを生かす。
  対応表の各行のファイルを `_files/ugd/` に旧名でコピーする（常に最新版が開く）
- `img/photo.jpg` : 写真（900px に縮小済み）

## 日常更新

- 発表を追加: `talks.md` の先頭に 1 行足す → push。
- 本・一般向け記事を追加: `writing.md` の該当セクション先頭に足す → push。
- Statement を公開: 次の名前で `statements/` に PDF を置く → push。
  `Yoshida_ResearchStatement_EN.pdf` / `Yoshida_ResearchStatement_JA.pdf` /
  `Yoshida_TeachingStatement_EN.pdf` / `Yoshida_TeachingStatement_JA.pdf`

1. `papers.bib` にエントリを 1 つ追加（`section` は必須。
   `wp_revision` / `wp` / `pub` / `wip` のどれか）。
2. `quarto preview` で確認。
3. `git add -A && git commit -m "..." && git push`。

## 注意

- Wix で PDF を上げ直すと URL が変わる。DNS 切替までに Wix で上げた PDF の URL は
  `legacy_urls.tsv` に 1 行足す。
- `papers/` のファイル名は書類に載るので、DNS 切替後は変えない。

- 素材（CV・写真・プロフィール・指示書）は `~/Dropbox/0_context_ai/website/` にある。
  旧素材フォルダ `~/Dropbox/website:` はフォルダ名のコロンが Quarto を壊したため廃止。
- 論文 PDF は `papers/` にある。ファイル名は `Yoshida_短い名前.pdf`（共著は
  `Yoshida_共著者_短い名前.pdf`、スライドは末尾 `_slides`）。
  新しい版は同じファイル名で上書きすれば bib を触らずに済む。
- `CNAME` は DNS 切替の直前に追加する（先に置くと github.io での確認が
  リダイレクトされてしまう）。
