CREATE EXTERNAL TABLE IF NOT EXISTS `sensor_data_lakehouse`.`step_trainer_landing` (
  `sensorReadingTime` BIGINT,
  `serialNumber` STRING,
  `distanceFromObject` INT
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3://sensor-data-lakehouse-step-trainer-landing/'
TBLPROPERTIES ('classification' = 'json');
