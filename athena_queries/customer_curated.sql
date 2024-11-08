CREATE EXTERNAL TABLE IF NOT EXISTS `sensor_data_lakehouse`.`customer_curated` (
  `customerName` STRING,
  `email` STRING,
  `phone` STRING,
  `birthDay` STRING,
  `serialNumber` STRING,
  `registrationDate` BIGINT,
  `lastUpdateDate` BIGINT,
  `shareWithResearchAsOfDate` BIGINT,
  `shareWithPublicAsOfDate` BIGINT,
  `shareWithFriendsAsOfDate` BIGINT
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3://sensor-data-lakehouse-customer-curated/'
TBLPROPERTIES ('classification' = 'json');
