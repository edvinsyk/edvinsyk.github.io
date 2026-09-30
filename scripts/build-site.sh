#!/usr/bin/env bash
set -euo pipefail

web_root=$(pwd)
cv_source=${1:-cv-source}
cv_root=$(cd "$cv_source" && pwd)
cv_output="$web_root/_cv-output"

rm -rf "$cv_output"
(
  cd "$cv_root"
  quarto render cv-academic.qmd --to typst --output-dir "$cv_output"
  quarto render cv-academic.qmd --to html --output-dir "$cv_output"
)

python3 - "$cv_output" "$web_root" <<'PY'
from pathlib import Path
import re
import sys

cv_output = Path(sys.argv[1])
web_root = Path(sys.argv[2])
name = "cv-academic"
rendered = (cv_output / f"{name}.html").read_text()

def section_by_id(document, section_id):
    start_tag = re.search(
        rf'<section\b(?=[^>]*\bid="{re.escape(section_id)}")[^>]*>', document
    )
    if start_tag is None:
        raise ValueError(f"Missing section id {section_id!r} in rendered academic CV")
    depth = 1
    for tag in re.finditer(r'</?section\b[^>]*>', document[start_tag.end():]):
        if tag.group().startswith("</"):
            depth -= 1
            if depth == 0:
                return document[start_tag.start():start_tag.end() + tag.end()]
        else:
            depth += 1
    raise ValueError(f"Unclosed section id {section_id!r} in rendered academic CV")

start = rendered.index('<main class="content" id="quarto-document-content">')
start = rendered.index(">", start) + 1
end = rendered.index("</main>", start)
body = rendered[start:end].strip()
body = re.sub(
    r'<div class="cv-download">.*?</div>',
    f'<div class="cv-download"><p><a href="/cv-files/{name}.pdf">Download PDF</a></p></div>',
    body,
    count=1,
    flags=re.DOTALL,
)
body = re.sub(r'\b(id|data-anchor-id)="([^"]+)"', lambda match: f'{match[1]}="academic-{match[2]}"', body)
body = re.sub(r'\bhref="#([^"]+)"', r'href="#academic-\1"', body)
body = re.sub(r'\s+role="(?:list|listitem)"', "", body)
(web_root / "_cv-academic-body.html").write_text(body)

research = "\n".join(section_by_id(rendered, section_id) for section_id in ("publications", "ongoing-work"))
research = re.sub(r'\b(id|data-anchor-id)="([^"]+)"', lambda match: f'{match[1]}="research-{match[2]}"', research)
research = re.sub(r'\bhref="#([^"]+)"', r'href="#research-\1"', research)
research = re.sub(r'\s+role="(?:list|listitem)"', "", research)
(web_root / "_cv-research-body.html").write_text(research)
PY

quarto render
mkdir -p "$web_root/_site/cv-files" "$web_root/_site/cv-assets"
cp "$cv_output"/cv-academic.pdf "$web_root/_site/cv-files/"
cp "$cv_root"/assets/fonts/*.ttf "$web_root/_site/cv-assets/"
