CREATE TEMPORARY FUNCTION parse_json_data(json_data STRING)
RETURNS STRUCT<questionaire_id string, respondent_id string, timestamp string, q1 string, q2 string, q5 string>
LANGUAGE js
AS "return JSON.parse(json_data);";

with input_data as (
SELECT answer as json_data
FROM `test-asasaki.asasaki_data_infra_dataset.survey`
)
, parse_data as (
  SELECT
    parse_json_data(json_data).*
  FROM
    input_data
)

SELECT
  *
FROM parse_data