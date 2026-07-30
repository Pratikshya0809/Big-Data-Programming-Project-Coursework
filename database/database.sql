

CREATE TABLE operators (
  operator_ref VARCHAR(20) PRIMARY KEY,
  operator_name VARCHAR(100)
);
CREATE TABLE routes (
  line_ref VARCHAR(50) PRIMARY KEY,
  route_name VARCHAR(100),
  scheduled_headway_sec DOUBLE
);
CREATE TABLE timetable_stops (
  stop_id INT AUTO_INCREMENT PRIMARY KEY,
  line_ref VARCHAR(50),
  service_code VARCHAR(50),
  operator_noc VARCHAR(20),
  vehicle_journey_code VARCHAR(50),
  direction VARCHAR(20),
  route_ref VARCHAR(50),
  stop_sequence INT,
  stop_point_ref VARCHAR(50),
  stop_name VARCHAR(150),
  scheduled_time_sec INT,
  source_file VARCHAR(200),
  FOREIGN KEY (line_ref) REFERENCES routes(line_ref),
  FOREIGN KEY (operator_noc) REFERENCES operators(operator_ref)
);
CREATE TABLE vehicle_locations (
  location_id INT AUTO_INCREMENT PRIMARY KEY,
  poll_timestamp DATETIME,
  recorded_at_time DATETIME,
  line_ref VARCHAR(50),
  vehicle_ref VARCHAR(50),
  operator_ref VARCHAR(20),
  latitude DOUBLE,
  longitude DOUBLE,
  bearing INT,
  FOREIGN KEY (line_ref) REFERENCES routes(line_ref),
  FOREIGN KEY (operator_ref) REFERENCES operators(operator_ref)
);
CREATE TABLE bunching_events (
  event_id INT AUTO_INCREMENT PRIMARY KEY,
  line_ref VARCHAR(50),
  vehicle_ref VARCHAR(50),
  recorded_at_time DATETIME,
  observed_headway_sec DOUBLE,
  scheduled_headway_sec DOUBLE,
  headway_ratio DOUBLE,
  is_bunching INT
);

-- operators
INSERT INTO operators VALUES ('SCCU', 'Stagecoach Cumbria');
INSERT INTO operators VALUES ('SCMY', 'Stagecoach Merseyside & South Lancashire');

