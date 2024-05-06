
# person-trip-od-amount ---------------------------------------------------

get_shape_property_table2_person_trip_od_amount <- function(shape_property_table2) {
  shape_property_table2 |>
    filter(str_detect(data_name, "OD量")) |>
    select(file_name, col_name_to, col_name_from) |>
    mutate(across(file_name,
                  \(x) str_split(x, "\\s+"))) |>
    unnest(file_name) |>

    # FIXME?: S05-b-10_CHUBUとS05-b-10_KINKIのデータを追加
    # => データの列数がS05-b-10_SYUTOと同等であるためSYUTOのデータを複製
    mutate(
      file_name = file_name |>
        map(\(file_name) {
          if (str_detect(file_name, "S05-b-10_SYUTO-\\d+-g_PersonTripODAmount\\.shp")) {
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

read_person_trip_od_amount <- function(file_person_trip_od_amount,
                                       shape_property_table2_person_trip_od_amount,
                                       crs) {
  file_person_trip_od_amount |>
    keep(\(x) path_ext(x) == "shp") |>
    map(\(file) {
      shape_property_table2_person_trip_od_amount <- shape_property_table2_person_trip_od_amount |>
        filter(file_name == path_file(file))

      read_sf(file,
              crs = crs) |>
        rename_with(\(x) shape_property_table2_person_trip_od_amount$col_name_to,
                    shape_property_table2_person_trip_od_amount$col_name_from) |>
        rename(urban_area_code = 都市圏,
               survey_year = 調査年度,
               orig_zone_code = 発生集中,
               dest_zone_code = ゾーンコード) |>
        mutate(across(survey_year,
                      as.integer)) |>
        rename_with(\(x) "合計-合計トリップ数",
                    any_of("全トリップ数")) |>
        pivot_longer(!c(urban_area_code, survey_year, orig_zone_code, dest_zone_code, geometry),
                     names_to = c("transportation", "purpose"),
                     names_sep = "-",
                     names_transform = list(transportation = as_factor,
                                            purpose = \(x) x |>
                                              str_remove("トリップ数$") |>
                                              as_factor()),
                     values_to = "od_amount",
                     values_transform = list(od_amount = as.integer))
    }) |>
    bind_rows() |>
    relocate(!geometry)
}

get_point_person_trip_od_amount <- function(data_person_trip_od_amount) {
  data_person_trip_od_amount |>
    select(urban_area_name, data_creation_year, urban_area_code, survey_year, orig_zone_code, dest_zone_code) |>
    filter(orig_zone_code == dest_zone_code) |>
    select(!dest_zone_code) |>
    rename(zone_code = orig_zone_code) |>
    slice_head(n = 1,
               by = c(urban_area_name, data_creation_year, urban_area_code, survey_year, zone_code)) |>
    # FIXME?: 同一地点間であってもジオメトリにややズレがあり終点側が代表点となっているようである
    mutate(across(geometry,
                  lwgeom::st_endpoint))
}

get_person_trip_od_amount <- function(data_person_trip_od_amount, point_person_trip_od_amount) {
  point <- point_person_trip_od_amount |>
    nest(.by = c(urban_area_name, data_creation_year, urban_area_code, survey_year),
         .key = "point")

  person_trip_od_amount <- data_person_trip_od_amount |>
    st_drop_geometry() |>
    select(urban_area_name, data_creation_year, urban_area_code, survey_year, orig_zone_code, dest_zone_code, transportation, purpose, od_amount) |>
    nest(.by = c(urban_area_name, data_creation_year, urban_area_code, survey_year, transportation, purpose)) |>
    left_join(point,
              by = join_by(urban_area_name, data_creation_year, urban_area_code, survey_year)) |>
    mutate(
      od_amount = list(data, point) |>
        pmap(\(data, point) {
          od_amount <- xtabs(od_amount ~ orig_zone_code + dest_zone_code,
                             data = data)
          od_amount[point$zone_code, point$zone_code]
        }),
      .keep = "unused"
    )

  # 目的別の合計トリップ数を追加
  person_trip_od_amount_by_purpose <- person_trip_od_amount |>
    filter(transportation != "合計",
           purpose != "合計") |>
    summarise(across(od_amount,
                     \(x) x |>
                       reduce(`+`,
                              .init = 0) |>
                       list()),
              .by = c(urban_area_name, data_creation_year, urban_area_code, survey_year, purpose)) |>
    add_column(transportation = as_factor("合計"),
               .before = "purpose")

  bind_rows(person_trip_od_amount,
            person_trip_od_amount_by_purpose) |>
    arrange(urban_area_name, data_creation_year, urban_area_code, survey_year, transportation, purpose)
}

get_distance_person_trip_od_amount <- function(point_person_trip_od_amount) {
  point_person_trip_od_amount |>
    nest(.by = c(urban_area_name, data_creation_year, urban_area_code, survey_year)) |>
    mutate(
      distance = data |>
        map(\(data) {
          distance <- st_distance(data)
          dimnames(distance) <- list(orig_zone_code = data$zone_code,
                                     dest_zone_code = data$zone_code)
          distance
        }),
      .keep = "unused"
    )
}
