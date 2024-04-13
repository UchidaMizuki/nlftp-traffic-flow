library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("tidyverse", "fs", "sf"),
  format = "qs"
)

fs::dir_create(c("R", "data-raw"))
tar_source()

# shape-property-table2 ---------------------------------------------------
target_shape_property_table2 <- rlang::list2(
  tar_target(
    file_shape_property_table2,
    download_shape_property_table2(),
    format = "file"
  ),
  tar_target(
    shape_property_table2,
    read_shape_property_table2(file_shape_property_table2 = file_shape_property_table2)
  ),
)

# person-trip-od-amount ---------------------------------------------------
target_person_trip_od_amount_mapped <- tar_map(
  tibble::tribble(
    ~urban_area_name, ~data_creation_year, ~url,
    "syuto", 2010, stringr::str_c(url_nlftp, "data/S05-b/S05-b-10/S05-b-10_SYUTO_GML.zip"),
    "chubu", 2010, stringr::str_c(url_nlftp, "data/S05-b/S05-b-10/S05-b-10_CHUBU_GML.zip"),
    "kinki", 2010, stringr::str_c(url_nlftp, "data/S05-b/S05-b-10/S05-b-10_KINKI_GML.zip"),
    "kinki", 2012, stringr::str_c(url_nlftp, "data/S05-b/S05-b-12/S05-b-12_KINKI_GML.zip"),
    "chubu", 2013, stringr::str_c(url_nlftp, "data/S05-b/S05-b-13/S05-b-13_CHUBU-g.zip"),
  ),
  tar_target(
    file_person_trip_od_amount,
    download_person_trip_od_amount(url = url),
    format = "file"
  ),
  tar_target(
    data_person_trip_od_amount,
    read_person_trip_od_amount(file_person_trip_od_amount = file_person_trip_od_amount,
                               shape_property_table2_person_trip_od_amount = shape_property_table2_person_trip_od_amount,
                               crs = JGD2000)
  ),
  names = c(urban_area_name, data_creation_year)
)

target_person_trip_od_amount_combined <- tar_combine(
  data_person_trip_od_amount,
  target_person_trip_od_amount_mapped[["data_person_trip_od_amount"]],
  command = dplyr::bind_rows(!!!.x,
                             .id = "urban_area_name_data_creation_year") |>
    tidyr::separate_wider_regex(urban_area_name_data_creation_year,
                                c("data_person_trip_od_amount_",
                                  urban_area_name = "[^_]+",
                                  "_",
                                  data_creation_year = "\\d+")) |>
    dplyr::mutate(across(urban_area_name, as_factor),
                  across(data_creation_year, as.integer)) |>
    st_as_sf()
)

target_person_trip_od_amount <- rlang::list2(
  tar_target(
    shape_property_table2_person_trip_od_amount,
    get_shape_property_table2_person_trip_od_amount(shape_property_table2 = shape_property_table2),
  ),
  target_person_trip_od_amount_mapped,
  target_person_trip_od_amount_combined,
  tar_target(
    point_person_trip_od_amount,
    get_point_person_trip_od_amount(data_person_trip_od_amount = data_person_trip_od_amount)
  ),
  tar_target(
    person_trip_od_amount,
    get_person_trip_od_amount(data_person_trip_od_amount = data_person_trip_od_amount,
                              point_person_trip_od_amount = point_person_trip_od_amount)
  ),
  tar_target(
    distance_person_trip_od_amount,
    get_distance_person_trip_od_amount(point_person_trip_od_amount = point_person_trip_od_amount)
  )
)

# target ------------------------------------------------------------------
rlang::list2(
  target_shape_property_table2,
  target_person_trip_od_amount,
  tar_quarto(
    readme,
    "README.qmd"
  )
)