-- routes (all, small table)
INSERT INTO routes VALUES ('1', 'Route 1', 339.3559300925734);
INSERT INTO routes VALUES ('10', 'Route 10', 1508.108108108108);
INSERT INTO routes VALUES ('100', 'Route 100', 767.0337837837837);
INSERT INTO routes VALUES ('104', 'Route 104', 1663.7624466571835);
INSERT INTO routes VALUES ('109', 'Route 109', 1659.7202797202797);
INSERT INTO routes VALUES ('11', 'Route 11', 1591.6666666666667);
INSERT INTO routes VALUES ('111', 'Route 111', 407.7663189968358);
INSERT INTO routes VALUES ('125', 'Route 125', 478.5245901639344);
INSERT INTO routes VALUES ('127', 'Route 127', 1982.7272727272727);
INSERT INTO routes VALUES ('18', 'Route 18', 3600.0);
INSERT INTO routes VALUES ('1A', 'Route 1A', 618.8829238075573);
INSERT INTO routes VALUES ('2', 'Route 2', 538.8540275923453);
INSERT INTO routes VALUES ('22', 'Route 22', 7233.75);
INSERT INTO routes VALUES ('22A', 'Route 22A', 7242.857142857143);
INSERT INTO routes VALUES ('280', 'Route 280', 1068.5761047463177);
INSERT INTO routes VALUES ('29', 'Route 29', 3561.428571428572);
INSERT INTO routes VALUES ('29A', 'Route 29A', 3705.333333333333);
INSERT INTO routes VALUES ('2A', 'Route 2A', 1836.8649193548383);
INSERT INTO routes VALUES ('2X', 'Route 2X', 1189.06015037594);
INSERT INTO routes VALUES ('3', 'Route 3', 583.448275862069);
INSERT INTO routes VALUES ('30', 'Route 30', 843.7041156840935);
INSERT INTO routes VALUES ('300', 'Route 300', 1284.1254355400697);
INSERT INTO routes VALUES ('32', 'Route 32', 2473.846153846154);
INSERT INTO routes VALUES ('3A', 'Route 3A', 1953.9130434782608);
INSERT INTO routes VALUES ('4', 'Route 4', 1286.3226744186045);
INSERT INTO routes VALUES ('40', 'Route 40', 2640.192307692308);
INSERT INTO routes VALUES ('400', 'Route 400', 6955.0);
INSERT INTO routes VALUES ('41', 'Route 41', 1960.1779755283649);
INSERT INTO routes VALUES ('41A', 'Route 41A', 3275.0);
INSERT INTO routes VALUES ('42', 'Route 42', 1605.568181818182);
INSERT INTO routes VALUES ('42A', 'Route 42A', 3240.0);
INSERT INTO routes VALUES ('43', 'Route 43', 4028.571428571429);
INSERT INTO routes VALUES ('43A', 'Route 43A', 3200.0);
INSERT INTO routes VALUES ('44', 'Route 44', 1688.1818181818182);
INSERT INTO routes VALUES ('45', 'Route 45', 3163.6363636363635);
INSERT INTO routes VALUES ('46', 'Route 46', 3675.0);
INSERT INTO routes VALUES ('49', 'Route 49', 2280.6015037593984);
INSERT INTO routes VALUES ('5', 'Route 5', 1460.9514170040484);
INSERT INTO routes VALUES ('50', 'Route 50', 1520.357142857143);
INSERT INTO routes VALUES ('505', 'Route 505', 4350.0);
INSERT INTO routes VALUES ('508', 'Route 508', 3798.461538461538);
INSERT INTO routes VALUES ('509', 'Route 509', 5200.0);
INSERT INTO routes VALUES ('51', 'Route 51', 1465.7142857142858);
INSERT INTO routes VALUES ('516', 'Route 516', 3740.0);
INSERT INTO routes VALUES ('517', 'Route 517', 6300.0);
INSERT INTO routes VALUES ('52', 'Route 52', 1331.1159546643416);
INSERT INTO routes VALUES ('530', 'Route 530', 8730.0);
INSERT INTO routes VALUES ('534', 'Route 534', 11475.0);
INSERT INTO routes VALUES ('55', 'Route 55', 2151.711079943899);
INSERT INTO routes VALUES ('553', 'Route 553', 8450.0);
INSERT INTO routes VALUES ('554', 'Route 554', 2564.3823529411766);
INSERT INTO routes VALUES ('555', 'Route 555', 1033.3735979292494);
INSERT INTO routes VALUES ('559', 'Route 559', 900.0);
INSERT INTO routes VALUES ('563', 'Route 563', 3995.4545454545455);
INSERT INTO routes VALUES ('567', 'Route 567', 4080.0);
INSERT INTO routes VALUES ('59', 'Route 59', 618.4342145554762);
INSERT INTO routes VALUES ('599', 'Route 599', 1124.5454545454545);
INSERT INTO routes VALUES ('6', 'Route 6', 1599.1538461538462);
INSERT INTO routes VALUES ('60', 'Route 60', 7950.0);
INSERT INTO routes VALUES ('600', 'Route 600', 2518.9655172413795);
INSERT INTO routes VALUES ('61', 'Route 61', 488.27472527472526);
INSERT INTO routes VALUES ('62', 'Route 62', 902.7150537634408);
INSERT INTO routes VALUES ('63', 'Route 63', 1105.8259423503323);
INSERT INTO routes VALUES ('63A', 'Route 63A', 2559.56043956044);
INSERT INTO routes VALUES ('64', 'Route 64', 3492.5);
INSERT INTO routes VALUES ('67', 'Route 67', 603.4983766233767);
INSERT INTO routes VALUES ('68', 'Route 68', 912.0);
INSERT INTO routes VALUES ('685', 'Route 685', 1173.799734748011);
INSERT INTO routes VALUES ('6A', 'Route 6A', 956.4651493598864);
INSERT INTO routes VALUES ('6B', 'Route 6B', 4050.0);
INSERT INTO routes VALUES ('6C', 'Route 6C', 3600.0);
INSERT INTO routes VALUES ('7', 'Route 7', 5023.928571428572);
INSERT INTO routes VALUES ('71', 'Route 71', 7560.0);
INSERT INTO routes VALUES ('721', 'Route 721', 60.0);
INSERT INTO routes VALUES ('755', 'Route 755', 1980.9272727272728);
INSERT INTO routes VALUES ('77', 'Route 77', 5750.0);
INSERT INTO routes VALUES ('77A', 'Route 77A', 6100.0);
INSERT INTO routes VALUES ('77C', 'Route 77C', 6112.5);
INSERT INTO routes VALUES ('78', 'Route 78', 2266.6666666666665);
INSERT INTO routes VALUES ('81', 'Route 81', 3600.0);
INSERT INTO routes VALUES ('88', 'Route 88', 3136.363636363636);
INSERT INTO routes VALUES ('89', 'Route 89', 4170.0);
INSERT INTO routes VALUES ('9', 'Route 9', 870.4225352112676);
INSERT INTO routes VALUES ('93', 'Route 93', 9945.0);
INSERT INTO routes VALUES ('99', 'Route 99', 450.0);
INSERT INTO routes VALUES ('EL1', 'Route EL1', 1607.5471698113208);
INSERT INTO routes VALUES ('M1', 'Route M1', 2481.0);
INSERT INTO routes VALUES ('P1', 'Route P1', 573.9073950699533);
INSERT INTO routes VALUES ('S11', 'Route S11', 900.0);
INSERT INTO routes VALUES ('S15', 'Route S15', 900.0);
INSERT INTO routes VALUES ('S22', 'Route S22', 900.0);
INSERT INTO routes VALUES ('S32', 'Route S32', 900.0);
INSERT INTO routes VALUES ('S90', 'Route S90', 900.0);
INSERT INTO routes VALUES ('S91', 'Route S91', 900.0);
INSERT INTO routes VALUES ('S92', 'Route S92', 900.0);
INSERT INTO routes VALUES ('S93', 'Route S93', 900.0);
INSERT INTO routes VALUES ('S96', 'Route S96', 900.0);
INSERT INTO routes VALUES ('UB1', 'Route UB1', 7297.5);
INSERT INTO routes VALUES ('UB2', 'Route UB2', 9195.0);
INSERT INTO routes VALUES ('X2', 'Route X2', 470.2272727272728);
INSERT INTO routes VALUES ('X4', 'Route X4', 1950.6521739130435);
INSERT INTO routes VALUES ('X5', 'Route X5', 1545.8711433756805);
INSERT INTO routes VALUES ('X5S', 'Route X5S', 900.0);
INSERT INTO routes VALUES ('X6', 'Route X6', 1893.3471933471933);
INSERT INTO routes VALUES ('X7', 'Route X7', 5494.285714285714);
INSERT INTO routes VALUES ('X8', 'Route X8', 2900.0);

