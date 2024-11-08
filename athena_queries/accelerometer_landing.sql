CREATE EXTERNAL TABLE IF NOT EXISTS `sensor_data_lakehouse`.`accelerometer_landing` (
  `user` STRING,
  `x` FLOAT,
  `y` FLOAT,
  `z` FLOAT,
  `timeStamp` BIGINT
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3://sensor-data-lakehouse-accelerometer-landing/'
TBLPROPERTIES ('classification' = 'json');
