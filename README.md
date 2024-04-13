# 国土数値情報 交通流動量


国土数値情報 交通流動量データを整形するためのRコードです．

## 利用上の注意点

- データ利用にあたっては事前に[国土数値情報ダウンロードサービスコンテンツ利用規約](https://nlftp.mlit.go.jp/ksj/other/agreement.html)を確認してください．

## 利用方法

1.  本リポジトリをクローンしてください．
2.  RStudioで本リポジトリを開いてください．
3.  `targets::tar_make()`を実行してください．

## データ一覧

### パーソントリップOD量

- 出典: 国土数値情報 交通流動量 パーソントリップＯＤ量データ
  (https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-S05-b-2013.html)
- OD量のうち**目的別の合計値**，および**代表地点間距離**については，国土数値情報
  交通流動量 パーソントリップＯＤ量データ (
  https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-S05-b-2013.html)
  を加工して作成

#### OD量: `person_trip_od_amount`

``` r
targets::tar_read(person_trip_od_amount)
```

    # A tibble: 212 × 5
       urban_area_name data_creation_year transportation purpose od_amount          
       <fct>                        <int> <fct>          <fct>   <list>             
     1 syuto                         2010 鉄道           出勤    <table [600 × 600]>
     2 syuto                         2010 鉄道           登校    <table [600 × 600]>
     3 syuto                         2010 鉄道           自由    <table [600 × 600]>
     4 syuto                         2010 鉄道           業務    <table [600 × 600]>
     5 syuto                         2010 鉄道           帰宅    <table [600 × 600]>
     6 syuto                         2010 鉄道           合計    <table [600 × 600]>
     7 syuto                         2010 バス           出勤    <table [600 × 600]>
     8 syuto                         2010 バス           登校    <table [600 × 600]>
     9 syuto                         2010 バス           自由    <table [600 × 600]>
    10 syuto                         2010 バス           業務    <table [600 × 600]>
    # ℹ 202 more rows

#### 代表地点間距離: `distance_person_trip_od_amount`

``` r
targets::tar_read(distance_person_trip_od_amount)
```

    # A tibble: 5 × 3
      urban_area_name data_creation_year distance           
      <fct>                        <int> <list>             
    1 syuto                         2010 <table [600 × 600]>
    2 chubu                         2010 <table [445 × 445]>
    3 kinki                         2010 <table [302 × 302]>
    4 kinki                         2012 <table [432 × 432]>
    5 chubu                         2013 <table [594 × 594]>
