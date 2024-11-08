CREATE EXTERNAL TABLE IF NOT EXISTS `sensor_data_lakehouse`.`machine_learning_curated` (
  `user` STRING,
  `x` FLOAT,
  `y` FLOAT,
  `z` FLOAT,
  `timestamp` BIGINT,
  `sensorReadingTime` BIGINT,
  `serialNumber` STRING,
  `distanceFromObject` BIGINT
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3://sensor-data-lakehouse-machine-learning-curated/'
TBLPROPERTIES ('classification' = 'json');
