
# person-trip-occurred-concentrated ---------------------------------------

get_shape_property_table2_person_trip_occurred_concentrated <- function(shape_property_table2) {
  shape_property_table2 |>
    filter(str_detect(data_name, "発生・集中量")) |>
    select(file_name, col_name_to, col_name_from) |>
    mutate(across(file_name,
                  \(x) str_split(x, "\\s+"))) |>
    unnest(file_name) |>

    # FIXME?: S05-a-10_CHUBUとS05-a-10_KINKIのデータを追加
    # => データの列数がS05-a-10_SYUTOと同等であるためSYUTOのデータを複製
    mutate(
      file_name = file_name |>
        map(\(file_name) {
          if (str_detect(file_name, "S05-a-10_SYUTO-g_Occurred_ConcentratedTrafficVolumeOfPersonTrip\\.shp")) {
            file_name |>
              str_replace("SYUTO",
                          c("SYUTO", "CHUBU", "KINKI"))
          } else {
            file_name
          }
        })
    ) |>
    unnest(file_name)
}

read_person_trip_occurred_concentrated <- function(file_person_trip_occurred_concentrated,
                                                   shape_property_table2_person_trip_occurred_concentrated,
                                                   crs) {
  file_person_trip_occurred_concentrated |>
    keep(\(x) path_ext(x) == "shp") |>
    map(\(file) {
      shape_property_table2_person_trip_occurred_concentrated <- shape_property_table2_person_trip_occurred_concentrated |>
        filter(file_name == path_file(file))

      read_sf(file,
              crs = crs) |>
        rename_with(\(x) shape_property_table2_person_trip_occurred_concentrated$col_name_to,
                    shape_property_table2_person_trip_occurred_concentrated$col_name_from) |>
        rename(urban_area_code = 都市圏,
               survey_year = 調査年度,
               occurred_concentrated_type = 発生集中,
               zone_code = ゾーンコード) |>
        mutate(across(survey_year,
                      as.integer)) |>
        rename_with(\(x) "合計-合計トリップ数",
                    any_of("全トリップ数")) |>
        pivot_longer(!c(urban_area_code, survey_year, occurred_concentrated_type, zone_code, geometry),
                     names_to = c("transportation", "purpose"),
                     names_sep = "-",
                     names_transform = list(transportation = as_factor,
                                            purpose = \(x) x |>
                                              str_remove("トリップ数$") |>
                                              as_factor()),
                     values_to = "traffic_volume",
                     values_transform = list(traffic_volume = as.integer))
    }) |>
    bind_rows() |>
    relocate(!geometry) |>
    mutate(across(occurred_concentrated_type,
                  \(x) case_match(x,
                                  "1" ~ "occurred",
                                  "2" ~ "concentrated") |>
                    as_factor())) |>
    pivot_wider(names_from = occurred_concentrated_type,
                values_from = traffic_volume,
                names_prefix = "traffic_volume_") |>
    relocate(!geometry)
}

get_person_trip_occurred_concentrated <- function(data_person_trip_occurred_concentrated) {
  person_trip_occurred_concentrated <- data_person_trip_occurred_concentrated |>
    select(urban_area_name, data_creation_year, zone_code, transportation, purpose, traffic_volume_occurred, traffic_volume_concentrated)

  # 目的別の合計トリップ数を追加
  person_trip_occurred_concentrated_py_purpose <- person_trip_occurred_concentrated |>
    filter(transportation != "合計",
           purpose != "合計") |>
    summarise(across(c(traffic_volume_occurred, traffic_volume_concentrated),
                     sum),
              across(geometry, first),
              .by = c(urban_area_name, data_creation_year, zone_code, purpose)) |>
    add_column(transportation = as_factor("合計"),
               .before = "purpose")

  bind_rows(person_trip_occurred_concentrated,
            person_trip_occurred_concentrated_py_purpose) |>
    arrange(urban_area_name, data_creation_year, zone_code, transportation, purpose)
}
