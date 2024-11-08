CREATE EXTERNAL TABLE IF NOT EXISTS `sensor_data_lakehouse`.`step_trainer_trusted` (
  `sensorReadingTime` BIGINT,
  `serialNumber` STRING,
  `distanceFromObject` BIGINT
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3://sensor-data-lakehouse-step-trainer-trusted/'
TBLPROPERTIES ('classification' = 'json');