-- vehicle_locations (sample of 20 rows)
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-29 03:20:13', 'X5', 'SCCU-10014', 'SCCU', '54.667065', '-2.75572', '96');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-29 04:00:51', 'X5', 'SCCU-10548', 'SCCU', '54.643574', '-3.548556', '54');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 18:58:20', '300', 'SCCU-10624', 'SCCU', '0.0', '0.0', '0');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 22:31:42', '300', 'SCCU-11123', 'SCCU', '54.845909', '-3.041166', '258');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-29 01:25:25', 'X5', 'SCCU-11124', 'SCCU', '54.642746', '-3.545311', '0');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-29 00:01:53', '1', 'SCCU-11633', 'SCCU', '53.760639', '-2.695254', '342');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 23:09:58', '1', 'SCCU-12211', 'SCCU', '54.050854', '-2.800524', '0');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-29 01:11:04', '599', 'SCCU-13801', 'SCCU', '54.330986', '-2.744337', '78');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-29 00:30:16', '599', 'SCCU-13802', 'SCCU', '54.329651', '-2.74497', '174');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 22:23:01', '599', 'SCCU-13803', 'SCCU', '54.331047', '-2.743807', '66');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-29 00:41:13', '599', 'SCCU-13806', 'SCCU', '54.330776', '-2.745596', '72');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-29 02:23:10', 'X5', 'SCCU-15222', 'SCCU', '54.64373', '-3.548731', '0');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 12:03:24', '300', 'SCCU-15223', 'SCCU', '0.0', '0.0', '0');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 23:20:49', '1', 'SCCU-15300', 'SCCU', '53.760361', '-2.696067', '264');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 18:23:46', '1', 'SCCU-15578', 'SCCU', '53.831356', '-2.602638', '306');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 15:02:04', 'X5', 'SCCU-15723', 'SCCU', '54.610222', '-3.194064', '132');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 23:19:39', '1', 'SCCU-15729', 'SCCU', '54.097408', '-3.257873', '342');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 23:20:23', 'X5', 'SCCU-15849', 'SCCU', '54.642765', '-3.545971', '282');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-28 14:00:34', '1', 'SCCU-15854', 'SCCU', '0.0', '0.0', '0');
INSERT INTO vehicle_locations (poll_timestamp, recorded_at_time, line_ref, vehicle_ref, operator_ref, latitude, longitude, bearing) VALUES ('2026-07-29 09:05:56.291253', '2026-07-29 04:21:24', '2A', 'SCCU-15910', 'SCCU', '0.0', '0.0', '0');

