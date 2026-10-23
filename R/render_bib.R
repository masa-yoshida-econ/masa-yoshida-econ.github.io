# Minimal BibTeX reader + HTML renderer for research.qmd (base R only).
# Custom fields are documented at the top of papers.bib.

read_bib <- function(path) {
  txt <- readLines(path, warn = FALSE, encoding = "UTF-8")
  txt <- txt[!grepl("^\\s*%", txt)]                 # drop comment lines
  txt <- paste(txt, collapse = "\n")
  starts <- gregexpr("@\\w+\\s*\\{", txt)[[1]]
  if (starts[1] == -1) return(list())
  ends <- c(starts[-1] - 1, nchar(txt))
  lapply(seq_along(starts), function(i) {
    parse_entry(substr(txt, starts[i], ends[i]))
  })
}

parse_entry <- function(s) {
  type <- sub("^@(\\w+).*", "\\1", s)
  body <- sub("^@\\w+\\s*\\{", "", s)
  key  <- trimws(sub(",.*", "", body))
  body <- sub("^[^,]*,", "", body)
  out  <- list(type = tolower(type), key = key)
  i <- 1; n <- nchar(body)
  while (i <= n) {
    rest <- substr(body, i, n)
    m <- regexpr("^\\s*,?\\s*([A-Za-z_]+)\\s*=\\s*\\{", rest, perl = TRUE)
    if (m == -1) break
    name  <- tolower(sub("^\\s*,?\\s*([A-Za-z_]+).*", "\\1", substr(rest, 1, attr(m, "match.length")), perl = TRUE))
    j <- i + attr(m, "match.length")               # position right after "{"
    depth <- 1; k <- j
    while (k <= n && depth > 0) {
      ch <- substr(body, k, k)
      if (ch == "{") depth <- depth + 1 else if (ch == "}") depth <- depth - 1
      k <- k + 1
    }
    out[[name]] <- trimws(substr(body, j, k - 2))
    i <- k
  }
  out
}

# BibTeX "Last, First and Last, First" -> "First Last"
format_authors <- function(a) {
  parts <- trimws(strsplit(a, "\\s+and\\s+")[[1]])
  vapply(parts, function(p) {
    if (grepl(",", p)) { lf <- trimws(strsplit(p, ",")[[1]]); paste(lf[2], lf[1]) } else p
  }, character(1), USE.NAMES = FALSE)
}

# "Name: URL; Name: URL" -> named character vector
parse_author_url <- function(s) {
  if (is.null(s) || s == "") return(character(0))
  items <- trimws(strsplit(s, ";")[[1]])
  urls  <- sub("^[^:]+:\\s*", "", items)
  names(urls) <- trimws(sub(":.*$", "", items))
  urls
}

# light TeX -> HTML cleanup for abstracts/titles
tex2html <- function(x) {
  x <- gsub("---", "&mdash;", x, fixed = TRUE)
  x <- gsub("--", "&ndash;", x, fixed = TRUE)
  x <- gsub("\\&", "&amp;", x, fixed = TRUE)
  x <- gsub("\\%", "%", x, fixed = TRUE)
  x <- gsub("[{}]", "", x)
  x
}

link_btn <- function(url, label) {
  if (is.null(url) || url == "") return("")
  sprintf('<a href="%s" target="_blank" rel="noopener">%s</a>', url, label)
}


# Clean BibTeX for the Cite button (standard fields only).
bib_escape <- function(x) gsub("&", "\\&", gsub("\\\\&", "&", x))
make_bibtex <- function(e) {
  is_pub <- !is.null(e$journal) && is.null(e$status)
  type <- if (is_pub) "article" else "unpublished"
  f <- list(title = e$title, author = e$author)
  if (is_pub) f$journal <- e$journal
  f$year <- e$year
  if (is_pub) { f$volume <- e$volume; f$number <- e$number; f$pages <- e$pages; f$doi <- e$doi }
  f <- Filter(Negate(is.null), f)
  if (!is.null(e$month)) f$month <- month.abb[as.integer(e$month)]
  if (!is_pub) {
    note <- c(if (!is.null(e$status)) paste(e$status, if (!is.null(e$journal)) paste("at", e$journal)),
              if (is.null(e$status)) "Working paper")
    f$note <- note[1]
  }
  if (!is.null(e$url_pdf)) f$url <- paste0("https://m-yoshida.com/", e$url_pdf)
  w <- max(nchar(names(f)))
  lines <- sprintf("  %-*s = {%s}", w, names(f), vapply(f, bib_escape, character(1)))
  paste0("@", type, "{", e$key, ",\n", paste(lines, collapse = ",\n"), "\n}")
}

