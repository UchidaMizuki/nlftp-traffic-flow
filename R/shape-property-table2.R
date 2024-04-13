
# shape-property-table2 ---------------------------------------------------

download_shape_property_table2 <- function() {
  curl::curl_download("https://nlftp.mlit.go.jp/ksj/gml/codelist/shape_property_table2.xlsx",
                      "data-raw/shape_property_table2.xlsx")
}

read_shape_property_table2 <- function(file_shape_property_table2) {
  readxl::read_xlsx(file_shape_property_table2,
                    skip = 3,
                    col_types = "text") |>
    rename_with(\(x) "シェープファイル名",
                matches("シェープファイル名")) |>
    rename(data_type_large = 大分類,
           data_type_small = 小分類,
           data_name = データ名,
           data_version = バージョン情報,
           data_year = データ年度,
           file_name = シェープファイル名,
           col_name_from = 属性コード,
           col_name_to = 属性名,
           col_name_identifier = 識別子,
           remark = 備考) |>
    fill(data_version, data_year, file_name)
}
