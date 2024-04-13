
# nlftp -------------------------------------------------------------------

download_nlftp <- function(path, exdir) {
  url <- str_c("https://nlftp.mlit.go.jp/ksj/gml/", path)
  dir_create(exdir)

  exdir <- path(exdir,
                path_file(url) |>
                  path_ext_remove())
  dir_create(exdir)

  zipfile <- file_temp()
  curl::curl_download(url, zipfile)
  zip::unzip(zipfile,
             exdir = exdir)

  dir_ls(exdir,
         recurse = TRUE)
}