month_name <- function(m) {
  if (is.null(m) || m == "") return(NULL)
  month.name[as.integer(m)]
}

render_entry <- function(e, me = "Masahiro Yoshida") {
  # --- authors: all names, coauthors linked when author_url is given ---
  authors <- format_authors(e$author)
  aurl <- parse_author_url(e$author_url)
  au_html <- vapply(authors, function(nm) {
    if (nm %in% names(aurl)) sprintf('<a href="%s" target="_blank" rel="noopener">%s</a>', aurl[[nm]], nm) else nm
  }, character(1), USE.NAMES = FALSE)
  authors_html <- sprintf('<div class="pub-authors">%s</div>', paste(au_html, collapse = ", "))

  # --- meta line: "Month Year · Status at <journal>" ---
  date <- paste(c(month_name(e$month), e$year), collapse = " ")
  journal <- if (!is.null(e$journal)) {
    vol <- if (!is.null(e$volume)) paste0(" ", e$volume, if (!is.null(e$number)) paste0("(", e$number, ")")) else ""
    pg  <- if (!is.null(e$pages)) paste0(", ", gsub("--", "&ndash;", e$pages)) else ""
    sprintf('<span class="pub-journal">%s</span>%s%s', tex2html(e$journal), vol, pg)
  } else NULL
  status  <- if (!is.null(e$status)) tex2html(e$status) else NULL
  if (!is.null(status) && !is.null(e$status_note))
    status <- paste0(status, ' <span class="pub-status-note">(', tex2html(e$status_note), ')</span>')
  venue <- if (!is.null(status) && !is.null(journal)) {
    sprintf('<span class="pub-status">%s at %s</span>', status, journal)
  } else if (!is.null(status)) {
    sprintf('<span class="pub-status">%s</span>', status)
  } else journal
  note <- if (!is.null(e$note)) sprintf('<span class="pub-status">%s</span>', tex2html(e$note)) else NULL
  meta_parts <- Filter(Negate(is.null), list(date, venue, note))
  meta_html <- sprintf('<div class="pub-meta">%s</div>', paste(meta_parts, collapse = '<span class="dot">&middot;</span>'))

  # --- buttons ---
  links <- c(
    link_btn(e$url_pdf,       "PDF"),
    link_btn(e$url_pub,       "Journal"),
    link_btn(if (!is.null(e$doi)) paste0("https://doi.org/", e$doi) else e$url_doi, "DOI"),
    link_btn(e$url_slides,    "Slides"),
    link_btn(e$url_ssrn,      "SSRN"),
    link_btn(e$url_iza,       "IZA DP"),
    link_btn(e$url_code,      "Code"),
    link_btn(e$url_data,      "Data"),
    link_btn(e$url_media,     "Website"),
    link_btn(e$url_media_pdf, "Article (PDF)")
  )
  links <- links[links != ""]
  cite_id <- paste0("cite-", e$key)
  show_cite <- !identical(tolower(if (is.null(e$cite)) "" else e$cite), "no")
  if (show_cite) links <- c(links, sprintf('<a href="#%s" class="pub-cite-btn" data-target="%s">Cite</a>', cite_id, cite_id))
  links_html <- if (length(links)) sprintf('<div class="pub-links">%s</div>', paste(links, collapse = "")) else ""
  cite_html <- if (!show_cite) "" else sprintf('<div class="pub-cite" id="%s" hidden><pre><code>%s</code></pre><button type="button" class="pub-cite-copy">Copy</button></div>',
                       cite_id, gsub("<", "&lt;", make_bibtex(e), fixed = TRUE))
  talks <- if (!is.null(e$talks)) sprintf('<div class="pub-talks">%s</div>', tex2html(e$talks)) else ""
  abs   <- if (!is.null(e$abstract)) sprintf('<details><summary>Abstract</summary><p>%s</p></details>', tex2html(e$abstract)) else ""

  sprintf('<div class="pub" id="%s">\n<div class="pub-title">%s</div>\n%s\n%s\n%s%s%s%s\n</div>\n',
          e$key, tex2html(e$title), authors_html, meta_html, links_html, cite_html, talks, abs)
}

render_section <- function(entries, section) {
  es <- Filter(function(e) identical(e$section, section), entries)
  if (!length(es)) return(invisible(NULL))
  yrs <- vapply(es, function(e) as.integer(if (is.null(e$year)) 0 else e$year), integer(1))
  es <- es[order(-yrs, seq_along(es))]
  cat(paste(vapply(es, render_entry, character(1)), collapse = "\n"))
}
