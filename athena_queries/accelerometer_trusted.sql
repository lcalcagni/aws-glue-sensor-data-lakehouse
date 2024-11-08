CREATE EXTERNAL TABLE IF NOT EXISTS `sensor_data_lakehouse`.`accelerometer_trusted` (
  `user` STRING,
  `x` FLOAT,
  `y` FLOAT,
  `z` FLOAT,
  `timestamp` BIGINT
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3://sensor-data-lakehouse-accelerometer-trusted/'
TBLPROPERTIES ('classification' = 'json');
