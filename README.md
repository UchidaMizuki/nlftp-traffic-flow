# 国土数値情報 交通流動量


国土数値情報 交通流動量データを整形するためのRコードです．

``` r
library(targets)
library(tidyverse)
library(sf)
```

## 利用上の注意点

- データ利用にあたっては事前に[国土数値情報ダウンロードサービスコンテンツ利用規約](https://nlftp.mlit.go.jp/ksj/other/agreement.html)を確認してください．

## 利用方法

1.  本リポジトリをクローンしてください．
2.  RStudioで本プロジェクトを開いてください．
3.  `targets::tar_make()`を実行してください．

## データ一覧

### パーソントリップ発生・集中量

- 出典: 国土数値情報 パーソントリップ発生・集中量データ
  (<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-S05-a-2013.html>)

- 発生・集中量のうち**目的別の合計値**については，国土数値情報
  パーソントリップ発生・集中量データ
  (<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-S05-a-2013.html>)
  を加工して作成

#### 発生・集中量: `person_trip_occurred_concentrated`

``` r
tar_load(person_trip_occurred_concentrated)
glimpse(person_trip_occurred_concentrated)
```

    Rows: 104,892
    Columns: 8
    $ urban_area_name             <fct> syuto, syuto, syuto, syuto, syuto, syuto, …
    $ data_creation_year          <int> 2010, 2010, 2010, 2010, 2010, 2010, 2010, …
    $ zone_code                   <chr> "0010", "0010", "0010", "0010", "0010", "0…
    $ transportation              <fct> 鉄道, 鉄道, 鉄道, 鉄道, 鉄道, 鉄道, バス, …
    $ purpose                     <fct> 出勤, 登校, 自由, 業務, 帰宅, 合計, 出勤, …
    $ traffic_volume_occurred     <int> 46, 0, 46594, 46037, 244456, 337133, 0, 0,…
    $ traffic_volume_concentrated <int> 238126, 690, 51541, 60934, 167, 351458, 26…
    $ geometry                    <MULTIPOLYGON [°]> MULTIPOLYGON (((139.7526 35..…

### パーソントリップOD量

- 出典: 国土数値情報 交通流動量 パーソントリップＯＤ量データ
  (<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-S05-b-2013.html>)
- OD量のうち**目的別の合計値**，および**代表地点間距離**については，国土数値情報
  交通流動量 パーソントリップＯＤ量データ
  (<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-S05-b-2013.html>)
  を加工して作成

#### OD量: `person_trip_od_amount`

``` r
tar_load(person_trip_od_amount)
glimpse(person_trip_od_amount)
```

    Rows: 212
    Columns: 7
    $ urban_area_name    <fct> syuto, syuto, syuto, syuto, syuto, syuto, syuto, sy…
    $ data_creation_year <int> 2010, 2010, 2010, 2010, 2010, 2010, 2010, 2010, 201…
    $ urban_area_code    <chr> "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "…
    $ survey_year        <int> 2008, 2008, 2008, 2008, 2008, 2008, 2008, 2008, 200…
    $ transportation     <fct> 鉄道, 鉄道, 鉄道, 鉄道, 鉄道, 鉄道, バス, バス, バ…
    $ purpose            <fct> 出勤, 登校, 自由, 業務, 帰宅, 合計, 出勤, 登校, 自…
    $ od_amount          <list> <<table[600 x 600]>>, <<table[600 x 600]>>, <<tabl…

#### 代表地点間距離: `distance_person_trip_od_amount`

``` r
tar_load(distance_person_trip_od_amount)
glimpse(distance_person_trip_od_amount)
```

    Rows: 5
    Columns: 3
    $ urban_area_name    <fct> syuto, chubu, kinki, kinki, chubu
    $ data_creation_year <int> 2010, 2010, 2010, 2012, 2013
    $ distance           <list> <<units[600 x 600]>>, <<units[445 x 445]>>, <<units…
