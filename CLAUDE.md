# 個人学術サイト構築プロジェクト（Wix → Quarto 移行）

## 施主
Masahiro Yoshida（masa）。早稲田大学政治経済学術院 准教授。労働経済学・マクロ労働、気候×労働の実証。
Rユーザー（RStudio/Positron）だがエンジニアではない。説明はノーコードユーザー向けに、簡潔に。日本語で対話。

## 目的
アカデミアの転職活動（2026年秋〜、国内公募＋海外応募）に向け、現行の Wix サイト https://www.m-yoshida.com/ を
Quarto + GitHub Pages に移行し、よりプロフェッショナルに見せる。

## 確定事項（議論済み・再検討不要）
- ジェネレータは **Quarto**（Hugo/HugoBlox・Jekyll は不採用。保守性とRワークフローとの整合で決定）
- ホスティングは **GitHub Pages**。GitHubユーザー名は `masa-yoshida-econ`（2026-10-19 に m-yoshida-econ から変更）
- リポジトリ名は `masa-yoshida-econ.github.io`
- 独自ドメイン `m-yoshida.com`（Wix購入）を継続使用。DNSのみGitHub Pagesへ向け替え（ドメイン移管はしない）
- `gh` と `quarto` は Homebrew でインストール済み、`gh auth login` 完了
- 素材は本フォルダ `website/` 内にある（CV PDF・写真・論文リスト・プロフィール文など。ファイル名は任意、中身で判断すること）

## デザイン方針
- 参考: https://yutatoyama.github.io/ （al-folio）と https://www.xinchengqiu.com/ （Wowchemy）。
  両者の「シンプルでミニマルな学術サイト」の見た目に寄せる。凝った装飾は不要
- **Quarto製と外見で分からないようにする**：
  - Bootswatch既定テーマの顔を消す。Google Fonts で独自フォント指定、`styles.css` で配色・余白・ナビバーを上書き
  - TOC非表示、`about` テンプレのレイアウトは使わずトップページは自前で組む
  - `<meta name="generator">` を除去
- 印刷を考慮し、塗りつぶし色の多用は避ける

## ページ構成
- Home：写真・名前・所属・短いbio・Interests・Education・連絡先・Google Scholar等リンク
- Research：`.bib`駆動で **Publications** と **Working Papers** を分けて自動描画。各項目にステータス（R&R先など）・PDF・コード・SSRN/IZAリンク
- Teaching
- Talks：日付降順。Recent / Upcoming を分ける
- CV：PDFへのリンク（公開ファイル名は `cv.pdf`）
- 日本語ページ（現サイトのJPN切替相当）
- 公開リンクや論文リストに漏れがないか、現行Wixサイトと照合して指摘すること

## 技術構成
- GitHub Actions で push 時に自動 render → Pages 公開
- `CNAME` ファイルに `m-yoshida.com`
- まず `https://masa-yoshida-econ.github.io` で表示確認。**DNS切替は最後**（新サイト完成まで旧Wixサイトを落とさない）
- 日常更新は「`.bib` に1エントリ追加 → push」で済む設計にする

## DNS切替手順（施主がWix管理画面で実施。Claude Codeは値を提示するのみ）
- Aレコード（@）×4: 185.199.108.153 / 185.199.109.153 / 185.199.110.153 / 185.199.111.153
- CNAME（www）: masa-yoshida-econ.github.io
- 既存のWix向けA/CNAMEは削除
- GitHub側: Settings → Pages → Custom domain = m-yoshida.com、Enforce HTTPS
- 反映後、Wixのサイトプランは解約（ドメイン契約のみ残す）

## 作業の進め方
- 完璧を狙わず、まず骨組み（Home・Research・CV）を建てて `quarto preview` で見せる。Talks/Teachingは後から追加
- 施主の確認を挟みながら進める。大きな構成変更の前は一言確認
- 迷ったら「シンプルな方」「保守が楽な方」を選ぶ

## 作業メモ（2026-10-11 追記）
- プロジェクトの実体はこのフォルダ `~/Dropbox/masa-yoshida-econ.github.io/`（2026-10-20 に旧名 m-yoshida-econ.github.io から改名）。
  素材フォルダ `~/Dropbox/website:/` はフォルダ名のコロンが Quarto（Sass）を壊すので、
  ソースはここに置く。素材（CV PDF・写真・profile.md）は従来どおり `website:` にある。
- Research は `papers.bib` → `R/render_bib.R`（base R）→ `research.qmd` で描画。
- 論文 PDF は `papers/` に移管済み（2026-10-11）。ボタン色は WASEDA RED #8E1729。
- 2026-10-13: Non-Refereed Works（2026-10-20 に Non-Technical Writing へ改名、writing.md）と Teaching ページを追加。Statement は statements/ に PDF を置くと自動でボタンが有効になる。
- 2026-10-20: DNS 切替完了。公開 URL は https://www.m-yoshida.com（GitHub の custom domain は www が主、m-yoshida.com は www へ転送、常時 HTTPS）。Wix はドメイン契約と DNS のみ使用、サイトプランは解約予定。
