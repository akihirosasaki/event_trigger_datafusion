# 目的
DataFusionとBigTableの技術調査

# 背景
アンケートデータなどの蓄積・分析をするデータパイプラインのニーズが出てきた

# 業務要件
①週次で発生するアンケートデータを分析基盤に蓄積して分析する
②アンケートデータは定常質問と非定常質問から成り、スキーマレスである
③アンケートは週次でクラウド環境に手動でアップロードする
④ユーザーはBigQuery上で分析をする

# システム要件
①アンケートCSVをCloud Storageにアップロード
②Cloud Storageにアップロードをトリガーに、CloudFusionでETLを行い、BigTableにインサート
③BigTableのテーブルをBigQueryに外部テーブル登録
④BigTableへのクエリで、アンケートデータにアクセス可能

![Datafusionシステム化方式 drawio](https://user-images.githubusercontent.com/26422417/165108808-7fb86050-2075-4a05-8721-00135dc46c02.png)

## IF要件
### IF項目要件
| Name | Description |　Type | example |
| ------------- | ------------- | ------------- | ------------- |
| quetionaire_id | アンケートID | string | 20220502 |
| respondent_id | 回答者ID | integer | 1 | 
| timestamp | 回答日時 | timestamp | 2022-05-03 00:00:00 |
| q1 | Q1回答結果 | string | どちらでもない |
| q2 | Q2回答結果 | string | どちらでもない |
| q3 | Q3回答結果 | string | どちらでもない |
以下、q4, q5とアンケートによって続いていく。

### IF処理要件
#### From: GCS
- Project: {自分のProjectID}
- Region: us-central1
- BucketName: asasaki_questionaire_bucket
- Dir: /weekly_questionaire/

#### With: Data Fusion

#### To: BigTable



## テーブル要件
### テーブル一覧
- Service: BigTable
  - Project: {自分のProjectID}
  - Dataset: {自分のDatasetID}
  - table: 
- Service: BigQuery
  - Project: {自分のProjectID}
  - Dataset: {自分のDatasetID}
  - table: 

### テーブル項目要件
| Name | Description |　Type | example |
| ------------- | ------------- | ------------- | ------------- |
| quetionaire_id | アンケートID | string | 20220502 |
| respondent_id | 回答者ID | integer | 1 | 
| timestamp | 回答日時 | timestamp | 2022-05-03 00:00:00 |
| q1 | Q1回答結果 | string | どちらでもない |
| q2 | Q2回答結果 | string | どちらでもない |
| q3 | Q3回答結果 | string | どちらでもない |
以下、q4, q5とアンケートによって続いていく。