-- bunching_events (sample of 20 rows)
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-15578', '2026-07-28 18:23:46', 15792.0, 339.3559300925734, 46.53521155705774, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-36990', '2026-07-28 22:42:54', 15548.0, 339.3559300925734, 45.81620246258446, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-37041', '2026-07-28 22:47:55', 301.0, 339.3559300925734, 0.8869743337559765, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-12211', '2026-07-28 23:09:58', 1323.0, 339.3559300925734, 3.8985616065088267, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-37484', '2026-07-28 23:15:21', 323.0, 339.3559300925734, 0.9518030226019283, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-15729', '2026-07-28 23:19:39', 258.0, 339.3559300925734, 0.7602637146479798, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-15300', '2026-07-28 23:20:49', 70.0, 339.3559300925734, 0.2062731008734829, 1);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-36820', '2026-07-28 23:33:19', 750.0, 339.3559300925734, 2.210068937930174, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-36103', '2026-07-28 23:47:43', 864.0, 339.3559300925734, 2.5459994164955604, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-11633', '2026-07-29 00:01:53', 850.0, 339.3559300925734, 2.504744796320864, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCMY-10577', '2026-07-29 00:08:49', 416.0, 339.3559300925734, 1.2258515709052697, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCMY-10814', '2026-07-29 00:34:54', 1565.0, 339.3559300925734, 4.6116771838142965, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-36988', '2026-07-29 00:41:48', 414.0, 339.3559300925734, 1.2199580537374561, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCMY-11624', '2026-07-29 00:42:00', 12.0, 339.3559300925734, 0.035361103006882784, 1);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCMY-11621', '2026-07-29 01:18:17', 2177.0, 339.3559300925734, 6.415093437165318, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCMY-11625', '2026-07-29 01:29:48', 691.0, 339.3559300925734, 2.036210181479667, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCMY-11101', '2026-07-29 01:56:36', 1608.0, 339.3559300925734, 4.738387802922293, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCCU-27291', '2026-07-29 01:59:41', 185.0, 339.3559300925734, 0.5451503380227762, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCMY-11623', '2026-07-29 02:11:51', 730.0, 339.3559300925734, 2.151133766252036, 0);
INSERT INTO bunching_events (line_ref, vehicle_ref, recorded_at_time, observed_headway_sec, scheduled_headway_sec, headway_ratio, is_bunching) VALUES ('1', 'SCMY-10576', '2026-07-29 02:32:39', 1248.0, 339.3559300925734, 3.6775547127158097, 0);

SHOW TABLES;

SELECT COUNT(*) FROM operators;
SELECT COUNT(*) FROM routes;
SELECT COUNT(*) FROM vehicle_locations;
SELECT COUNT(*) FROM bunching_events;

