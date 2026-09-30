
Academic homepage and content for [webpage](https://edvinsyk.github.io).

Fonts and themes largely borrowed from [Andrew Heiss](https://github.com/andrewheiss/ath-quarto).

## CV tab

The CV source of truth is the private `edvinsyk/cv-academic` repository. The
`CV` navbar link opens the academic CV inside this Quarto site, with the site's
navbar and theme around the CV content. The webpage build checks out the
private CV repository, renders the academic CV to HTML and PDF, and embeds its
rendered content in the site. The PDF is published under `cv-files/`; no CV
source files or standalone CV HTML pages are published. The CV repository
continues to build the regular CV, but it is not included on this site page.
The Research page takes its Publications and Ongoing Work sections from the
same rendered academic CV, so those records are maintained only in the CV
repository.

### Repository setup

- In this repository, add the Actions secret `CV_REPOSITORY_TOKEN` with
  **Contents: read** access to the private `edvinsyk/cv-academic` repository.
- In the CV repository, set the Actions variable `WEBSITE_REPOSITORY` to
  `edvinsyk/edvinsyk.github.io` and add `WEBSITE_REBUILD_TOKEN` with
  **Contents: read and write** access to this repository. The CV build uses
  that token to send the `cv_updated` repository-dispatch event.
- In this repository's Settings → Pages, select **GitHub Actions** as the
  build and deployment source.

The site rebuilds after CV updates and after changes pushed to this website's
`main` branch. To build locally, make the private CV repository available in a
directory named `cv-source`, then run `scripts/build-site.sh cv-source`.
