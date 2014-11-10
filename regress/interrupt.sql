-- liblwgeom interruption

CREATE TEMPORARY TABLE _time AS SELECT now() t;

CREATE FUNCTION _timecheck(label text, tolerated interval) RETURNS text
AS $$
DECLARE
  ret TEXT;
  lap INTERVAL;
BEGIN
  lap := now()-t FROM _time;
  IF lap <= tolerated THEN ret := label || ' interrupted on time';
  ELSE ret := label || ' interrupted late: ' || lap;
  END IF;
  UPDATE _time SET t = now();
  RETURN ret;
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

CREATE TEMP TABLE _inputs AS
SELECT 1::int as id, ST_Collect(g) g FROM (
 SELECT ST_MakeLine(
   ST_Point(cos(radians(x)),sin(radians(270-x))),
   ST_Point(sin(radians(x)),cos(radians(60-x)))
   ) g
 FROM generate_series(1,720) x
 ) foo
;


-----------------
-- ST_Segmentize
-----------------

SET statement_timeout TO 100;
SELECT ST_Segmentize(ST_MakeLine(ST_Point(4,39), ST_Point(1,41)), 1e-100);
SELECT _timecheck('segmentize', '150ms');
SET statement_timeout TO 0;
-- Not affected by old timeout
SELECT '1',ST_AsText(ST_Segmentize('LINESTRING(0 0,4 0)'::geometry, 2));


DROP FUNCTION _timecheck(text, interval);