CREATE EXTERNAL TABLE IF NOT EXISTS `sensor_data_lakehouse`.`customer_trusted` (
  `customerName` STRING,
  `email` STRING,
  `phone` STRING,
  `birthDay` STRING,
  `serialNumber` STRING,
  `registrationDate` BIGINT,
  `lastupdatedate` BIGINT,
  `sharewithresearchasofdate` BIGINT,
  `sharewithpublicasofdate` BIGINT,
  `sharewithfriendsasofdate` BIGINT
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3://sensor-data-lakehouse-customer-trusted/'
TBLPROPERTIES ('classification' = 'json');
