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
